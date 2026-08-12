-- ============================================================
-- 21 — Window Functions
-- examples.sql
-- ============================================================

CREATE DATABASE IF NOT EXISTS window_functions_demo;
USE window_functions_demo;

DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS staging_customer;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS employees;

-- ============================================================
-- 1. Employees
-- ============================================================
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

-- 1. OVER() without PARTITION BY: company average.
SELECT
    employee_id,
    employee_name,
    salary,
    AVG(salary) OVER () AS company_avg_salary
FROM employees;

-- 2. PARTITION BY: department average while retaining employees.
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

-- 4. Top 2 rows per department: exactly two rows per department.
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

-- 5. Top 2 salary levels per department: ties preserved.
WITH ranked AS (
    SELECT
        e.*,
        DENSE_RANK() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
        ) AS salary_rank
    FROM employees e
)
SELECT *
FROM ranked
WHERE salary_rank <= 2;

-- 6. Highest salary in each department.
SELECT
    employee_id,
    employee_name,
    department_id,
    salary,
    FIRST_VALUE(salary) OVER (
        PARTITION BY department_id
        ORDER BY salary DESC, employee_id
    ) AS highest_department_salary
FROM employees;

-- 7. Lowest salary in each department.
-- Explicit frame avoids LAST_VALUE() default-frame surprises.
SELECT
    employee_id,
    employee_name,
    department_id,
    salary,
    LAST_VALUE(salary) OVER (
        PARTITION BY department_id
        ORDER BY salary, employee_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS lowest_department_salary
FROM employees;

-- ============================================================
-- 2. Orders for LAG / LEAD / running calculations
-- ============================================================
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

-- 8. LAG: previous order amount per customer.
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

-- 9. LAG with offset and default value.
SELECT
    customer_id,
    order_id,
    amount,
    LAG(amount, 2, 0) OVER (
        PARTITION BY customer_id
        ORDER BY order_date, order_id
    ) AS amount_two_orders_ago
FROM orders;

-- 10. Change from previous order.
WITH compared AS (
    SELECT
        customer_id,
        order_id,
        order_date,
        amount,
        LAG(amount) OVER (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
        ) AS previous_amount
    FROM orders
)
SELECT
    customer_id,
    order_id,
    amount,
    previous_amount,
    amount - previous_amount AS change_from_previous
FROM compared;

-- 11. Days since previous order.
WITH previous_orders AS (
    SELECT
        customer_id,
        order_id,
        order_date,
        LAG(order_date) OVER (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
        ) AS previous_order_date
    FROM orders
)
SELECT
    customer_id,
    order_id,
    order_date,
    previous_order_date,
    DATEDIFF(order_date, previous_order_date) AS days_since_previous
FROM previous_orders;

-- 12. LEAD: next order date.
SELECT
    customer_id,
    order_id,
    order_date,
    LEAD(order_date) OVER (
        PARTITION BY customer_id
        ORDER BY order_date, order_id
    ) AS next_order_date
FROM orders;

-- 13. Running total per customer.
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

-- 14. Running average.
SELECT
    order_date,
    order_id,
    amount,
    AVG(amount) OVER (
        ORDER BY order_date, order_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_average
FROM orders;

-- 15. Three-row moving average.
SELECT
    order_date,
    order_id,
    amount,
    AVG(amount) OVER (
        ORDER BY order_date, order_id
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS three_row_moving_average
FROM orders;

-- 16. First and second order per customer.
WITH ranked AS (
    SELECT
        o.*,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
        ) AS order_number
    FROM orders o
)
SELECT *
FROM ranked
WHERE order_number IN (1, 2);

-- ============================================================
-- 3. CDC / staging deduplication
-- ============================================================
CREATE TABLE staging_customer (
    record_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(100),
    updated_at DATETIME NOT NULL
);

INSERT INTO staging_customer VALUES
(1, 101, 'Amit',  'Mumbai', '2026-08-01 09:00:00'),
(2, 101, 'Amit',  'Pune',   '2026-08-03 10:00:00'),
(3, 102, 'Priya', 'Delhi',  '2026-08-02 11:00:00'),
(4, 102, 'Priya', 'Noida',  '2026-08-04 12:00:00'),
(5, 103, 'Rahul', 'Nashik', '2026-08-05 08:00:00');

-- 17. Keep latest record for every business key.
WITH ranked AS (
    SELECT
        s.*,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY updated_at DESC, record_id DESC
        ) AS rn
    FROM staging_customer s
)
SELECT *
FROM ranked
WHERE rn = 1;

-- ============================================================
-- 4. Events and next-event analysis
-- ============================================================
CREATE TABLE events (
    event_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    event_time DATETIME NOT NULL,
    event_type VARCHAR(30) NOT NULL
);

INSERT INTO events VALUES
(1, 10, '2026-08-01 09:00:00', 'login'),
(2, 10, '2026-08-01 09:10:00', 'view'),
(3, 10, '2026-08-01 09:25:00', 'purchase'),
(4, 10, '2026-08-01 12:00:00', 'logout'),
(5, 20, '2026-08-01 10:00:00', 'login'),
(6, 20, '2026-08-01 10:20:00', 'view'),
(7, 20, '2026-08-01 10:45:00', 'logout');

-- 18. Time until next event.
WITH sequenced AS (
    SELECT
        user_id,
        event_id,
        event_time,
        event_type,
        LEAD(event_time) OVER (
            PARTITION BY user_id
            ORDER BY event_time, event_id
        ) AS next_event_time
    FROM events
)
SELECT
    user_id,
    event_type,
    event_time,
    next_event_time,
    TIMESTAMPDIFF(
        MINUTE,
        event_time,
        next_event_time
    ) AS minutes_to_next_event
FROM sequenced;

-- ============================================================
-- 5. Window result filtering
-- ============================================================

-- Correct pattern: calculate first, filter outside.
WITH ranked AS (
    SELECT
        e.*,
        ROW_NUMBER() OVER (
            ORDER BY salary DESC, employee_id
        ) AS rn
    FROM employees e
)
SELECT *
FROM ranked
WHERE rn <= 3;

-- ============================================================
-- 6. Grain awareness after joins
-- ============================================================

-- Before adding a window after a JOIN, verify what one row represents.
-- A one-to-many JOIN can multiply rows and change ranking/counting results.
-- Always inspect the joined result first, then apply the window calculation.

-- ============================================================
-- 7. EXPLAIN
-- ============================================================

EXPLAIN
SELECT
    customer_id,
    order_id,
    amount,
    ROW_NUMBER() OVER (
        PARTITION BY customer_id
        ORDER BY order_date, order_id
    ) AS rn
FROM orders;

-- ============================================================
-- Key lessons
-- ============================================================
-- * PARTITION BY defines independent windows.
-- * Window ORDER BY controls calculation order.
-- * ROW_NUMBER gives unique row positions.
-- * RANK preserves ties with gaps.
-- * DENSE_RANK preserves ties without gaps.
-- * LAG looks backward; LEAD looks forward.
-- * Explicit ROWS frames matter for row-based calculations.
-- * LAST_VALUE often requires an explicit complete-partition frame.
-- * Use a CTE/derived table to filter window results.
-- * Always validate data grain before applying windows after joins.
