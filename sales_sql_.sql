-- Row Counts of all tables
USE sales;
SELECT 'transactions' AS table_name, COUNT(*) AS row_count
FROM transactions 
UNION ALL 
SELECT 'customers', COUNT(*)
FROM customers 
UNION ALL 
SELECT 'products', COUNT(*)
FROM products 
UNION ALL 
SELECT 'markets', COUNT(*)
FROM markets 
UNION ALL 
SELECT 'date', COUNT(*)
FROM date;

-- Nulls

SELECT 
    'transactions' AS table_name,
    COUNT(*) AS total_rows,
    SUM(product_code IS NULL) AS null_product_code,
    SUM(customer_code IS NULL) AS null_customer_code,
    SUM(market_code IS NULL) AS null_market_code,
    SUM(order_date IS NULL) AS null_order_date,
    SUM(sales_qty IS NULL) AS null_sales_qty,
    SUM(sales_amount IS NULL) AS null_sales_amount,
    SUM(currency IS NULL) AS null_currency
FROM
    transactions;

SELECT 
    'customers' AS table_name,
    COUNT(*) AS total_rows,
    SUM(customer_code IS NULL) AS null_customer_code,
    SUM(custmer_name IS NULL) AS null_customer_name,
    SUM(customer_type IS NULL) AS null_customer_type
FROM
    customers;

SELECT 
    'products' AS table_name,
    COUNT(*) AS total_rows,
    SUM(product_code IS NULL) AS null_product_code,
    SUM(product_type IS NULL) AS null_product_type
FROM
    products;

SELECT 
    'markets' AS table_name,
    COUNT(*) AS total_rows,
    SUM(markets_code IS NULL) AS null_market_code,
    SUM(markets_name IS NULL) AS null_market_name,
    SUM(zone IS NULL) AS null_zone
FROM
    markets;

SELECT 
    'date' AS table_name,
    COUNT(*) AS total_rows,
    SUM(`date` IS NULL) AS null_date,
    SUM(cy_date IS NULL) AS null_cy_date,
    SUM(`year` IS NULL) AS null_year,
    SUM(month_name IS NULL) AS null_month_name,
    SUM(date_yy_mmm IS NULL) AS null_date_label
FROM
    `date`;

-- Blank or whitespace-only text checks after removing CR/LF characters. 
-- method 1
SELECT 
    COUNT(*) AS total_rows,
    SUM(markets_name IS NULL
        OR TRIM(markets_name) = '') AS blank_market_name,
    SUM(zone IS NULL OR TRIM(zone) = '') AS blank_zone
FROM
    markets;

-- method 2
SELECT 
    SUM(CASE
        WHEN
            markets_name IS NULL
                OR TRIM(markets_name) = ''
        THEN
            1
        ELSE 0
    END) AS blank_market_name,
    SUM(CASE
        WHEN zone IS NULL OR TRIM(zone) = '' THEN 1
        ELSE 0
    END) AS blank_zone
FROM
    markets;

SELECT 
    COUNT(*) AS total_rows,
    SUM(customer_code IS NULL
        OR TRIM(customer_code) = '') AS blank_customer_code,
    SUM(custmer_name IS NULL
        OR TRIM(custmer_name) = '') AS blank_custmer_name
FROM
    customers;

SELECT 
    COUNT(*) AS total_rows,
    SUM(product_code IS NULL
        OR TRIM(product_code) = '') AS blank_product_code,
    SUM(product_type IS NULL
        OR TRIM(product_type) = '') AS blank_product_type
FROM
    products;


-- Inspect raw category values and their cleaned equivalents.
SELECT 
    currency AS raw_value,
    TRIM(currency) AS cleaned_value,
    COUNT(*) AS total_rows
FROM
    transactions
GROUP BY currency , TRIM(currency)
ORDER BY cleaned_value;


