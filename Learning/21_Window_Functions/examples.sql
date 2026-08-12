-- 21_Window_Functions — Examples

CREATE DATABASE IF NOT EXISTS window_functions_demo;
USE window_functions_demo;

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    department_id INT NOT NULL,
    salary DECIMAL(10,2) NOT NULL
);

INSERT INTO employees VALUES
(101, 'Amit', 10, 90000),
(102, 'Neha', 10, 85000),
(103, 'Rahul', 10, 85000),
(104, 'Priya', 20, 95000),
(105, 'Karan', 20, 70000),
(106, 'Sneha', 20, 70000);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL
);

INSERT INTO orders VALUES
(1001, 501, '2026-08-01', 1000),
(1002, 501, '2026-08-05', 1500),
(1003, 501, '2026-08-10', 800),
(1004, 502, '2026-08-02', 2000),
(1005, 502, '2026-08-07', 500);

-- 1. Company average while keeping every employee.
SELECT
    employee_id,
    employee_name,
    salary,
    AVG(salary) OVER () AS company_avg_salary
FROM employees;

-- 2. Department average.
SELECT
    employee_id,
    department_id,
    salary,
    AVG(salary) OVER (
        PARTITION BY department_id
    ) AS department_avg_salary
FROM employees;

-- 3. ROW_NUMBER, RANK, and DENSE_RANK.
SELECT
    employee_id,
    department_id,
    salary,
    ROW_NUMBER() OVER (
        PARTITION BY department_id
        ORDER BY salary DESC, employee_id
    ) AS row_num,
    RANK() OVER (
        PARTITION BY department_id
        ORDER BY salary DESC
    ) AS salary_rank,
    DENSE_RANK() OVER (
        PARTITION BY department_id
        ORDER BY salary DESC
    ) AS dense_salary_rank
FROM employees;

-- 4. Top 2 employees per department.
WITH ranked AS (
    SELECT
        e.*,
        ROW_NUMBER() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC, employee_id
        ) AS rn
    FROM employees e
)
SELECT *
FROM ranked
WHERE rn <= 2;

-- 5. Previous order for every customer.
SELECT
    customer_id,
    order_id,
    order_date,
    amount,
    LAG(amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_date, order_id
    ) AS previous_amount
FROM orders;

-- 6. Next order date.
SELECT
    customer_id,
    order_id,
    order_date,
    LEAD(order_date) OVER (
        PARTITION BY customer_id
        ORDER BY order_date, order_id
    ) AS next_order_date
FROM orders;

-- 7. Running total per customer.
SELECT
    customer_id,
    order_date,
    order_id,
    amount,
    SUM(amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_date, order_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM orders;

-- 8. Difference from previous order.
SELECT
    customer_id,
    order_id,
    amount,
    amount - LAG(amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_date, order_id
    ) AS change_from_previous
FROM orders;

-- 9. Seven-row moving average pattern.
SELECT
    order_date,
    amount,
    AVG(amount) OVER (
        ORDER BY order_date, order_id
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS moving_avg
FROM orders;

-- 10. Deduplication pattern.
-- Replace the business key and timestamp with the real staging columns.
WITH ranked AS (
    SELECT
        o.*,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id, order_date
            ORDER BY order_id DESC
        ) AS rn
    FROM orders o
)
SELECT *
FROM ranked
WHERE rn = 1;

-- Key lessons:
-- * PARTITION BY defines independent windows.
-- * ORDER BY inside OVER controls the calculation order.
-- * Add a stable tie-breaker when ROW_NUMBER must be deterministic.
-- * Use an explicit ROWS frame when exact row-based behavior matters.
-- * Filter window-function results in an outer query or CTE.