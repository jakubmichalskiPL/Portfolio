-- Year-over-Year Sales Analysis
-- Purpose: Compare annual estimated sales value
-- and calculate year-over-year change.

WITH order_amount AS
  (SELECT fs.order_number,
          fs.order_date,
          ROUND(SUM(fs.quantity * dp.unit_price_usd), 2) AS price_usd
   FROM fact_sales AS fs
   JOIN dim_products AS dp ON fs.product_key = dp.product_key
   GROUP BY fs.order_number,
            fs.order_date),
     yearly_sales AS
  (SELECT EXTRACT(YEAR
                  FROM order_date) AS YEAR,
          SUM(price_usd) AS sales_amount
   FROM order_amount
   GROUP BY EXTRACT(YEAR
                    FROM order_date)),
     sales_with_previous_year AS
  (SELECT YEAR,
          sales_amount,
          LAG(sales_amount) OVER (
                                  ORDER BY YEAR) AS previous_year_amount
   FROM yearly_sales)
SELECT YEAR,
       ROUND(sales_amount, 2) AS sales_amount,
       ROUND(previous_year_amount, 2) AS previous_year_amount,
       ROUND(sales_amount - previous_year_amount, 2) AS yoy_change,
       ROUND(100.0 * (sales_amount - previous_year_amount) / NULLIF(previous_year_amount, 0), 2) AS yoy_percent
FROM sales_with_previous_year
ORDER BY YEAR;