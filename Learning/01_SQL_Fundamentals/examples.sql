-- ============================================================
-- SQL Fundamentals - Worked Examples
-- MySQL
-- ============================================================
-- Purpose:
--   Learn the basic building blocks of SQL through runnable
--   examples. Each section demonstrates one fundamental concept.
-- ============================================================

-- ============================================================
-- 0. Sample Data Setup
-- ============================================================
-- Run this section first when executing the examples locally.

DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(50),
    department VARCHAR(50),
    salary DECIMAL(10, 2),
    city VARCHAR(50)
);

INSERT INTO employees (employee_id, employee_name, department, salary, city)
VALUES
    (101, 'Amit',   'Data',    60000.00, 'Mumbai'),
    (102, 'Priya',  'Finance', 55000.00, 'Pune'),
    (103, 'Rahul',  'Data',    70000.00, 'Mumbai'),
    (104, 'Neha',   'HR',      50000.00, 'Nashik'),
    (105, 'Vikram', 'Data',    65000.00, 'Pune');

-- Verify the sample data.
SELECT *
FROM employees;


-- ============================================================
-- 1. SELECT - Specific Columns
-- ============================================================
SELECT employee_id, employee_name
FROM employees;


-- ============================================================
-- 2. SELECT * - All Columns
-- ============================================================
SELECT *
FROM employees;

-- Production practice:
-- Prefer explicitly selecting required columns when possible.


-- ============================================================
-- 3. FROM - Data Source
-- ============================================================
SELECT employee_name
FROM employees;


-- ============================================================
-- 4. Column Aliases
-- ============================================================
SELECT
    employee_id AS id,
    employee_name AS name
FROM employees;


-- ============================================================
-- 5. Aliases Without AS
-- ============================================================
SELECT
    employee_id id,
    employee_name name
FROM employees;


-- ============================================================
-- 6. Calculated Columns
-- ============================================================
SELECT
    employee_name,
    salary,
    salary * 12 AS annual_salary
FROM employees;


-- ============================================================
-- 7. Arithmetic Operators
-- ============================================================
SELECT 10 + 20 AS addition_result;
SELECT 100 - 25 AS subtraction_result;
SELECT 10 * 5 AS multiplication_result;
SELECT 100 / 4 AS division_result;
SELECT 17 % 5 AS remainder_result;


-- ============================================================
-- 8. Expressions Using Table Columns
-- ============================================================
SELECT
    employee_name,
    salary,
    salary + 5000 AS salary_after_increment,
    salary * 12 AS annual_salary
FROM employees;


-- ============================================================
-- 9. Numeric Literals
-- ============================================================
SELECT 100 AS number_value;
SELECT 99.50 AS decimal_value;
SELECT -25 AS negative_value;


-- ============================================================
-- 10. String Literals
-- ============================================================
SELECT 'MySQL' AS technology;
SELECT 'Data Engineer' AS target_role;


-- ============================================================
-- 11. Multiple Expressions in One SELECT
-- ============================================================
SELECT
    1000 + 500 AS total,
    1000 * 12 AS annual_amount,
    'Data Engineer' AS target_role;


-- ============================================================
-- 12. SQL Comments
-- ============================================================
-- Single-line comment
SELECT employee_name
FROM employees;

/*
   Multi-line comment.
   Useful for documenting a larger block of SQL.
*/
SELECT employee_id
FROM employees;

# MySQL single-line comment
SELECT department
FROM employees;


-- ============================================================
-- 13. WHERE - Basic Row Filtering
-- ============================================================
SELECT
    employee_name,
    salary
FROM employees
WHERE salary > 60000;


-- ============================================================
-- 14. Comparison Operators
-- ============================================================
SELECT *
FROM employees
WHERE salary = 60000;

SELECT *
FROM employees
WHERE salary <> 60000;

SELECT *
FROM employees
WHERE salary >= 60000;

SELECT *
FROM employees
WHERE salary < 60000;


-- ============================================================
-- 15. AND / OR in a Basic Query
-- ============================================================
SELECT
    employee_name,
    department,
    salary
FROM employees
WHERE department = 'Data'
  AND salary > 60000;

SELECT
    employee_name,
    department
FROM employees
WHERE department = 'Data'
   OR department = 'Finance';


