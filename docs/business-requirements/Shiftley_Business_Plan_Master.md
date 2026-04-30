# Shiftley: Unified Financial & Operational Blueprint

This document provides a single, consolidated view of Shiftley's economics, including revenue streams, operational expenses, and profitability targets.

---

## 1. The Unified Financial Master Table (INR)

This table summarizes both the **Income Potential** and **Operational Expenses** across two growth phases.

| Category | Item | Startup (0-10k Users) | Scale (10k-100k Users) |
| :--- | :--- | :--- | :--- |
| **INCOME (Monthly)** | **Employer Subscriptions** | ₹1,50,000 (100 Subs) | ₹15,00,000 (1,000 Subs) |
| | **Marketplace Fee** | ₹0 (Zero-Fee Model) | ₹0 (Zero-Fee Model) |
| | **Accountability Fines** | ₹5,000 | ₹75,000 |
| | **TOTAL REVENUE** | **₹1,55,000** | **₹15,75,000** |
| --- | --- | --- | --- |
| **EXPENSES (Monthly)** | **Cloud Compute (Go/AWS)**| ₹1,250 | ₹6,680 |
| | **Database (Postgres)** | ₹2,090 | ₹12,500 |
| | **Cache & Session** | ₹1,250 | ₹3,760 |
| | **ALB & Networking** | ₹1,920 | ₹5,680 |
| | **WhatsApp & Manual KYC** | ₹1,500 | ₹15,000 |
| | **Razorpay Fee (Absorbed)** | ₹24,000 | ₹3,60,000 |
| | **TOTAL EXPENSES** | **₹32,010** | **₹4,03,620** |
| --- | --- | --- | --- |
| **NET RESULT** | **Monthly EBITDA** | **+₹1,22,990** | **+₹11,71,380** |

---

## 2. Business Logic Clarifications

### Local KYC & WhatsApp Strategy
To minimize burn and ensure high-trust verification, Shiftley uses a **Local/Manual KYC** model.
*   **KYC (Identity)**: Instead of paying ₹25 per Aadhaar check, workers upload their documents, and our **Internal Verifiers** (Staff) approve them via the admin dashboard. Tech cost = **₹0**.
*   **WhatsApp Communication**: We use the WhatsApp Business API for all OTPs and notifications. At ~₹0.35 per message, this is 60% cheaper than traditional SMS gateways.

### The "Zero-Fee" Marketplace Model
We have opted for a **Zero Marketplace Fee** strategy to maximize adoption and disrupt traditional staffing agencies.
*   **Revenue Source**: Income is derived exclusively from **Employer Subscriptions** (SaaS model).
*   **Cost Absorption**: The **2% Razorpay processing fee** is absorbed by the platform from the subscription revenue.

---

## 3. Break-Even & Profitability Logic

### The "Subscription-First" Break-Even
*   **Monthly Operating Expense**: ~₹32,000 (Including absorbed transaction fees).
*   **Subscription Price**: ₹1,499 / mo.
*   **Break-Even Point**: **~22 Active Monthly Subscribers**.
*   *Interpretation: You only need 22 paying businesses across the entire platform to cover all technical and communication overhead.*

---

## 4. Valuation & Market Potential

| Stage | Milestone | Estimated Valuation (INR) |
| :--- | :--- | :--- |
| **Pre-Seed (Current)** | Go-Backend + Flutter MVP | **₹2 Cr - ₹4 Cr** |
| **Seed** | 500 Active Employers | **₹15 Cr - ₹25 Cr** |
| **Series A** | 10k Monthly Gigs | **₹100 Cr+** |

---

## 5. Strategic Exit Targets

Shiftley is an ideal acquisition target for:
1.  **Zomato / Swiggy**: To solve blue-collar staff shortages.
2.  **Razorpay / PayU**: To integrate high-frequency payroll engines.
3.  **Urban Company**: To expand beyond home services into retail staffing.
