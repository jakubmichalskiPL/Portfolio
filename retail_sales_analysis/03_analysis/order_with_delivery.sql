-- Orders with delivery
-- Purpose: Data exploration
-- Question: Are orders with delivery associated
-- exclusively with online sales?

WITH orders AS (
	SELECT
		DISTINCT order_number,
		delivery_date,
		country
	FROM fact_sales fs
	JOIN dim_stores ds
	ON ds.store_key = fs.store_key
)
SELECT
    country,
    SUM(CASE WHEN delivery_date IS NOT NULL THEN 1 ELSE 0 END) AS orders_with_delivery
FROM orders
GROUP BY country
ORDER BY orders_with_delivery DESC;