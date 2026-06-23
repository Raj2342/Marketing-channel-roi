{{ config(
    materialized='table',
    format='parquet'
) }}

SELECT 
    msno,
    payment_method_id,
    payment_plan_days,
    plan_list_price,
    actual_amount_paid,
    is_auto_renew,
    is_cancel,
    -- Converted from BIGINT to DATE
    CAST(date_parse(CAST(transaction_date AS VARCHAR), '%Y%m%d') AS DATE) AS transaction_date,
    CAST(date_parse(CAST(membership_expire_date AS VARCHAR), '%Y%m%d') AS DATE) AS membership_expire_date
FROM {{ source('marketing_raw', 'transactions') }}