-- ============================================================
-- SQL Fundamentals - Examples
-- ============================================================

-- Example 1: Select all columns
SELECT *
FROM employees;

-- Example 2: Select specific columns
SELECT employee_id, employee_name, department
FROM employees;

-- Example 3: Column aliases
SELECT
    employee_id AS id,
    employee_name AS name
FROM employees;

-- Example 4: Calculated column
SELECT
    employee_name,
    salary,
    salary * 12 AS annual_salary
FROM employees;

-- Example 5: SQL comments
-- Single-line comment

/*
   Multi-line comment
   Used for longer explanations.
*/

-- Example 6: DISTINCT values
SELECT DISTINCT department
FROM employees;

-- Example 7: Simple expression
SELECT 10 + 20 AS result;
