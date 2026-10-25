# CREATING TABLES

CREATE TABLE dim_customer (
    customer_key INTEGER PRIMARY KEY,
    gender       VARCHAR(20),
    name         VARCHAR(100),
    city         VARCHAR(100),
    state_code   VARCHAR(10),
    state        VARCHAR(100),
    zip_code     VARCHAR(20),
    country      VARCHAR(100),
    continent    VARCHAR(50),
    birthday     DATE
);

CREATE TABLE dim_stores (
    store_key     INTEGER PRIMARY KEY,
    country       VARCHAR(100),
    state         VARCHAR(100),
    square_meters INTEGER,
    open_date     DATE
);

CREATE TABLE dim_products (
    product_key   INTEGER PRIMARY KEY,
    product_name  VARCHAR(200),
    unit_cost_usd NUMERIC(12, 2),
    unit_price_usd NUMERIC(12, 2),
    category_key  INTEGER
);


CREATE TABLE dim_exchange_rates (
	date         DATE NOT NULL,
	currency     VARCHAR(3) NOT NULL,
    	exchange     NUMERIC(18, 6) NOT NULL,
	exchange_key VARCHAR(14) PRIMARY KEY,
    CONSTRAINT uq_exchange_date_currency UNIQUE (date, currency)
);

CREATE TABLE fact_sales (
    order_number  BIGINT NOT NULL,
    line_item     INTEGER NOT NULL,
    order_date    DATE NOT NULL,
    delivery_date DATE,
    customer_key  INTEGER NOT NULL,
    store_key     INTEGER NOT NULL,
    product_key   INTEGER NOT NULL,
    quantity      INTEGER NOT NULL,
    currency      VARCHAR(3) NOT NULL,
    exchange_key  VARCHAR(14),

    CONSTRAINT pk_fact_sales
        PRIMARY KEY (order_number, line_item),

    CONSTRAINT fk_sales_customer
        FOREIGN KEY (customer_key)
        REFERENCES dim_customers (customer_key),

    CONSTRAINT fk_sales_store
        FOREIGN KEY (store_key)
        REFERENCES dim_stores (store_key),

    CONSTRAINT fk_sales_product
        FOREIGN KEY (product_key)
        REFERENCES dim_products (product_key),

    CONSTRAINT fk_sales_exchange
        FOREIGN KEY (exchange_key)
        REFERENCES dim_exchange_rates (exchange_key)
);


CREATE TABLE dim_employees (
    employee_key INTEGER PRIMARY KEY,
    name         VARCHAR(150) NOT NULL,
    store_key    INTEGER NOT NULL,
    manager_key  INTEGER,

    CONSTRAINT fk_employees_store
        FOREIGN KEY (store_key)
        REFERENCES dim_stores(store_key),

    CONSTRAINT fk_employees_manager
        FOREIGN KEY (manager_key)
        REFERENCES dim_employees(employee_key),

    CONSTRAINT chk_employee_not_own_manager
        CHECK (manager_key IS NULL OR manager_key <> employee_key)
);

# GENERATING DATA FOR DIM_EMPLOYEES:


WITH store_counts AS (
    SELECT
        store_key,
        (store_key % 4) + 1 AS employee_count
    FROM generate_series(0, 66) AS store_key
),
employee_rows AS (
    SELECT
        sc.store_key,
        gs.employee_no,
        COALESCE(
            SUM(sc.employee_count) OVER (
                ORDER BY sc.store_key
                ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS previous_employees
    FROM store_counts sc
    CROSS JOIN LATERAL generate_series(
        1, sc.employee_count
    ) AS gs(employee_no)
),
employees AS (
    SELECT
        previous_employees + employee_no AS employee_key,
        store_key,
        employee_no
    FROM employee_rows
)
INSERT INTO dim_employees (
    employee_key,
    name,
    store_key,
    manager_key
)
SELECT
    e.employee_key,
    names.first_name || ' ' || names.last_name,
    e.store_key,
    NULL
FROM employees e
CROSS JOIN LATERAL (
    SELECT
        (ARRAY[
            'James', 'Oliver', 'Harry', 'George', 'Jack',
            'Jacob', 'Noah', 'Charlie', 'Thomas', 'Oscar',
            'William', 'Henry', 'Alfie', 'Joshua', 'Leo',
            'Emily', 'Olivia', 'Amelia', 'Isla', 'Ava',
            'Jessica', 'Lily', 'Sophie', 'Grace', 'Mia',
            'Charlotte', 'Alice', 'Ella', 'Lucy', 'Freya'
        ])[((e.employee_key - 1) % 30) + 1] AS first_name,
        (ARRAY[
            'Smith', 'Johnson', 'Williams', 'Brown', 'Jones',
            'Miller', 'Davis', 'Wilson', 'Taylor', 'Clark',
            'Walker', 'Hall', 'Allen', 'Young', 'King',
            'Wright', 'Scott', 'Green', 'Baker', 'Adams',
            'Nelson', 'Hill', 'Campbell', 'Mitchell', 'Roberts',
            'Carter', 'Phillips', 'Evans', 'Turner', 'Parker'
        ])[((e.employee_key * 7 - 1) % 30) + 1] AS last_name
) names;

WITH store_counts AS (
    SELECT
        store_key,
        (store_key % 4) + 1 AS employee_count
    FROM generate_series(0, 66) AS store_key
),
employee_rows AS (
    SELECT
        sc.store_key,
        gs.employee_no,
        COALESCE(
            SUM(sc.employee_count) OVER (
                ORDER BY sc.store_key
                ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS previous_employees
    FROM store_counts sc
    CROSS JOIN LATERAL generate_series(
        1, sc.employee_count
    ) AS gs(employee_no)
),
employees AS (
    SELECT
        previous_employees + employee_no AS employee_key,
        store_key,
        employee_no
    FROM employee_rows
)
UPDATE dim_employees AS target
SET manager_key = manager.employee_key
FROM employees AS e
JOIN employees AS manager
    ON manager.store_key = e.store_key
   AND manager.employee_no = 1
WHERE target.employee_key = e.employee_key
  AND e.employee_no > 1;
