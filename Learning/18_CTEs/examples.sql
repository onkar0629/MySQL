-- 18_CTEs — Examples
-- Run this file in MySQL 8.0+.

DROP DATABASE IF EXISTS cte_demo;
CREATE DATABASE cte_demo;
USE cte_demo;

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    manager_id INT NULL,
    department VARCHAR(50) NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    updated_at DATETIME NOT NULL
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    order_date DATE NOT NULL
);

INSERT INTO employees VALUES
(1, 'CEO', NULL, 'Management', 200000, '2026-08-01 09:00:00'),
(2, 'Amit', 1, 'Data Engineering', 100000, '2026-08-02 09:00:00'),
(3, 'Neha', 1, 'Analytics', 90000, '2026-08-03 09:00:00'),
(4, 'Rahul', 2, 'Data Engineering', 80000, '2026-08-04 09:00:00'),
(5, 'Priya', 2, 'Data Engineering', 85000, '2026-08-05 09:00:00');

INSERT INTO orders VALUES
(101, 501, 1200, 'COMPLETED', '2026-08-01'),
(102, 501, 800, 'COMPLETED', '2026-08-02'),
(103, 502, 2500, 'COMPLETED', '2026-08-03'),
(104, 503, 400, 'CANCELLED', '2026-08-04'),
(105, 502, 1800, 'COMPLETED', '2026-08-05');

-- 1. Basic CTE
WITH active_orders AS (
    SELECT *
    FROM orders
    WHERE status = 'COMPLETED'
)
SELECT *
FROM active_orders;

-- 2. Aggregate inside a CTE, filter outside
WITH customer_sales AS (
    SELECT
        customer_id,
        SUM(amount) AS total_sales
    FROM orders
    WHERE status = 'COMPLETED'
    GROUP BY customer_id
)
SELECT *
FROM customer_sales
WHERE total_sales >= 2000;

-- 3. Multiple CTEs
WITH customer_sales AS (
    SELECT customer_id, SUM(amount) AS total_sales
    FROM orders
    WHERE status = 'COMPLETED'
    GROUP BY customer_id
),
ranked_customers AS (
    SELECT
        customer_id,
        total_sales,
        RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
    FROM customer_sales
)
SELECT *
FROM ranked_customers
WHERE sales_rank <= 2;

-- 4. Deduplicate latest employee record pattern
WITH ranked_employees AS (
    SELECT
        employee_id,
        employee_name,
        department,
        updated_at,
        ROW_NUMBER() OVER (
            PARTITION BY employee_id
            ORDER BY updated_at DESC
        ) AS rn
    FROM employees
)
SELECT *
FROM ranked_employees
WHERE rn = 1;

-- 5. Recursive CTE: employee hierarchy
WITH RECURSIVE employee_tree AS (
    SELECT
        employee_id,
        employee_name,
        manager_id,
        0 AS level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    SELECT
        e.employee_id,
        e.employee_name,
        e.manager_id,
        t.level + 1
    FROM employees e
    JOIN employee_tree t
      ON e.manager_id = t.employee_id
)
SELECT
    employee_id,
    employee_name,
    manager_id,
    level
FROM employee_tree
ORDER BY level, employee_id;

-- 6. Recursive CTE: generate numbers 1 through 10
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM numbers
    WHERE n < 10
)
SELECT n
FROM numbers;

-- 7. Source/target-style reconciliation using CTEs
WITH source_metrics AS (
    SELECT
        COUNT(*) AS row_count,
        SUM(amount) AS total_amount
    FROM orders
    WHERE status = 'COMPLETED'
),
target_metrics AS (
    SELECT
        COUNT(*) AS row_count,
        SUM(amount) AS total_amount
    FROM orders
    WHERE status = 'COMPLETED'
)
SELECT
    s.row_count AS source_rows,
    t.row_count AS target_rows,
    s.total_amount AS source_amount,
    t.total_amount AS target_amount,
    CASE
        WHEN s.row_count = t.row_count
         AND s.total_amount = t.total_amount
        THEN 'MATCH'
        ELSE 'MISMATCH'
    END AS reconciliation_status
FROM source_metrics s
CROSS JOIN target_metrics t;

-- 8. CTE can make a multi-step transformation easier to read.
WITH valid_orders AS (
    SELECT *
    FROM orders
    WHERE amount >= 0
      AND status <> 'CANCELLED'
),
monthly_customer_sales AS (
    SELECT
        customer_id,
        SUM(amount) AS total_sales
    FROM valid_orders
    GROUP BY customer_id
)
SELECT *
FROM monthly_customer_sales
ORDER BY total_sales DESC, customer_id;