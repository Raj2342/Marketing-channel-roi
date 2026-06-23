

-- STEP 1: The "Time Machine" (Rank all transactions by date)
WITH transaction_ranked AS (
    SELECT 
        msno,
        payment_method_id,
        is_auto_renew,
        is_cancel,
        transaction_date,
        membership_expire_date,
        -- Tie-breaker added: If date is same, pick the furthest expiry date
        ROW_NUMBER() OVER(
            PARTITION BY msno 
            ORDER BY transaction_date DESC, membership_expire_date DESC
        ) as rn
    FROM "awsdatacatalog"."marketing_analytics_native"."stg_transactions"
),

-- STEP 2: Extract ONLY the Latest Status (Where rn = 1)
transaction_latest AS (
    SELECT 
        msno,
        payment_method_id AS latest_payment_method_id,
        is_auto_renew AS latest_is_auto_renew,
        is_cancel AS latest_is_cancel
    FROM transaction_ranked
    WHERE rn = 1
),

-- STEP 3: The "Math Engine" (Calculate Totals, Averages, and Dates)
transaction_agg AS (
    SELECT 
        msno,
        
        -- Row count
        COUNT(*) AS total_transactions,
        
        -- Sum metrics
        SUM(payment_plan_days) AS sum_payment_plan_days,
        
        -- 1. Convert List Price & Actual Paid to USD during Aggregation (JARVIS FIX: Cast to DOUBLE for AWS)
        ROUND(SUM(CAST(plan_list_price AS DOUBLE)) / 31.0, 2) AS sum_plan_list_price,
        ROUND(SUM(CAST(actual_amount_paid AS DOUBLE)) / 31.0, 2) AS sum_actual_amount_paid,
        
        -- Avg metrics (JARVIS FIX: Cast to DOUBLE)
        AVG(CAST(payment_plan_days AS DOUBLE)) AS avg_payment_plan_days,
        ROUND(AVG(CAST(plan_list_price AS DOUBLE)) / 31.0, 2) AS avg_plan_list_price,
        ROUND(AVG(CAST(actual_amount_paid AS DOUBLE)) / 31.0, 2) AS avg_actual_amount_paid,
        
        -- FIX: Directly cast the standard string/timestamp to DATE
        CAST(MIN(transaction_date) AS DATE) AS first_transaction_date,
        CAST(MAX(transaction_date) AS DATE) AS last_transaction_date,
        CAST(MAX(membership_expire_date) AS DATE) AS latest_membership_expire_date ,

        ROUND(SUM(GREATEST(0.0, CAST(plan_list_price AS DOUBLE) - CAST(actual_amount_paid AS DOUBLE))) / 31.0, 2) AS total_discount_burn
        
    FROM "awsdatacatalog"."marketing_analytics_native"."stg_transactions"
    GROUP BY msno
),

-- STEP 4: Fetch Members Data (JARVIS FIX: Added missing demographic columns)
members_data AS (
    SELECT 
        msno,
        city,
        bd,
        gender,
        registered_via,
        registration_init_time
    FROM "awsdatacatalog"."marketing_analytics_native"."raw_cleaning_members"
),

-- STEP 5: Bring it all together (The LEFT JOIN)
final_merged AS (
    SELECT 
        a.*,
        
        l.latest_payment_method_id,
        l.latest_is_auto_renew,
        l.latest_is_cancel,
        
       
        -- THE FIX: Catching Ghost Nulls exactly where the LEFT JOIN happens
        COALESCE(CAST(m.registered_via AS VARCHAR), 'Missing Info') AS registered_via,
        COALESCE(m.registration_init_time, DATE '1900-01-01') AS registration_init_time,
        
        -- Calculate Tenure in Days (JARVIS FIX: Athena uses date_diff('day', start_date, end_date))
        COALESCE(date_diff('day', a.first_transaction_date, a.latest_membership_expire_date), 0) AS Tenure_Days ,

        -- Create the Event Flag for Survival Analysis
        CASE 
            -- Assuming the dataset cutoff is March 31, 2017. Adjust this date to your actual max date! (JARVIS FIX: added DATE keyword)
            WHEN a.latest_membership_expire_date < DATE '2017-03-31' THEN 1 -- The user has churned
            ELSE 0 -- The user is still active (Censored)
        END AS is_Churned , 

        -- Add this directly into your existing calculated_metrics CTE in dbt
        
        -- THE FIX: The "Promo Hunter" Flag (No SUM needed here)
        CASE 
            WHEN a.total_discount_burn > 0 THEN 1 
            ELSE 0 
        END AS is_discounted

    FROM transaction_agg a
    LEFT JOIN transaction_latest l 
        ON a.msno = l.msno
    LEFT JOIN members_data m 
        ON a.msno = m.msno
)

-- STEP 6: Apply the VIP Flag (The 1/0 Logic)
SELECT 
    *,
    -- The Iron Man Flag: High Value User Definition
    CASE 
        WHEN sum_actual_amount_paid >= 80.29 
         AND sum_actual_amount_paid >= sum_plan_list_price 
         AND Tenure_Days >= 365 
        THEN 1 
        ELSE 0 
    END AS is_High_Value_User

FROM final_merged
-- THE FIX: Erase the 8,545 "System Ghost" records before they hit Power BI
WHERE Tenure_Days >= 0