SELECT 
    product_type AS raw_value,
    TRIM(product_type) AS cleaned_value,
    COUNT(*) AS total_rows
FROM
    products
GROUP BY product_type , TRIM(product_type)
ORDER BY cleaned_value;


SELECT 
    TRIM(currency) AS cleaned_value,
    COUNT(*) AS transaction_rows,
    SUM(sales_qty) AS total_quantity,
    SUM(sales_amount) AS total_sales_amount
FROM
    transactions
GROUP BY cleaned_value
ORDER BY cleaned_value;
 
 -- Transaction date coverage and date-dimension coverage.
SELECT 
    MIN(order_date) AS first_transaction_date,
    MAX(order_date) AS last_transaction_date,
    COUNT(*) AS transaction_rows,
    COUNT(DISTINCT (order_Date)) AS distinct_order_Date
FROM
    transactions;

SELECT 
    MIN(date) AS first_calender_date,
    MAX(date) AS last_calender_date,
    COUNT(*) AS calender_rows,
    COUNT(DISTINCT (date)) AS distinct_calender_date
FROM
    date;

-- Numeric anomalies
SELECT 
    *
FROM
    sales.transactions
LIMIT 5;
SELECT 
    SUM(sales_qty < 0) AS negative_sales_qty,
    SUM(sales_qty = 0) AS zero_sales_qty,
    SUM(sales_amount < 0) AS negative_sales_amount,
    SUM(sales_amount = 0) AS zero_sales_amount,
    SUM(sales_qty < 0) AS negative_sales_qty,
    MIN(sales_qty) AS minimum_sales_qty,
    MAX(sales_qty) AS maximum_sales_qty,
    MIN(sales_amount) AS minimum_sales_amount,
    MAX(sales_amount) AS maximum_sales_amount
FROM
    transactions;

SELECT 
    product_code,
    customer_code,
    market_code,
    order_date,
    sales_qty,
    sales_amount,
    TRIM(currency) AS currency_clean
FROM
    transactions
WHERE
    sales_qty <= 0 OR sales_amount <= 0
ORDER BY sales_amount , order_date;

-- Duplicate candidates AFTER normalizing currency text.
WITH normalized_transactions AS (
    SELECT
        product_code,
        customer_code,
        market_code,
        order_date,
        sales_qty,
        sales_amount,
        TRIM(REPLACE(
					REPLACE(currency, CHAR(13), ''), --  removes \r, a hidden carriage-return character.
                    CHAR(10), '')					-- removes \n, a hidden line-break character.
                    ) 
                    AS currency_clean,  -- removes the carriage return values from the currency column
        COUNT(*) AS occurrence_count 	-- count of identical transactions
    FROM transactions
    GROUP BY
        product_code,
        customer_code,
        market_code,
        order_date,
        sales_qty,
        sales_amount,
        TRIM(
			REPLACE(
            REPLACE(currency, CHAR(13), ''), 
					CHAR(10), '')
            )   
    HAVING COUNT(*) > 1
)
SELECT
    COUNT(*) AS duplicate_groups,
    SUM(occurrence_count - 1) AS excess_candidate_rows
FROM normalized_transactions;

-- Review individual duplicate groups.
SELECT 
    product_code,
    customer_code,
    market_code,
    order_date,
    sales_qty,
    sales_amount,
    TRIM(REPLACE(REPLACE(currency, CHAR(13), ''),
            CHAR(10),
            '')) AS currency_clean,
    COUNT(*) AS occurrences
FROM
    transactions
GROUP BY product_code , customer_code , market_code , order_date , sales_qty , sales_amount , TRIM(REPLACE(REPLACE(currency, CHAR(13), ''),
        CHAR(10),
        ''))
HAVING COUNT(*) > 1
ORDER BY occurrences DESC , order_date;

/*
-- Referential integrity: transaction product codes missing from products.
How many transaction records refer to missing products?
How many different product codes are missing?
How much sales amount is associated with those records?
*/

