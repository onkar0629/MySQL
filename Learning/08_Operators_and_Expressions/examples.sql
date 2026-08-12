-- ============================================================
-- 08 — Operators and Expressions
-- Worked Examples
-- ============================================================

CREATE DATABASE IF NOT EXISTS mysql_learning_08;
USE mysql_learning_08;

DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    department VARCHAR(50),
    salary DECIMAL(10,2),
    bonus DECIMAL(10,2),
    status VARCHAR(20),
    manager_id INT
);

INSERT INTO employees VALUES
(1, 'Amit', 'Data Engineering', 90000, 10000, 'active', NULL),
(2, 'Priya', 'Analytics', 65000, NULL, 'active', 1),
(3, 'Rahul', 'Finance', 52000, 5000, 'inactive', 1),
(4, 'Sneha', 'Data Engineering', 110000, 15000, 'active', 1),
(5, 'Vikas', NULL, 48000, NULL, 'active', NULL);

-- 1. Arithmetic expressions
SELECT salary, bonus, salary + COALESCE(bonus, 0) AS total_compensation
FROM employees;

SELECT salary, salary * 12 AS annual_salary
FROM employees;

SELECT 10 / 4 AS division_result,
       10 DIV 4 AS integer_division,
       10 % 4 AS remainder;

-- 2. Comparison operators
SELECT employee_name, salary
FROM employees
WHERE salary >= 60000;

SELECT employee_name, status
FROM employees
WHERE status <> 'inactive';

-- 3. AND / OR / NOT
SELECT employee_name, department, salary
FROM employees
WHERE department = 'Data Engineering'
  AND salary >= 60000;

SELECT employee_name, department
FROM employees
WHERE department = 'Data Engineering'
   OR department = 'Analytics';

SELECT employee_name, status
FROM employees
WHERE NOT status = 'inactive';

-- 4. Operator precedence
SELECT employee_name, department, salary
FROM employees
WHERE department = 'Data Engineering'
   OR department = 'Analytics'
  AND salary >= 60000;

SELECT employee_name, department, salary
FROM employees
WHERE (department = 'Data Engineering'
    OR department = 'Analytics')
  AND salary >= 60000;

-- 5. BETWEEN
SELECT employee_name, salary
FROM employees
WHERE salary BETWEEN 50000 AND 90000;

-- 6. IN / NOT IN
SELECT employee_name, department
FROM employees
WHERE department IN ('Data Engineering', 'Analytics');

SELECT employee_name, status
FROM employees
WHERE status NOT IN ('inactive', 'deleted');

-- 7. LIKE
SELECT employee_name
FROM employees
WHERE employee_name LIKE 'A%';

SELECT employee_name
FROM employees
WHERE employee_name LIKE '%a%';

-- 8. NULL checks
SELECT employee_name, manager_id
FROM employees
WHERE manager_id IS NULL;

SELECT employee_name, bonus
FROM employees
WHERE bonus IS NOT NULL;

-- 9. CASE expressions
SELECT
    employee_name,
    salary,
    CASE
        WHEN salary >= 100000 THEN 'High'
        WHEN salary >= 60000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_band
FROM employees;

-- 10. Data Engineering timestamp filtering pattern
DROP TABLE IF EXISTS pipeline_events;
CREATE TABLE pipeline_events (
    event_id INT PRIMARY KEY,
    event_name VARCHAR(100),
    updated_at DATETIME
);

INSERT INTO pipeline_events VALUES
(1, 'load_started', '2026-08-01 00:05:00'),
(2, 'load_completed', '2026-08-01 14:30:00'),
(3, 'validation_failed', '2026-08-02 01:00:00');

SELECT *
FROM pipeline_events
WHERE updated_at >= '2026-08-01'
  AND updated_at < '2026-08-02';

-- 11. Detect invalid records
SELECT *
FROM employees
WHERE salary < 0
   OR salary IS NULL;

-- 12. Bitwise operators
SELECT 5 & 3 AS bitwise_and,
       5 | 3 AS bitwise_or,
       5 ^ 3 AS bitwise_xor;

-- Key takeaway:
-- Use explicit parentheses for complex boolean logic,
-- IS NULL for NULL checks, and half-open ranges for timestamps.
