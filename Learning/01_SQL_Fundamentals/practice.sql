-- ============================================================
-- SQL Fundamentals - Practice
-- MySQL
-- ============================================================

-- Instructions:
-- 1. Try each question yourself before checking examples.sql.
-- 2. Write the SQL query below each question.
-- 3. Focus on understanding what each clause does.
-- ============================================================

-- Practice Dataset
-- Use the following table for Questions 1-10.

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
    (106, 'Neha', 'Finance', 58000.00, 'Mumbai');

-- ============================================================
-- Q1. Display all columns from the employees table.
-- ============================================================


-- ============================================================
-- Q2. Display only employee_name and department.
-- ============================================================


-- ============================================================
-- Q3. Display employee_name and salary.
-- ============================================================


-- ============================================================
-- Q4. Display employee_name as name and salary as monthly_salary.
-- ============================================================


-- ============================================================
-- Q5. Display employee_name, salary, and annual salary.
-- Annual salary = salary * 12.
-- ============================================================


-- ============================================================
-- Q6. Display all unique departments.
-- ============================================================


-- ============================================================
-- Q7. Calculate 15 * 8 and return the result with a meaningful alias.
-- Do not use a table.
-- ============================================================


-- ============================================================
-- Q8. Return the text 'Data Engineer' with the alias target_role.
-- Do not use a table.
-- ============================================================


-- ============================================================
-- Q9. Display employees whose salary is greater than 60000.
-- ============================================================


-- ============================================================
-- Q10. Display employee_name and salary for employees in Mumbai.
-- ============================================================


-- ============================================================
-- Interview Practice
-- ============================================================

-- Q11. Explain the difference between SQL and MySQL.
-- Write your answer as SQL comments.


-- Q12. Explain the difference between a DBMS and an RDBMS.
-- Write your answer as SQL comments.


-- Q13. List DDL, DML, DQL, DCL, and TCL commands.
-- Write your answer as SQL comments.


-- Q14. Write the logical processing order of a typical SQL query.
-- Write your answer as SQL comments.


-- Q15. Why is SQL called a declarative language?
-- Write your answer as SQL comments.


-- ============================================================
-- Challenge
-- ============================================================

-- Q16. Write one query that returns:
-- employee_name
-- department
-- monthly salary
-- annual salary
--
-- Only include employees earning more than 55000.
-- Sort the result by annual salary from highest to lowest.
--
-- Hint: Do not worry about mastering ORDER BY yet;
-- the goal is to recognize how multiple clauses form one query.

