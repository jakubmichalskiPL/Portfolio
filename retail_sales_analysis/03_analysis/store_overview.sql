
-- Store Sales Performance
-- Purpose: Compare stores by size, order volume, customer count,
-- employee count, and order value statistics.

 WITH orders_amount AS
  (SELECT fs.order_number,
          fs.store_key,
          ROUND(SUM(fs.quantity * dp.unit_price_usd), 2) AS price_usd
   FROM fact_sales AS fs
   JOIN dim_products AS dp ON fs.product_key = dp.product_key
   GROUP BY fs.order_number,
            fs.store_key),
      stats_for_store AS
  (SELECT oa.store_key,
          ROUND(AVG(oa.price_usd), 2) AS avg_order_amount,
          ROUND(MAX(oa.price_usd), 2) AS max_order_amount,
          ROUND(MIN(oa.price_usd), 2) AS min_order_amount,
          ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP (
                                                    ORDER BY oa.price_usd))::numeric, 2) AS median_order_amount
   FROM orders_amount AS oa
   GROUP BY oa.store_key),
      sales_by_store AS
  (SELECT fs.store_key,
          COUNT(DISTINCT fs.order_number) AS all_time_orders,
          COUNT(DISTINCT fs.customer_key) AS customers
   FROM fact_sales AS fs
   GROUP BY fs.store_key),
      employees_by_store AS
  (SELECT de.store_key,
          COUNT(*) AS employees
   FROM dim_employees AS de
   GROUP BY de.store_key)
SELECT ds.store_key,
       ds.country,
       ds.state,
       ds.square_meters,
       ROUND(AVG(ds.square_meters) OVER (PARTITION BY ds.country), 0) AS avg_area_in_country,
       COUNT(*) OVER (PARTITION BY ds.country) AS stores_in_country,
       COALESCE(s.all_time_orders, 0) AS all_time_orders,
       ss.avg_order_amount,
       ss.median_order_amount,
       ss.max_order_amount,
       ss.min_order_amount,
       COALESCE(e.employees, 0) AS employees,
       COALESCE(s.customers, 0) AS customers,
       ds.open_date
FROM dim_stores AS ds
LEFT JOIN sales_by_store AS s ON ds.store_key = s.store_key
LEFT JOIN employees_by_store AS e ON ds.store_key = e.store_key
LEFT JOIN stats_for_store AS ss ON ds.store_key = ss.store_key
ORDER BY ds.store_key;