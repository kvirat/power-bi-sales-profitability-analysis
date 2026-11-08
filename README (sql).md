# Sales Data Analysis with SQL

SQL scripts for profiling, cleaning-checks, and analysing a sales database (`sales`) in **MySQL**. The project is split into two stages: first validate the data, then answer business questions with it.

## Repository Structure

```
.
├── sql/
│   ├── 01_data_quality_checks.sql   # profiling & validation
│   └── 02_sales_analysis.sql        # business analysis queries
└── README.md
```

## Database Schema

The `sales` database has one fact table and four dimension tables.

| Table | Type | Key columns |
|---|---|---|
| `transactions` | Fact | `product_code`, `customer_code`, `market_code`, `order_date`, `sales_qty`, `sales_amount`, `currency` |
| `customers` | Dimension | `customer_code`, `custmer_name`*, `customer_type` |
| `products` | Dimension | `product_code`, `product_type` |
| `markets` | Dimension | `markets_code`, `markets_name`, `zone` |
| `date` | Dimension | `date`, `cy_date`, `year`, `month_name`, `date_yy_mmm` |

\* The column name is spelled `custmer_name` in the source table, so the queries use that exact spelling.

**Joins:** `transactions.product_code → products.product_code`, `transactions.customer_code → customers.customer_code`, `transactions.market_code → markets.markets_code`, `transactions.order_date → date.date`.

## Script 1: `01_data_quality_checks.sql`

Profiles the data before any analysis is done:

- **Row counts** for every table
- **NULL checks** across all columns in all tables
- **Blank / whitespace-only values** in text columns
- **Hidden characters** (`\r`, `\n`) in `currency`, and cleaned-vs-raw comparisons
- **Date coverage** of transactions vs. the date dimension
- **Numeric anomalies:** negative or zero quantities and amounts, min/max values
- **Duplicate detection** after normalising currency text
- **Referential integrity:** transactions pointing to missing products, customers, markets, or dates
- **Market dimension checks:** blank zones, repeated market names, unused market codes
- **Date dimension consistency:** year, month name, and month-start columns vs. the actual date
- **Outlier review:** top 20 transactions by amount and by quantity

## Script 2: `02_sales_analysis.sql`

Business analysis built on the validated data:

| Section | What it answers |
|---|---|
| Data preview & row counts | What does each table look like and how big is it? |
| Filtering & time-based revenue | Chennai transactions, 2020 transactions, revenue by year |
| Market-level analysis | Revenue by market, currency distribution, product/market/zone dataset |
| Product performance | Average sale and revenue per product type per year |
| Market totals with currency cleaning | Quantity and amount by market and cleaned currency |
| Zone-level analysis | Revenue by zone, and by zone × product type |
| Customer analysis | Revenue by customer, customer type, and customer type × zone |
| Trends | Monthly revenue trend, yearly revenue by customer type and zone |

## How to Run

1. Load the `sales` database into MySQL (MySQL 8.x recommended).
2. Open the scripts in MySQL Workbench, DBeaver, or the `mysql` CLI.
3. Run `01_data_quality_checks.sql` first and review the results.
4. Run `02_sales_analysis.sql` section by section.

```bash
mysql -u <user> -p < sql/01_data_quality_checks.sql
mysql -u <user> -p < sql/02_sales_analysis.sql
```

## SQL Concepts Used

`INNER JOIN` / `LEFT JOIN` anti-joins, CTEs, `GROUP BY` with `HAVING`, conditional aggregation (`SUM(condition)`, `CASE`), string cleaning (`TRIM`, `REPLACE`, `CHAR(13)`, `CHAR(10)`), `COALESCE`, `GROUP_CONCAT`, date functions (`YEAR`, `MONTHNAME`, `DATE_SUB`).

## Notes & Things to Verify

- **Revenue definition:** the analysis script calculates revenue as `sales_qty * sales_amount`, but the market totals section sums `sales_amount` on its own. Confirm whether `sales_amount` is a per-unit price or already a line total. If it is already the total, the `qty * amount` revenue figures are overstated.
- **Mixed currencies:** `transactions.currency` can hold more than one currency (and values with hidden `\r` characters). Revenue queries that don't group by or convert currency add different currencies together.
- **Unmatched keys:** `INNER JOIN`s drop transactions whose product, customer, or market is missing from the dimension tables. Check the referential-integrity results in script 1 to see how much is affected.

## Author

Your Name · [GitHub](https://github.com/your-username)
