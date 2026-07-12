# 🎧 LTV-Based Acquisition Strategy: SaaS Subscription Optimization

<p>
  <img src="https://img.shields.io/badge/Google%20BigQuery-669DF6?style=flat&logo=google-cloud&logoColor=white" alt="BigQuery">
  <img src="https://img.shields.io/badge/AWS%20Athena-232F3E?style=flat&logo=amazon-aws&logoColor=white" alt="AWS Athena">
  <img src="https://img.shields.io/badge/dbt_Cloud-FF6B6B?style=flat&logo=dbt&logoColor=white" alt="dbt Cloud">
  <img src="https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white" alt="Python">
  <img src="https://img.shields.io/badge/SQL-4479A1?style=flat&logo=postgresql&logoColor=white" alt="SQL">
  <img src="https://img.shields.io/badge/Power_BI-F2C811?style=flat&logo=powerbi&logoColor=black" alt="Power BI">
</p>

*An independent enterprise-architecture case study demonstrating multi-cloud ELT workflows, behavioral intent classification, and data-driven margin optimization.*

---

## 🎯 The Business Problem: Burning Cash on Low-Value Users

In a B2C Subscription SaaS business model, not all customers are created equal[cite: 1]. For a music streaming platform like KKBox, evaluating marketing success purely by Customer Acquisition Cost (CAC) and raw user count creates a dangerous financial trap[cite: 1]. 

If the marketing team spends $50 to acquire a user from a specific channel, but that user only pays for one month ($10) before leaving, the company loses $40 per acquisition[cite: 1]. For instance, a platform might acquire 1,000 "low-value" users through cheap social media ads who churn immediately, versus acquiring 100 "power users" through targeted ads who stay for 12+ months and generate massive profit[cite: 1].

**The Objective:**
To build a diagnostic data model that joins user memberships and transaction logs to identify exactly which registration channels (`registered_via`) produce users with the highest Lifetime Value (LTV)[cite: 1]. The ultimate goal is to shift the marketing budget away from high-churn sources and double down on the channels that bring in long-term "Power Users"[cite: 1].

The core financial formula driving this analysis is:
$$ LTV = \frac{ARPU}{\text{Churn Rate}} \times \text{Gross Margin} $$

---

## ⚙️ Core Analytical Execution & Sub-Questions

To identify the profitable segments, I engineered a data pipeline that answers five distinct business questions, applying advanced logic to raw transactional data:

1. **Which registration channels are actually paying our bills?** 
  
2. **What is the expected 'Active Life' of a user from each channel?** 
  
3. **Are we acquiring 'Serial Churners' through promos?** 
   
4. **Does the acquisition channel dictate the payment method (and thus the churn)?** 
   
5. **How many months does it take to 'break even' on a user from this channel?** 
   
---
## ELT Architecture and Data flow

### Goolge : 

<img width="1529" height="991" alt="cart_google" src="https://github.com/user-attachments/assets/6f68ec92-b2ca-4f49-8a04-977871b9b637" /> 

### Aws : 
<img width="1141" height="621" alt="cart_security drawio" src="https://github.com/user-attachments/assets/ae5299f6-a247-4a4b-863c-e75e72ba09b2" />
<img width="2459" height="1551" alt="cart_architecture drawio" src="https://github.com/user-attachments/assets/317c3339-14b2-4c05-a580-16dd340491bf" />

---
## 📁 Raw Data volume
This project processes enterprise-grade data volumes, strictly requiring a robust cloud data warehouse architecture (GCP + BigQuery + dbt) rather than localized processing tools. The raw data ingestion and transformation pipeline handles:
* **Transactions Log:** `22,978,755` rows of historical subscription payments, auto-renewals, and plan changes.
* **Members Log:** `6,769,473` rows of unique user demographics and registration metadata.

<img width="1903" height="757" alt="image" src="https://github.com/user-attachments/assets/7a277f45-f539-4c7c-9591-e6e8d19468d4" />

## dbt Data Lineage & Transformation DAG 
<img width="781" height="571" alt="dbt-lineage drawio" src="https://github.com/user-attachments/assets/75ed5f24-1f0c-489f-a62f-d5b49b9874d1" />

---
### 📂 Repository Structure & SQL Models

To maintain enterprise-grade code hygiene and modularity, the entire data transformation layer is built using dbt Core. Below is the directory structure detailing the staging, cleaning, and aggregation models processing the 29 million+ rows.

*Note: Navigate directly into the `models/aggregate/` directory to review the complex Window Functions and Business Logic calculations powering the LTV engine.*

