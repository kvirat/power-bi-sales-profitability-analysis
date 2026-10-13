# Power BI Sales & Profitability Analysis

## Project Overview

This project analyzes sales data for a computer hardware business operating in a changing market. The goal is to build an interactive Power BI dashboard that helps business stakeholders monitor sales performance, understand revenue trends, and analyze profitability across markets, customers, and products.

## Business Problem

The business needs a centralized reporting solution to explore sales performance and profitability. The dashboard provides interactive insights to support data-driven business decisions.

## Dataset

The project uses a MySQL sales database containing information about:

- Sales transactions
- Customers and customer types
- Products and product categories
- Markets and regions
- Dates and sales performance

The database dump is included in the `data/` folder.

## Tools & Technologies

- **Power BI Desktop** — Dashboard development and data visualization
- **MySQL** — Data storage and querying
- **Power Query (M)** — Data connection, import, and transformation
- **Basic DAX** — Measures and business calculations

## Project Workflow

1. Connected Power BI to the MySQL sales database.
2. Imported five tables using Power Query.
3. Created a star-schema data model with one fact table and four dimension tables.
4. Developed DAX measures for revenue, sales quantity, profit margin, and contribution percentages.
5. Built interactive reports with KPI cards, charts, slicers, and drill-down functionality.
6. Added a dynamic profit target parameter to compare actual profit margins against a selected target.

## Dashboard Pages

### 1. Key Insights
- Revenue and sales quantity by market and customer type
- Monthly revenue trends
- Top customers and products
- KPI cards and date/year slicers

### 2. Profit Analysis
- Revenue contribution versus profit contribution by market
- Customer-level revenue and profit margin analysis
- Profitability contribution comparisons

### 3. Performance Insights
- Profit margin drill-down from zone to market, customer, and product
- Revenue comparison with the previous year
- Combined revenue and profit margin trend analysis

## Key Features

- Interactive filters and slicers
- Star-schema data modeling
- Basic DAX calculations
- Year-over-year revenue analysis
- Dynamic profit target analysis
- Market, customer, and product performance analysis

## How to Run the Project

1. Install MySQL Server and Power BI Desktop.
2. Import the SQL database dump from the `data/` folder into a local MySQL instance. Review the script before running it, especially if your MySQL instance already contains a database named `sales`.
3. Open the `.pbix` file from the `dashboard/` folder in Power BI Desktop.
4. If prompted, update the MySQL server, database, and authentication settings to match your local environment.
5. Refresh the data connection to load the data into the report.

## Results

Developed a three-page interactive Power BI dashboard to explore sales trends, compare market and customer performance, identify top-performing products, and analyze profitability against selected targets.

No quantified business impact or performance improvement was measured as part of this project.

## Dashboard Preview

### Key Insights
![Key Insights](screenshots/key-insights.png)

### Profit Analysis
![Profit Analysis](screenshots/profit-analysis.png)

### Performance Insights
![Performance Insights](screenshots/performance-insights.png)

## Project Structure

```text
Power-BI-Sales-Profitability-Analysis/
├── README.md
├── data/
│   └── db_dump_version_2.sql
├── dashboard/
│   └── Sales_insight_DA_Project.pbix
└── screenshots/
    └── (dashboard screenshots, optional)
```

## Author

Virat K

GitHub: https://github.com/kvirat