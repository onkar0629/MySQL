-- ============================================================
-- SQL Fundamentals - Practice
-- MySQL
-- ============================================================

-- Instructions:
-- 1. Try each question yourself before checking examples.sql.
-- 2. Write the SQL query below each question.
-- 3. For theory questions, answer using SQL comments.
-- 4. Focus on understanding the requirement before writing syntax.
-- ============================================================

-- ============================================================
-- Practice Dataset
-- ============================================================

CREATE DATABASE IF NOT EXISTS sql_fundamentals_practice;
USE sql_fundamentals_practice;

DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100),
    department VARCHAR(50),
    salary DECIMAL(10, 2),
    city VARCHAR(50)
);

INSERT INTO employees (employee_id, employee_name, department, salary, city)
VALUES
    (101, 'Amit', 'Data Engineering', 60000.00, 'Mumbai'),
    (102, 'Priya', 'Finance', 55000.00, 'Pune'),
    (103, 'Rahul', 'Data Engineering', 70000.00, 'Mumbai'),
    (104, 'Sneha', 'HR', 50000.00, 'Pune'),
    (105, 'Vikram', 'Data Engineering', 65000.00, 'Bengaluru'),
    (106, 'Neha', 'Finance', 58000.00, 'Mumbai'),
    (107, 'Arjun', 'HR', 52000.00, 'Mumbai'),
    (108, 'Kiran', 'Data Engineering', 62000.00, 'Pune');

-- Verify the dataset before starting.
SELECT *
FROM employees;

-- ============================================================
-- Section A - SELECT and FROM
-- ============================================================

-- Q1. Display all columns from the employees table.


-- Q2. Display only employee_name and department.


-- Q3. Display employee_id, employee_name, and city.


-- Q4. Display employee_name and salary.


-- Q5. Display the employee_name column with the alias name.


-- ============================================================
-- Section B - Aliases and Expressions
-- ============================================================

-- Q6. Display employee_name as name and salary as monthly_salary.


-- Q7. Display employee_name, salary, and annual salary.
-- Annual salary = salary * 12.


-- Q8. Display employee_name and salary after a 10% increment.
-- Use an alias such as increased_salary.


-- Q9. Display employee_name, salary, and annual salary after a 10% increment.
-- Calculate the increased monthly salary first and then multiply it by 12.


-- Q10. Return 15 * 8 without using a table.
-- Give the result a meaningful alias.


-- Q11. Return the following values without using a table:
-- 100
-- 99.50
-- 'MySQL'
-- Give each value a meaningful alias.


-- ============================================================
-- Section C - DISTINCT and Basic Filtering
-- ============================================================

-- Q12. Display all unique departments.


-- Q13. Display all unique cities.


-- Q14. Display employees whose salary is greater than 60000.


-- Q15. Display employees whose salary is greater than or equal to 60000.


-- Q16. Display employees whose salary is less than 55000.


-- Q17. Display employees who work in Mumbai.


-- Q18. Display employee_name and salary for employees who work in the
-- Data Engineering department.


-- ============================================================
-- Section D - Multiple Conditions
-- ============================================================

-- Q19. Display Data Engineering employees earning more than 60000.


-- Q20. Display employees who work in Mumbai AND earn more than 55000.


-- Q21. Display employees who work in either Mumbai OR Pune.


-- Q22. Display employees who are NOT from the HR department.
-- Use a comparison condition; do not use advanced operators yet.


-- Q23. Display employees who work in Data Engineering OR Finance.


-- ============================================================
-- Section E - Comments and Query Structure
-- ============================================================

-- Q24. Write one single-line SQL comment explaining what SELECT does.


-- Q25. Write a multi-line SQL comment explaining the purpose of FROM.


-- Q26. Write a query using the basic structure:
-- SELECT -> FROM -> WHERE
-- Return employee_name and salary for employees earning more than 58000.


-- ============================================================
-- Section F - Practical Business Questions
-- ============================================================

-- Q27. HR wants a list of employee names and annual salaries.
-- Return employee_name and annual_salary.


