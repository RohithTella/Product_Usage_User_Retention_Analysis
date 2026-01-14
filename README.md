# Product_Usage_User_Retention_Analysis
Product usage and user retention analysis on ~1M ecommerce transactions using Excel, MySQL SQL, and Power BI with KPI dashboard and cohort retention heatmap.

## Overview
Product Usage and User Retention Analysis on the Online Retail II dataset (transaction-level ecommerce data). Cleaned ~1 million rows in Excel, loaded into MySQL for KPI reporting, and built an interactive Power BI dashboard to track revenue, orders, monthly active customers, repeat purchases, and cohort retention trends.

## Business Questions
- What is the total revenue, total orders, and unique customers?
- How does revenue change month by month?
- How many monthly active customers are there?
- How many new vs returning customers each month?
- What is the repeat purchase rate?
- Which products generate the highest revenue?
- Which countries contribute most to revenue and customers?
- What does customer retention look like using cohort analysis?

## Key Insights
- Repeat customers contribute a major share of buyers (around 72 percent repeat rate).
- Monthly revenue shows clear seasonality with peak and low periods.
- A small set of products contributes the highest share of revenue.
- United Kingdom generates the highest revenue and customer base.
- Cohort retention heatmap shows drop-off after first month and stable repeat customer groups.

## Tech Stack
Excel, MySQL Workbench SQL, Power BI, GitHub

## How to Use
1. Open Power BI dashboard: `powerbi/product_usage_retention_dashboard.pbix`
2. Use slicers (InvoiceYear, InvoiceMonth, Country) to explore trends.
3. SQL queries are available in: `sql/product_usage_kpi_queries.sql`
4. Cleaned dataset is available in: `data/product_usage_cleaned.csv`

## Screenshots
Dashboard:
- `screenshots/dashboard_main.png`