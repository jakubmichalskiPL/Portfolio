-- Employees Hierarchy
-- Purpose: Examine the employee hierarchy
-- and identify each employee's level and reporting path.

WITH RECURSIVE employees_hierarchy AS (
    SELECT
        employee_key,
        manager_key,
        name,
        1 AS hierarchy_level,
        CAST(name AS TEXT) AS path
    FROM dim_employees
    WHERE manager_key IS NULL

    UNION ALL

    SELECT
        e.employee_key,
        e.manager_key,
        e.name,
        m.hierarchy_level + 1,
        m.path || ' -> ' || e.name
    FROM dim_employees AS e
    JOIN employees_hierarchy AS m
        ON e.manager_key = m.employee_key
)

SELECT
    employee_key,
    manager_key,
    name,
    hierarchy_level,
    path
FROM employees_hierarchy
ORDER BY path;