-- ============================================================
-- 16. DISTINCT
-- ============================================================
-- DISTINCT removes duplicate result rows.
-- DISTINCT is covered in detail in a later topic.

SELECT DISTINCT department
FROM employees;

SELECT DISTINCT city
FROM employees;


-- ============================================================
-- 17. Basic Query Structure
-- ============================================================
SELECT
    employee_name,
    salary
FROM employees
WHERE salary > 50000;

-- Written order:
-- SELECT → FROM → WHERE


-- ============================================================
-- 18. Multiple Clauses Together
-- ============================================================
-- GROUP BY, HAVING and ORDER BY are covered in detail later.

SELECT
    department,
    COUNT(*) AS employee_count
FROM employees
WHERE salary > 50000
GROUP BY department
HAVING COUNT(*) >= 2
ORDER BY employee_count DESC;


-- ============================================================
-- 19. Logical Query Processing Order
-- ============================================================
-- Simplified logical order:
-- 1. FROM
-- 2. WHERE
-- 3. GROUP BY
-- 4. HAVING
-- 5. SELECT
-- 6. ORDER BY

SELECT
    department,
    COUNT(*) AS employee_count
FROM employees
WHERE salary > 50000
GROUP BY department
HAVING COUNT(*) >= 2
ORDER BY employee_count DESC;


-- ============================================================
-- 20. Why SELECT Aliases Are Not Normally Available in WHERE
-- ============================================================
-- This is NOT the correct approach:
--
-- SELECT salary * 12 AS annual_salary
-- FROM employees
-- WHERE annual_salary > 600000;
--
-- WHERE is logically processed before SELECT, so the SELECT alias
-- is not normally available there. Subqueries and CTEs can be
-- used when filtering derived values.


-- ============================================================
-- 21. Queries Without a Table
-- ============================================================
-- MySQL can evaluate constant expressions without FROM.

SELECT 10 + 20 AS result;
SELECT 'Hello, MySQL' AS message;
SELECT 100 * 12 AS annual_amount;


-- ============================================================
-- 22. NULL Introduction
-- ============================================================
-- NULL represents an absence of a value. It is not the same as
-- 0 or an empty string. NULL handling is covered later.

SELECT NULL AS missing_value;

SELECT
    employee_name,
    NULL AS bonus
FROM employees;


-- ============================================================
-- 23. Literal Alongside Table Data
-- ============================================================
SELECT
    employee_name,
    'Employee' AS record_type
FROM employees;


-- ============================================================
-- 24. Practical Example - Employee Annual Salary
-- ============================================================
-- Business requirement:
-- Display each employee's monthly and annual salary.

SELECT
    employee_id,
    employee_name,
    salary AS monthly_salary,
    salary * 12 AS annual_salary
FROM employees;


-- ============================================================
-- 25. Practical Example - Data Team Employees
-- ============================================================
-- Business requirement:
-- Find employees working in the Data department.

SELECT
    employee_id,
    employee_name,
    salary
FROM employees
WHERE department = 'Data';


-- ============================================================
-- 26. Practical Example - High Salary Employees
-- ============================================================
-- Business requirement:
-- Find employees earning more than 65000 per month.

SELECT
    employee_name,
    salary
FROM employees
WHERE salary > 65000;


-- ============================================================
-- 27. Practical Example - Employees in Mumbai
-- ============================================================
SELECT
    employee_name,
    department,
    city
FROM employees
WHERE city = 'Mumbai';


-- ============================================================
-- 28. Final Revision Query
-- ============================================================
-- Combines the fundamentals introduced in this topic.

SELECT
    employee_name AS name,
    department,
    salary AS monthly_salary,
    salary * 12 AS annual_salary
FROM employees
WHERE salary >= 60000
ORDER BY annual_salary DESC;


-- ============================================================
-- Key Takeaways
-- ============================================================
-- SELECT      → chooses columns or expressions
-- FROM        → identifies the data source
-- WHERE       → filters rows
-- DISTINCT    → removes duplicate result rows
-- AS          → creates an output alias
-- Expressions → calculate values
-- Literals    → fixed values written directly in SQL
-- Comments    → document SQL without affecting execution
--
-- Logical query processing:
-- FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY
-- ============================================================
