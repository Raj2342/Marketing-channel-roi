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

1. **The Revenue Contribution (Who is actually paying the bills?):** 
   * Calculated the Average Net Revenue Per User (ANRPU) mapped to their specific registration channel[cite: 1]. 
   * To identify heavy discount leakage, the model subtracts the `plan_list_price` from the `actual_amount_paid` rather than just summing the total revenue[cite: 1].
2. **The "Survival" Analysis (Active Life of a User):** 
   * Calculated the Mean Tenure in days per channel by extracting the `registration_init_time` from the members table and the maximum `membership_expire_date` from the transactions table[cite: 1]. 
   * *Data Governance Note:* Churn is strictly defined as having no new valid service subscription within 30 days after the current membership expires[cite: 1]. The `is_cancel` flag indicates an active user cancellation (often just a plan change), which does not inherently mean the user has churned[cite: 1].
3. **The "Discount Trap" Analysis (Serial Churners):** 
   * Engineered an `is_discounted` flag to isolate transactions where `actual_amount_paid` is less than the `plan_list_price`[cite: 1]. 
   * Calculated the 30-Day Churn Rate comparing discounted users vs. full-price users within each channel to prove which channels are artificially inflated by promo-abusers[cite: 1].
4. **The Payment Friction Analysis:** 
   * Mapped the `registered_via` source to the `payment_method_id` to identify the "Golden Path"[cite: 1]. 
   * This determines if specific combinations (e.g., mobile registration leading to high-churn In-App Purchases vs. Credit Card Auto-Renew) result in the highest ultimate LTV[cite: 1].
5. **The CAC Payback Proxy:** 
   * Built a "What-If" parameter model allowing stakeholders to input an Estimated CAC for different channels[cite: 1]. 
   * The logic dynamically calculates the "Months to Payback" to show exactly when a user from a specific channel breaks even and becomes profitable[cite: 1].

---

## 📊 Final Deliverable: 3-Page Power BI Blueprint

The final analytical models were connected to Power BI to deliver a structured, 3-page dashboard catering to different layers of the business conversation: Executive (The Money), Diagnostic (The Behavior), and Strategic (The ROI)[cite: 1]. 

* **Page 1: Channel Profitability** 
  * Features a Heatmap analyzing Channel vs. Revenue, driven by the core Lifetime Value (LTV) metric[cite: 1].
* **Page 2: Retention Health & Survival** 
  * Features Cohort Analysis tracking Monthly Retention, highlighting the overall retention percentage at Month 6[cite: 1]. Includes a Kaplan-Meier survival curve showing the percentage of users still active over time split by channel[cite: 1].
* **Page 3: Discount Impact & Strategy** 
  * Features a Dual-Axis Chart comparing Discount % vs. Churn Rate to track Revenue Leakage[cite: 1].
  * Concludes with a Strategic "Winner" Leaderboard ranking channels strictly by their LTV to Estimated CAC Ratio[cite: 1].