SELECT 
    COUNT(*) AS unmatched_transaction_rows,
    COUNT(DISTINCT t.product_code) AS distinct_missing_product_codes,
    SUM(t.sales_amount) AS associated_sales_amount
FROM
    transactions t
        LEFT JOIN
    products p ON t.product_code = p.product_code
WHERE
    p.product_code IS NULL;

SELECT 
    t.product_code,
    COUNT(*) AS transaction_rows,
    SUM(t.sales_qty) AS total_quantity,
    SUM(t.sales_amount) AS sales_amount
FROM
    transactions t
        LEFT JOIN
    products p ON t.product_code = p.product_code
WHERE
    p.product_code IS NULL
GROUP BY t.product_code
ORDER BY transaction_rows DESC;

/* Check unmatched customers, markets, and transaction dates. */

SELECT 
    COUNT(*) AS transactions_with_unmatched_customer
FROM
    transactions t
        LEFT JOIN
    customers c ON t.customer_code = c.customer_code
WHERE
    c.customer_code IS NULL;

SELECT 
    COUNT(*) AS transactions_with_unmatched_market
FROM
    transactions t
        LEFT JOIN
    markets m ON t.market_code = m.markets_code
WHERE
    m.markets_code IS NULL;

SELECT 
    COUNT(*) AS transactions_with_unmatched_date
FROM
    transactions t
        LEFT JOIN
    date d ON t.order_date = d.date
WHERE
    d.date IS NULL;

/* Market dimension checks: blank zones, repeated city labels, unused market codes. */
SELECT 
    *
FROM
    markets
WHERE
    TRIM(REPLACE(REPLACE(COALESCE(zone, ''),
                CHAR(13),
                ''),
            CHAR(10),
            '')) = '';
/* COALESCE(zone, '') This means:
- If zone contains a value, keep that value.
- If zone is NULL, replace it with an empty string ('').
*/

SELECT 
    TRIM(REPLACE(REPLACE(markets_name, CHAR(13), ''),
            CHAR(10),
            '')) AS market_name_clean,
    COUNT(*) AS market_code_count,
    GROUP_CONCAT(markets_code
        ORDER BY markets_code) AS market_codes
FROM
    markets
GROUP BY market_name_clean
HAVING COUNT(*) > 1;
-- GROUP_CONCAT() joins several values from different rows into one text value.


SELECT 
    *
FROM
    markets m
        LEFT JOIN
    transactions t ON m.markets_code = t.market_code
WHERE
    t.market_code IS NULL
ORDER BY m.markets_code;

/* Date dimension consistency checks. */
SELECT 
    SUM(`year` <> YEAR(`date`)) AS year_mismatch_rows,
    SUM(month_name <> MONTHNAME(`date`)) AS month_name_mismatch_rows,
    SUM(cy_date <> DATE_SUB(`date`,
        INTERVAL DAYOFMONTH(`date`) - 1 DAY)) AS calendar_month_start_mismatch_rows
FROM
    date;

/* Review unusually large transaction records; high values are not automatically errors. */

SELECT 
    product_code,
    customer_code,
    market_code,
    order_date,
    sales_qty,
    sales_amount,
    CASE
        WHEN sales_qty > 0 THEN ROUND(sales_amount / sales_qty, 2)
        ELSE NULL
    END AS sales_amount_per_unit,
    TRIM(REPLACE(REPLACE(currency, CHAR(13), ''),
            CHAR(10),
            '')) AS currency_clean
FROM
    transactions
ORDER BY sales_amount DESC
LIMIT 20;
        
SELECT 
    product_code,
    customer_code,
    market_code,
    order_date,
    sales_qty,
    sales_amount,
    TRIM(REPLACE(REPLACE(currency, CHAR(13), ''),
            CHAR(10),
            '')) AS currency_clean
FROM
    transactions
ORDER BY sales_qty DESC
LIMIT 20;











