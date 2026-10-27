
-- Consecutive Customer Purchase Years (Gaps and Islands)
-- Purpose: Identify customers who made purchases in at least
-- three consecutive years, ending in the latest available year (2021).


WITH customer_years AS (
    SELECT DISTINCT
        dc.customer_key,
        dc.name,
        EXTRACT(YEAR FROM fs.order_date) AS order_year
    FROM dim_customers AS dc
    JOIN fact_sales AS fs
        ON dc.customer_key = fs.customer_key
),
customer_year_sequences AS (
    SELECT
        customer_key,
        name,
        order_year,
        order_year - ROW_NUMBER() OVER (
            PARTITION BY customer_key
            ORDER BY order_year
        ) AS series_group
    FROM customer_years
)
SELECT
    customer_key,
    name,
    MIN(order_year) AS island_start,
    MAX(order_year) AS island_end,
    COUNT(*) AS consecutive_years
FROM customer_year_sequences
GROUP BY
    customer_key,
    name,
    series_group
HAVING
    MAX(order_year) = 2021
    AND COUNT(*) >= 3
ORDER BY consecutive_years DESC;
