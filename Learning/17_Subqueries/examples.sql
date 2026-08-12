-- 17_Subqueries — Examples
-- Practical MySQL examples for learning and Data Engineering interviews.

CREATE DATABASE IF NOT EXISTS subqueries_demo;
USE subqueries_demo;

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL
);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    department_id INT,
    salary DECIMAL(10,2),
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL
);

INSERT INTO departments VALUES
(1, 'Data Engineering'),
(2, 'Analytics'),
(3, 'Finance');

INSERT INTO employees VALUES
(101, 'Amit', 1, 85000),
(102, 'Neha', 1, 72000),
(103, 'Rahul', 2, 65000),
(104, 'Priya', 2, 90000),
(105, 'Karan', 3, 60000);

INSERT INTO orders VALUES
(1001, 501, '2026-08-01', 1200),
(1002, 501, '2026-08-05', 800),
(1003, 502, '2026-08-06', 2500),
(1004, 503, '2026-08-08', 400),
(1005, 502, '2026-08-10', 1800);

-- 1. Scalar subquery: employees earning above the company average.
SELECT
    employee_id,
    employee_name,
    salary
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
);

-- 2. Subquery with IN: employees belonging to departments
--    whose average salary is above 70000.
SELECT
    employee_id,
    employee_name,
    department_id,
    salary
FROM employees
WHERE department_id IN (
    SELECT department_id
    FROM employees
    GROUP BY department_id
    HAVING AVG(salary) > 70000
);

-- 3. EXISTS: customers who have at least one order.
SELECT DISTINCT o.customer_id
FROM orders o
WHERE EXISTS (
    SELECT 1
    FROM orders o2
    WHERE o2.customer_id = o.customer_id
);

-- 4. NOT EXISTS: customers represented in a customer list
--    but having no matching order would follow the same pattern.
--    This example uses a derived customer set for demonstration.
SELECT c.customer_id
FROM (
    SELECT DISTINCT customer_id
    FROM orders
) c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
      AND o.amount > 5000
);

-- 5. Derived table: aggregate first, then filter.
SELECT
    department_id,
    avg_salary
FROM (
    SELECT
        department_id,
        AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
) dept_summary
WHERE avg_salary > 70000;

-- 6. Subquery in SELECT: show each employee's salary
--    alongside the company average.
SELECT
    employee_name,
    salary,
    (
        SELECT AVG(salary)
        FROM employees
    ) AS company_avg_salary
FROM employees;

-- 7. Correlated subquery: highest-paid employee(s) in each department.
SELECT
    e.employee_id,
    e.employee_name,
    e.department_id,
    e.salary
FROM employees e
WHERE e.salary = (
    SELECT MAX(e2.salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id
);

-- 8. NOT EXISTS anti-join pattern.
--    Find departments with no employee earning more than 100000.
SELECT
    d.department_id,
    d.department_name
FROM departments d
WHERE NOT EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department_id = d.department_id
      AND e.salary > 100000
);

-- 9. Nested subquery: customers whose total spend is
--    above the average customer spend.
SELECT
    customer_id,
    SUM(amount) AS total_spend
FROM orders
GROUP BY customer_id
HAVING SUM(amount) > (
    SELECT AVG(customer_total)
    FROM (
        SELECT
            customer_id,
            SUM(amount) AS customer_total
        FROM orders
        GROUP BY customer_id
    ) totals
);

-- 10. Subquery for duplicate business keys.
SELECT
    customer_id
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Key lessons:
-- * Use scalar subqueries for a single calculated value.
-- * Use IN when comparing against a set of values.
-- * Prefer EXISTS / NOT EXISTS for existence and anti-join logic.
-- * Use derived tables when an intermediate result needs to be queried.
-- * Correlated subqueries depend on the current outer row and may be expensive.
-- * Always consider JOIN/CTE alternatives and verify performance with EXPLAIN.