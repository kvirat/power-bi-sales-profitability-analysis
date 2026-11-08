USE sales;
/* --------------------------------------------------------------------------
   SECTION 1: DATA PREVIEW
   Quick look at the first 5 rows of each table to understand the columns
   and the kind of values stored in them.
   -------------------------------------------------------------------------- */
SELECT * FROM sales.customers limit 5;
SELECT * FROM sales.date limit 5;
SELECT * FROM sales.markets limit 5;
SELECT * FROM sales.transactions limit 5;
SELECT * FROM sales.products limit 5;


/* --------------------------------------------------------------------------
   SECTION 2: BASIC ROW COUNTS
   Sanity checks on the size of each table.
   -------------------------------------------------------------------------- */

-- Total count of transaction 
SELECT count(*) as no_of_transactions FROM sales.transactions;

-- Total number of customers
select count(*) as num_of_customers from sales.customers;

-- Total number of markets
SELECT count(*) as num_of_markets FROM sales.markets;

-- Total number of products
SELECT count(*) as num_of_products FROM sales.products;


/* --------------------------------------------------------------------------
   SECTION 3: FILTERING & TIME-BASED REVENUE
   -------------------------------------------------------------------------- */

-- Show transactions for Chennai market (market code for chennai is Mark001)
-- Simple filter on market_code; no join needed because the code is already in transactions.
SELECT * FROM sales.transactions where market_code='Mark001';

-- Show transactions in 2020 join by date table
-- transactions only has the order_date, so we join to the date table
-- to get the year and then filter on year = 2020.
select t.*, d.year from transactions t
inner join date d on t.order_date = d.date
where d.year = 2020;

-- Show total revenue group by year
-- Revenue per transaction = quantity * amount; summed for each calendar year.
select d.year, sum(t.sales_qty * t.sales_amount) as total_revenue 
from transactions t
inner join date d on t.order_date = d.date
group by d.year;


/* --------------------------------------------------------------------------
   SECTION 4: MARKET-LEVEL ANALYSIS
   -------------------------------------------------------------------------- */

-- Show total revenue by market
-- Joins to markets to get readable market names; sorted so the
-- highest-revenue market appears first.
select m.markets_name, sum(t.sales_qty * t.sales_amount) as revenue 
from transactions t
inner join markets m on t.market_code = m.markets_code
group by m.markets_name
order by revenue desc;

-- Districution of currency 
-- Counts transactions per currency value. The value is wrapped in square
-- brackets so that hidden characters (spaces, \r, \n) become visible,
-- which helps detect dirty currency values such as 'INR\r' vs 'INR'.
SELECT CONCAT('[',currency,']') AS raw_currency, 
		count(*) as no_of_transactions FROM sales.transactions
GROUP BY sales.transactions.currency;


/*Retrieves transaction-level sales information along with product type, market name, and zone, 
creating a dataset for market-wise and product-wise sales analysis. */
-- Inner joins mean transactions whose product or market is missing from the
-- lookup tables will be excluded from this result.
SELECT 
    t.product_code,
    t.customer_code,
    t.market_code,
    t.order_date,
    t.sales_qty,
    t.sales_amount,
    p.product_type,
    m.markets_name,
    m.zone
FROM transactions t
INNER JOIN products p 
    ON t.product_code = p.product_code
INNER JOIN markets m 
    ON t.market_code = m.markets_code;


/* --------------------------------------------------------------------------
   SECTION 5: PRODUCT PERFORMANCE
   -------------------------------------------------------------------------- */

-- average transaction sales amount and total revenue for each product category annually
-- AVG(sales_amount) = typical value of a single transaction (rounded to 2 decimals).
-- SUM(qty * amount) = total revenue for the product type in that year.
-- Grouped by product type and year; ordered by year for easy trend reading.
SELECT 
    p.product_type,
    d.year,
    ROUND(AVG(sales_amount), 2) AS average_sales_amount,
    sum(t.sales_qty * t.sales_amount) AS revenue
FROM
    transactions t
        INNER JOIN
    products p ON t.product_code = p.product_code
        INNER JOIN
    date d ON t.order_date = d.date
GROUP BY p.product_type , d.year
ORDER BY d.year;


/* --------------------------------------------------------------------------
   SECTION 6: MARKET TOTALS WITH CURRENCY CLEANING
   -------------------------------------------------------------------------- */