```text
channel_data_preprocessing/
├── models/
│   ├── stageing/                           # Raw data standardization & type casting
│   │   ├── stg_members.sql
│   │   ├── stg_transactions.sql
│   │   └── stg_user_logs.sql
│   ├── cleaning/                           # Demographic data imputation & NULL handling
│   │   └── raw_cleaning_members.sql
│   ├── aggregate/                          # Core LTV metrics & intent classifications
│   │   └── aggregate_raw_data.sql
│   └── sources.yml                         # Source definitions mapped to BigQuery raw tables
├── logs/
│   └── dbt.log                             # Execution logs for debugging
├── target/                                 # Compiled SQL (generated post dbt run)
├── dbt_project.yml                         # Main dbt project configuration and materialization rules
├── .gitignore                              
├── command.txt                             # Stored execution commands
└── README.md                               # Project documentation (You are here)
## 📁 Data Sourcing & Simulation

To ensure strict adherence to data privacy standards and completely separate this independent case study from any professional work experience, the raw membership and transactional data powering this architecture is a synthetically scaled version of a public dataset: [WSDM - KKBox's Churn Prediction Challenge](https://www.kaggle.com/competitions/kkbox-churn-prediction-challenge/data).

<img width="1903" height="757" alt="image" src="https://github.com/user-attachments/assets/9bd602a7-8ad0-4118-9284-4af45152a633" />
```
---
### 🧠 Core Engineering Logic: LTV & Cohort Classification (Demo Snippet)

*📌 Note: The snippet below is a demonstration highlighting the core logic. The complete dbt models within this repository heavily utilize advanced SQL techniques including complex `CTEs`, deductive `WINDOW` functions, cross-table `LEFT JOINS`, and dynamic `CASE` statements to execute SaaS business logic directly within BigQuery.*

The true value of this diagnostic model lies in correctly identifying the current state of a user and classifying their Lifetime Value (LTV). Below is the logic snippet that uses a "Time Machine" approach to isolate a user's latest subscription status, calculates their tenure, and dynamically flags them as a "High-Value User" or a "Promo Hunter".

```sql
-- Snippet from: models/aggregate/aggregate_raw_data.sql

-- STEP 1: The "Time Machine" (Deduplicating to find the exact current state of the user)
WITH transaction_ranked AS (
    SELECT 
        msno,
        payment_method_id,
        is_auto_renew,
        is_cancel,
        transaction_date,
        membership_expire_date,
        -- Tie-breaker: If dates match, prioritize the furthest expiry date to prevent false churn flags
        ROW_NUMBER() OVER(
            PARTITION BY msno 
            ORDER BY transaction_date DESC, membership_expire_date DESC
        ) as rn
    FROM {{ ref('stg_transactions') }}
),

-- STEP 2: The Business Logic Engine (Extracting the final VIP Classifications)
SELECT 
    f.*,
    
    -- The Survival Flag: Determines if the user has technically churned based on business rules
    CASE 
        WHEN f.latest_membership_expire_date < DATE '2017-03-31' THEN 1 -- User Churned
        ELSE 0 -- User Active (Censored)
    END AS is_Churned, 

    -- The Promo Hunter Flag: Identifies users strictly reliant on heavily discounted acquisitions
    CASE 
        WHEN f.total_discount_burn > 0 THEN 1 
        ELSE 0 
    END AS is_discounted,

    -- The Ultimate KPI: Defining the profitable "Power User" 
    CASE 
        WHEN f.sum_actual_amount_paid >= 80.29 
         AND f.sum_actual_amount_paid >= f.sum_plan_list_price 
         AND f.Tenure_Days >= 365 
        THEN 1 
        ELSE 0 
    END AS is_High_Value_User

FROM final_merged f
WHERE f.Tenure_Days >= 0; -- System noise filtration

```
---
---
## 📈 Final Deliverable: Business Intelligence & Actionable Insights

https://app.powerbi.com/view?r=eyJrIjoiZDY3ODEzYTctOGY3MS00MDQ0LWEwZWMtZDcxYTM2MjJmY2Y0IiwidCI6IjM0YmQ4YmVkLTJhYzEtNDFhZS05ZjA4LTRlMGEzZjExNzA2YyJ9

<img width="1819" height="961" alt="Screenshot (38)" src="https://github.com/user-attachments/assets/8de53ee1-3dc8-448e-b373-4feedd974dd9" />
<img width="1824" height="972" alt="Screenshot (39)" src="https://github.com/user-attachments/assets/e56895d5-0e04-4bae-99ae-4326969f6200" />
<img width="1835" height="970" alt="Screenshot (40)" src="https://github.com/user-attachments/assets/ed84796a-e4ae-47c5-b4f2-1ae99b5c650c" />
<img width="1826" height="970" alt="Screenshot (41)" src="https://github.com/user-attachments/assets/145a91d3-8968-48d4-98b0-e0af7830668b" />
<img width="1833" height="993" alt="Screenshot (45)" src="https://github.com/user-attachments/assets/735795a5-aa48-430b-b2f2-edd3b61e1c9c" />
<img width="1583" height="979" alt="Screenshot (47)" src="https://github.com/user-attachments/assets/070cbe82-a3a9-443c-a313-d2c250b7c75d" />

----
## 📁 Data Sourcing & Simulation

To ensure strict adherence to data privacy standards and completely separate this independent case study from any professional work experience, the raw membership and transactional data powering this architecture is a synthetically scaled version of a public dataset: [WSDM - KKBox's Churn Prediction Challenge](https://www.kaggle.com/competitions/kkbox-churn-prediction-challenge/data).

The raw data was structurally modified, aggregated across multiple subscription touchpoints (auto-renewals, active cancellations, plan changes, and user demographics), and scaled to simulate a massive B2C enterprise multi-cloud environment. This allowed me to rigorously stress-test the GCP + BigQuery + dbt ELT pipeline and demonstrate production-grade analytical capabilities without utilizing proprietary company data.
