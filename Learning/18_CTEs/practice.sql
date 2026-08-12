-- 18_CTEs — Practice
-- DO NOT add answers here.
-- Solve each problem yourself.

/*
============================================================
SCHEMA
============================================================
*/

DROP DATABASE IF EXISTS cte_practice;
CREATE DATABASE cte_practice;
USE cte_practice;

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    manager_id INT NULL,
    department VARCHAR(50) NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    joining_date DATE NOT NULL
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(20) NOT NULL
);

CREATE TABLE customer_updates (
    update_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    email VARCHAR(150),
    updated_at DATETIME NOT NULL
);

INSERT INTO employees VALUES
(1, 'CEO', NULL, 'Management', 200000, '2018-01-10'),
(2, 'Amit', 1, 'Data Engineering', 100000, '2020-04-15'),
(3, 'Neha', 1, 'Analytics', 90000, '2021-06-20'),
(4, 'Rahul', 2, 'Data Engineering', 80000, '2022-02-12'),
(5, 'Priya', 2, 'Data Engineering', 85000, '2023-01-08'),
(6, 'Karan', 3, 'Analytics', 70000, '2024-03-01');

INSERT INTO orders VALUES
(101, 501, '2026-01-05', 1200, 'COMPLETED'),
(102, 501, '2026-02-10', 1800, 'COMPLETED'),
(103, 502, '2026-02-15', 2500, 'COMPLETED'),
(104, 503, '2026-03-02', 500, 'CANCELLED'),
(105, 502, '2026-03-08', 3000, 'COMPLETED'),
(106, 504, '2026-03-15', 900, 'COMPLETED'),
(107, 501, '2026-04-01', 2200, 'COMPLETED');

INSERT INTO customer_updates VALUES
(1, 501, 'old501@example.com', '2026-08-01 09:00:00'),
(2, 501, 'new501@example.com', '2026-08-05 10:00:00'),
(3, 502, 'old502@example.com', '2026-08-02 09:00:00'),
(4, 502, 'new502@example.com', '2026-08-07 11:00:00'),
(5, 503, 'customer503@example.com', '2026-08-03 12:00:00');

/*
============================================================
Q1 — Basic CTE
============================================================
Find all completed orders using a CTE named completed_orders.
*/

/* Write your SQL here */


/*
============================================================
Q2 — Aggregation + CTE
============================================================
Calculate total completed-order amount for each customer.
Return only customers whose total is greater than 3,000.
*/

/* Write your SQL here */


/*
============================================================
Q3 — Multiple CTEs
============================================================
Using two CTEs:
1. Calculate customer total spend.
2. Rank customers by total spend.
Return the top 3 customers.
*/

/* Write your SQL here */


/*
============================================================
Q4 — Latest Record
============================================================
For each customer, return only their latest record from
customer_updates using ROW_NUMBER() inside a CTE.
*/

/* Write your SQL here */


/*
============================================================
Q5 — Above Department Average
============================================================
Find employees whose salary is greater than the average salary
of their own department.
Use a CTE to calculate department averages first.
*/

/* Write your SQL here */


/*
============================================================
Q6 — Department Summary
============================================================
Create a CTE that returns, for every department:
- employee count
- average salary
- maximum salary

Then return departments whose average salary is above 80,000.
*/

/* Write your SQL here */


/*
============================================================
Q7 — Employee Hierarchy
============================================================
Use a recursive CTE to display the complete employee hierarchy.
Return:
- employee_id
- employee_name
- manager_id
- hierarchy_level
*/

/* Write your SQL here */


/*
============================================================
Q8 — Hierarchy Reporting
============================================================
Using a recursive CTE, find all employees who ultimately report
under employee_id = 2.
*/

/* Write your SQL here */


/*
============================================================
Q9 — Monthly Sales
============================================================
Using a CTE, calculate completed sales by month.
Return:
- month
- total_orders
- total_sales
*/

/* Write your SQL here */


/*
============================================================
Q10 — Data Quality
============================================================
Using a CTE, calculate for each customer:
- total update records
- latest update timestamp

Return customers having more than one update record.
*/

/* Write your SQL here */


/*
============================================================
Q11 — CTE + Window Function
============================================================
For each department, find the highest-paid employee.
Use a CTE with ROW_NUMBER().
*/

/* Write your SQL here */


/*
============================================================
Q12 — Reconciliation
============================================================
Create two CTEs representing source and target metrics for
completed orders.
Compare:
- row count
- total amount

Return MATCH or MISMATCH.
*/

/* Write your SQL here */


/*
============================================================
Q13 — Recursive Number Generator
============================================================
Generate integers from 1 through 30 using a recursive CTE.
*/

/* Write your SQL here */


/*
============================================================
Q14 — Interview Scenario
============================================================
A customer can have multiple updates. Return the latest email
for every customer.
The solution must use a CTE and ROW_NUMBER().
*/

/* Write your SQL here */


/*
============================================================
Q15 — Interview Scenario
============================================================
Find departments where the total salary is greater than the
average department total salary.
Use multiple CTEs.
*/

/* Write your SQL here */