-- Total sales and total amount by markets
-- Currency text can contain carriage-return (CHAR(13)) / line-feed (CHAR(10))
-- characters from the source file, so they are stripped and the value trimmed.
-- Grouping by the cleaned currency keeps 'INR' and 'INR\r' from being treated
-- as separate groups.
-- total_qty    = total units sold
-- total_amount = sum of sales_amount (NOT multiplied by quantity here)
SELECT
    m.markets_code,
    m.markets_name,
    TRIM(
        REPLACE(
            REPLACE(t.currency, CHAR(13), ''),
            CHAR(10), ''
        )
    ) AS currency_clean,
    SUM(t.sales_qty) AS total_qty,
    SUM(t.sales_amount) AS total_amount
FROM transactions t
INNER JOIN markets m
    ON t.market_code = m.markets_code
GROUP BY
    m.markets_code,
    m.markets_name,
    currency_clean
ORDER BY total_amount DESC;


/* --------------------------------------------------------------------------
   SECTION 7: ZONE-LEVEL ANALYSIS
   -------------------------------------------------------------------------- */

-- Total revenue by zone (zones group multiple markets together)
select m.zone, SUM(t.sales_qty * t.sales_amount) AS total_revenue 
from transactions t
inner join markets m on t.market_code = m.markets_code
group by m.zone
order by total_revenue desc;

-- Total revenue by zone and product type
-- Shows which product categories perform best in each zone.
select p.product_type, m.zone, 
		SUM(t.sales_qty * t.sales_amount) AS total_revenue 
from transactions t
inner join markets m on t.market_code = m.markets_code
INNER JOIN products p ON t.product_code = p.product_code
group by m.zone, p.product_type
order by total_revenue desc;


/* --------------------------------------------------------------------------
   SECTION 8: CUSTOMER ANALYSIS
   Note: the column is spelled "custmer_name" in the customers table,
   so the queries below use that exact spelling.
   -------------------------------------------------------------------------- */

-- Total revenue by customer, with their type and zone
-- Useful for identifying top customers within each zone.
select c.custmer_name, c.customer_type, 
		m.zone, SUM(t.sales_qty * t.sales_amount) AS total_revenue 
from transactions t
inner join customers c on t.customer_code = c.customer_code
inner join markets m on t.market_code = m.markets_code
group by c.custmer_name, c.customer_type, m.zone
order by total_revenue desc;

-- Total revenue by customer type
-- Compares customer segments (e.g. Brick & Mortar vs E-Commerce).
select c.customer_type, SUM(t.sales_qty * t.sales_amount) AS total_revenue 
from transactions t
inner join customers c on t.customer_code = c.customer_code
group by c.customer_type
order by total_revenue desc;

-- Total revenue by individual customer (top customers first)
select c.custmer_name, SUM(t.sales_qty * t.sales_amount) AS total_revenue from transactions t
inner join customers c on t.customer_code = c.customer_code
group by c.custmer_name
order by total_revenue desc;

-- Total revenue by customer type and zone
-- Shows which customer segment performs best in which zone.
select c.customer_type, m.zone, 
		SUM(t.sales_qty * t.sales_amount) AS total_revenue 
from transactions t
inner join customers c on t.customer_code = c.customer_code
inner join markets m on t.market_code = m.markets_code
group by c.customer_type, m.zone
order by total_revenue desc;


/* --------------------------------------------------------------------------
   SECTION 9: MONTHLY TREND & CUSTOMER-TYPE TREND
   -------------------------------------------------------------------------- */

-- Re-check of the transactions table structure
select * from transactions limit 5;

-- Monthly revenue trend
-- date_yy_mmm is a year-month label from the date table, so sorting by it
-- gives a chronological monthly view; month_name is included for readability.
select d.date_yy_mmm as year_month_, d.month_name, SUM(t.sales_qty * t.sales_amount) AS total_revenue 
from transactions t
inner join date d on t.order_date = d.date
group by d.month_name, d.date_yy_mmm
order by d.date_yy_mmm asc, total_revenue desc;


-- Yearly revenue by customer type and zone
-- Combines three dimensions (customer type, zone, year) to show how each
-- segment/zone combination grows over time. Ordered by customer type,
-- then year (oldest first), then highest revenue within that year.
SELECT
    c.customer_type,
    m.zone,
    d.year,
    SUM(t.sales_qty * t.sales_amount) AS total_revenue
FROM transactions t
INNER JOIN customers c ON t.customer_code = c.customer_code
INNER JOIN markets m ON t.market_code = m.markets_code
INNER JOIN date d ON t.order_date = d.date
GROUP BY
    c.customer_type,
    m.zone,
    d.year
ORDER BY
	c.customer_type,
    d.year ASC,
    total_revenue DESC;