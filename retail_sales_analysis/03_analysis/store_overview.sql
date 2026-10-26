-- Store Overview
-- Purpose: Compare stores by area, orders, customers,
-- employee count, and average store area by country.

WITH sales_by_store AS (
    SELECT
        store_key,
        COUNT(DISTINCT order_number) AS all_time_orders,
        COUNT(DISTINCT customer_key) AS customers
    FROM fact_sales
    GROUP BY store_key
),
employees_by_store AS (
    SELECT
        store_key,
        COUNT(*) AS employees
    FROM dim_employees
    GROUP BY store_key
)
SELECT
    ds.store_key,
    ds.country,
    ds.state,
    ds.square_meters,
    ROUND(AVG(ds.square_meters) OVER (PARTITION BY ds.country),0) AS avg_area_in_country,
    COUNT(*) OVER (PARTITION BY ds.country) AS stores_in_country,
    COALESCE(s.all_time_orders, 0) AS all_time_orders,
    COALESCE(e.employees, 0) AS employees,
    COALESCE(s.customers, 0) AS customers,
    ds.open_date
FROM dim_stores ds
LEFT JOIN sales_by_store s
    ON ds.store_key = s.store_key
LEFT JOIN employees_by_store e
    ON ds.store_key = e.store_key
ORDER BY ds.store_key;
