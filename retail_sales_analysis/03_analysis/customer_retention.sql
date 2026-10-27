
-- Year-over-Year Customer Retention
-- Purpose: Calculate annual customer retention rates by measuring
-- the percentage of customers who make a purchase in the following year.
-- Note: Retention for the latest available year is not calculated
-- because data for the following year is unavailable.


WITH customer_years AS
  (SELECT DISTINCT customer_key,
                   EXTRACT(YEAR
                           FROM order_date) AS order_year
   FROM fact_sales),
     customer_returns AS
  (SELECT c1.customer_key,
          c1.order_year AS current_year,
          c2.customer_key AS returned_customer
   FROM customer_years AS c1
   LEFT JOIN customer_years AS c2 ON c1.customer_key = c2.customer_key
   AND c1.order_year + 1 = c2.order_year),
     yearly_retention AS
  (SELECT current_year,
          COUNT(customer_key) AS current_year_customers,
          COUNT(returned_customer) AS retained_customers
   FROM customer_returns
   GROUP BY current_year),
     retention_with_latest_year AS
  (SELECT *,
          MAX(current_year) OVER () AS latest_year
   FROM yearly_retention)
SELECT current_year,
       current_year_customers,
       CASE
           WHEN current_year = latest_year THEN NULL
           ELSE retained_customers
       END AS retained_customers,
       CASE
           WHEN current_year = latest_year THEN NULL
           ELSE ROUND(100.0 * retained_customers / NULLIF(current_year_customers, 0), 1)
       END AS retention_rate_pct
FROM retention_with_latest_year
ORDER BY current_year;