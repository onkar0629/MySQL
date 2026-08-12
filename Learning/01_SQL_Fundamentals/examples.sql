-- ============================================================
-- SQL Fundamentals - Worked Examples
-- MySQL
-- ============================================================

-- ============================================================
-- 1. SELECT specific columns
-- ============================================================
SELECT employee_id, employee_name, department
FROM employees;

-- ============================================================
-- 2. SELECT all columns
-- ============================================================
SELECT *
FROM employees;

-- ============================================================
-- 3. Column aliases
-- ============================================================
SELECT
    employee_id AS id,
    employee_name AS name
FROM employees;

-- ============================================================
-- 4. Calculated columns
-- ============================================================
SELECT
    employee_name,
    salary,
    salary * 12 AS annual_salary
FROM employees;

-- ============================================================
-- 5. Multiple expressions
-- ============================================================
SELECT
    employee_name,
    salary,
    salary + 5000 AS salary_after_increment,
    salary * 12 AS annual_salary
FROM employees;

-- ============================================================
-- 6. Numeric literals and expressions
-- ============================================================
SELECT 10 + 20 AS addition_result;
SELECT 100 - 25 AS subtraction_result;
SELECT 10 * 5 AS multiplication_result;
SELECT 100 / 4 AS division_result;
SELECT 17 % 5 AS remainder_result;

-- ============================================================
-- 7. String and numeric literals
-- ============================================================
SELECT 'MySQL' AS technology;
SELECT 100 AS number_value;
SELECT 99.50 AS decimal_value;

-- ============================================================
-- 8. DISTINCT values
-- Note: DISTINCT is covered in detail in a later topic.
-- ============================================================
SELECT DISTINCT department
FROM employees;

-- ============================================================
-- 9. SQL comments
-- ============================================================
-- Single-line comment
SELECT employee_name
FROM employees;

/*
   Multi-line comment:
   useful for longer explanations.
*/
SELECT employee_id
FROM employees;

# MySQL single-line comment
SELECT department
FROM employees;

-- ============================================================
-- 10. Query with multiple clauses
-- This demonstrates the basic query structure.
-- ============================================================
SELECT
    employee_name,
    salary
FROM employees
WHERE salary > 50000;

-- ============================================================
-- 11. Aggregate query used to demonstrate logical order
-- GROUP BY, HAVING and ORDER BY are covered later in detail.
-- ============================================================
SELECT
    department,
    COUNT(*) AS employee_count
FROM employees
WHERE salary > 50000
GROUP BY department
HAVING COUNT(*) >= 2
ORDER BY employee_count DESC;

-- ============================================================
-- 12. A query without a table
-- MySQL can evaluate constant expressions directly.
-- ============================================================
SELECT 10 + 20 AS result;
SELECT 'Hello, MySQL' AS message;

-- ============================================================
-- 13. Explicit aliases for expressions
-- ============================================================
SELECT
    1000 * 12 AS annual_amount,
    'Data Engineer' AS target_role;

-- ============================================================
-- Interview Reminder
-- Logical processing order for a typical query:
-- FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY
-- ============================================================