-- Q28. The Data Engineering manager wants employees earning at least
-- 60000. Return employee_name, department, and salary.


-- Q29. The company wants to know which cities currently have employees.
-- Return only unique city names.


-- Q30. Finance wants to identify employees earning between 55000 and 60000.
-- For this exercise, use two comparison conditions joined with AND.


-- Q31. The HR team wants employees from Mumbai who are not in HR.
-- Return employee_name, department, and city.


-- Q32. The company wants a salary report containing:
-- employee_name
-- department
-- monthly_salary
-- annual_salary
-- Only include employees earning more than 55000.


-- Q33. The Data Engineering team wants a report containing:
-- employee_name
-- city
-- monthly_salary
-- annual_salary
-- Only include Data Engineering employees earning at least 60000.


-- ============================================================
-- Section G - Theory / Interview Practice
-- ============================================================

-- Q34. Explain the difference between SQL and MySQL.
-- Write your answer as SQL comments.


-- Q35. Explain the difference between a DBMS and an RDBMS.
-- Write your answer as SQL comments.


-- Q36. Explain the difference between a table, row, column, and value.
-- Write your answer as SQL comments.


-- Q37. List DDL, DML, DQL, DCL, and TCL commands with examples.
-- Write your answer as SQL comments.


-- Q38. Why is SQL called a declarative language?
-- Write your answer as SQL comments.


-- Q39. What is the difference between SELECT * and selecting specific columns?
-- Write your answer as SQL comments.


-- Q40. What is a column alias, and why is it useful?
-- Write your answer as SQL comments.


-- Q41. What is a SQL literal? Give numeric and string examples.
-- Write your answer as SQL comments.


-- Q42. What is the difference between a SQL keyword and an identifier?
-- Write your answer as SQL comments.


-- Q43. Write the simplified logical processing order of a typical SQL query.
-- Write your answer as SQL comments.


-- Q44. Why can a SELECT alias normally not be referenced in WHERE?
-- Write your answer as SQL comments.


-- Q45. Explain the difference between logical query processing and physical
-- query execution.
-- Write your answer as SQL comments.


-- ============================================================
-- Section H - Interview Challenges
-- ============================================================

-- Q46. Write a query that returns the employee with the highest salary.
-- Do not use advanced SQL such as window functions.
-- Hint: This is intentionally a simple challenge; think about the
-- clauses you already know.


-- Q47. Write a query that returns all employees whose annual salary is
-- greater than 720000.
-- Do not create a new column in the table; calculate it in the query.


-- Q48. Write a query that returns employees from Mumbai or Pune whose
-- salary is greater than 55000.


-- Q49. Write one query that returns:
-- employee_name
-- department
-- monthly_salary
-- annual_salary
-- city
-- Only include employees earning at least 60000.


-- Q50. Write one final query that demonstrates your understanding of:
-- SELECT
-- FROM
-- WHERE
-- aliases
-- calculated columns
-- AND / OR
-- DISTINCT where appropriate
--
-- Business requirement:
-- "Prepare a basic employee report for the Data Engineering and Finance
-- teams, showing employee name, city, monthly salary, and annual salary.
-- Include only employees earning more than 55000."


-- ============================================================
-- Self-Assessment
-- ============================================================

-- After completing the exercises, check whether you can confidently:
-- [ ] Write a basic SELECT query from memory.
-- [ ] Select specific columns and all columns.
-- [ ] Use column aliases.
-- [ ] Create calculated columns.
-- [ ] Use arithmetic operators.
-- [ ] Use literals without a table.
-- [ ] Use DISTINCT.
-- [ ] Filter rows using WHERE.
-- [ ] Use comparison operators.
-- [ ] Combine conditions with AND / OR.
-- [ ] Explain SQL vs MySQL.
-- [ ] Explain DBMS vs RDBMS.
-- [ ] Explain DDL, DML, DQL, DCL, and TCL.
-- [ ] Explain logical query processing order.
-- [ ] Solve the final business requirement without copying a solution.
-- ============================================================
