-- 15_NULL_and_Conditional_Logic: worked examples

CREATE DATABASE IF NOT EXISTS sql_learning_15;
USE sql_learning_15;

DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(50),
    department VARCHAR(30),
    salary DECIMAL(10,2),
    manager_id INT,
    phone VARCHAR(20),
    status VARCHAR(20),
    target DECIMAL(10,2),
    actual DECIMAL(10,2)
);

INSERT INTO employees VALUES
(1,'Asha','Engineering',90000,NULL,NULL,'ACTIVE',100000,95000),
(2,'Rahul','Engineering',65000,1,'9876543210','ACTIVE',80000,80000),
(3,'Meera','Sales',55000,1,'','INACTIVE',60000,45000),
(4,'Vikram','Sales',NULL,1,NULL,'ACTIVE',50000,0),
(5,'Neha','HR',45000,NULL,'9123456780',NULL,40000,42000);

-- 1. Correct way to find NULLs.
SELECT * FROM employees WHERE manager_id IS NULL;
SELECT * FROM employees WHERE manager_id IS NOT NULL;

-- 2. NULL is not the same as zero or an empty string.
SELECT employee_id, salary, phone, target, actual
FROM employees;

-- 3. COALESCE: first non-NULL value.
SELECT employee_id, COALESCE(phone, 'Not Available') AS phone
FROM employees;

-- 4. IFNULL: MySQL two-expression NULL replacement.
SELECT employee_id, IFNULL(salary, 0) AS salary
FROM employees;

-- 5. NULLIF: turn a matching value into NULL.
SELECT employee_id, NULLIF(phone, '') AS normalized_phone
FROM employees;

-- 6. Safe division: avoid divide-by-zero.
SELECT
    employee_id,
    actual / NULLIF(target, 0) AS achievement_ratio
FROM employees;

-- 7. CASE for business classification.
SELECT
    employee_id,
    salary,
    CASE
        WHEN salary IS NULL THEN 'Salary Missing'
        WHEN salary >= 80000 THEN 'High'
        WHEN salary >= 50000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_band
FROM employees;

-- 8. CASE for data-quality flags.
SELECT
    employee_id,
    CASE
        WHEN employee_name IS NULL OR department IS NULL THEN 'INVALID'
        ELSE 'VALID'
    END AS quality_status
FROM employees;

-- 9. Conditional aggregation with CASE.
SELECT
    department,
    SUM(CASE WHEN salary IS NULL THEN 1 ELSE 0 END) AS missing_salary_count,
    SUM(CASE WHEN status = 'ACTIVE' THEN 1 ELSE 0 END) AS active_count
FROM employees
GROUP BY department;

-- 10. Multiple fallback values with COALESCE.
SELECT
    employee_id,
    COALESCE(phone, employee_name, 'Unknown') AS contact_value
FROM employees;

-- 11. Empty string and NULL normalization.
SELECT
    employee_id,
    NULLIF(TRIM(phone), '') AS cleaned_phone
FROM employees;

-- 12. NULL-safe status reporting.
SELECT
    employee_id,
    COALESCE(status, 'UNKNOWN') AS normalized_status
FROM employees;

DROP DATABASE sql_learning_15;
