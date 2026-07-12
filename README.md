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
## 📁 Raw Data Sourcing & Scale

To ensure strict adherence to data privacy standards and completely separate this independent case study from any professional work experience, the raw membership and transactional data powering this architecture is sourced from a public dataset: [WSDM - KKBox's Churn Prediction Challenge](https://www.kaggle.com/competitions/kkbox-churn-prediction-challenge/data).

**Data Volume & Processing Scale:**
This project processes enterprise-grade data volumes, strictly requiring a robust cloud data warehouse architecture (GCP + BigQuery + dbt) rather than localized processing tools. The raw data ingestion and transformation pipeline handles:
* **Transactions Log:** `22,978,755` rows of historical subscription payments, auto-renewals, and plan changes.
* **Members Log:** `6,769,473` rows of unique user demographics and registration metadata.



## 📁 Data Sourcing & Simulation

To ensure strict adherence to data privacy standards and completely separate this independent case study from any professional work experience, the raw membership and transactional data powering this architecture is a synthetically scaled version of a public dataset: [WSDM - KKBox's Churn Prediction Challenge](https://www.kaggle.com/competitions/kkbox-churn-prediction-challenge/data).

The raw data was structurally modified, aggregated across multiple subscription touchpoints (auto-renewals, active cancellations, plan changes, and user demographics), and scaled to simulate a massive B2C enterprise multi-cloud environment. This allowed me to rigorously stress-test the GCP + BigQuery + dbt ELT pipeline and demonstrate production-grade analytical capabilities without utilizing proprietary company data.
