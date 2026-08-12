-- ============================================================
-- 11 — GROUP BY and HAVING | Worked Examples
-- ============================================================

DROP DATABASE IF EXISTS mysql_learning_11;
CREATE DATABASE mysql_learning_11;
USE mysql_learning_11;

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100),
    department VARCHAR(50),
    job_title VARCHAR(50),
    salary DECIMAL(12,2),
    manager_id INT NULL
);

INSERT INTO employees VALUES
(1,'Asha','Engineering','Data Engineer',90000,NULL),
(2,'Rahul','Engineering','Data Engineer',85000,1),
(3,'Neha','Engineering','Analyst',70000,1),
(4,'Vikram','Sales','Sales Executive',65000,NULL),
(5,'Priya','Sales','Sales Executive',72000,4),
(6,'Arjun','Sales','Manager',110000,NULL),
(7,'Meera','HR','HR Executive',60000,NULL),
(8,'Karan',NULL,'Intern',30000,NULL);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    amount DECIMAL(12,2)
);

INSERT INTO orders VALUES
(101,1,'2026-01-05',1200.00),
(102,1,'2026-01-15',800.00),
(103,2,'2026-01-20',2500.00),
(104,2,'2026-02-03',1500.00),
(105,3,'2026-02-10',4000.00),
(106,3,'2026-02-15',500.00),
(107,3,'2026-03-01',1000.00),
(108,4,'2026-03-03',700.00);

-- 1. Count employees per department
SELECT department, COUNT(*) AS employee_count
FROM employees
GROUP BY department;

-- 2. Average salary per department
SELECT department, AVG(salary) AS avg_salary
FROM employees
GROUP BY department;

-- 3. Multiple aggregates per department
SELECT
    department,
    COUNT(*) AS employee_count,
    MIN(salary) AS min_salary,
    MAX(salary) AS max_salary,
    AVG(salary) AS avg_salary
FROM employees
GROUP BY department;

-- 4. Group by department and job title
SELECT department, job_title, COUNT(*) AS employee_count
FROM employees
GROUP BY department, job_title;

-- 5. Filter rows before grouping
SELECT department, COUNT(*) AS employee_count
FROM employees
WHERE salary >= 70000
GROUP BY department;

-- 6. Filter groups after aggregation
SELECT department, COUNT(*) AS employee_count
FROM employees
GROUP BY department
HAVING COUNT(*) >= 2;

-- 7. Departments with average salary above 75000
SELECT department, AVG(salary) AS avg_salary
FROM employees
GROUP BY department
HAVING AVG(salary) > 75000;

-- 8. Customers with more than two orders
SELECT customer_id, COUNT(*) AS order_count
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > 2;

-- 9. Total spending per customer
SELECT customer_id, SUM(amount) AS total_spend
FROM orders
GROUP BY customer_id;

-- 10. Customers whose total spending exceeds 3000
SELECT customer_id, SUM(amount) AS total_spend
FROM orders
GROUP BY customer_id
HAVING SUM(amount) > 3000;

-- 11. Monthly order totals
SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    COUNT(*) AS order_count,
    SUM(amount) AS total_sales
FROM orders
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY order_year, order_month;

-- 12. Conditional aggregation
SELECT
    department,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN salary >= 80000 THEN 1 ELSE 0 END) AS high_earners
FROM employees
GROUP BY department;

-- 13. COUNT(*) versus COUNT(manager_id)
SELECT
    department,
    COUNT(*) AS total_rows,
    COUNT(manager_id) AS employees_with_manager
FROM employees
GROUP BY department;

-- 14. Find duplicate customer IDs in orders
SELECT customer_id, COUNT(*) AS duplicate_count
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- 15. Data Engineering-style batch aggregation
CREATE TABLE pipeline_events (
    event_id INT PRIMARY KEY,
    batch_id INT,
    status VARCHAR(20),
    records_processed INT
);

INSERT INTO pipeline_events VALUES
(1,1001,'SUCCESS',1000),
(2,1001,'SUCCESS',1200),
(3,1001,'FAILED',0),
(4,1002,'SUCCESS',1500),
(5,1002,'SUCCESS',1600),
(6,1003,'FAILED',0);

SELECT
    batch_id,
    COUNT(*) AS event_count,
    SUM(records_processed) AS records_processed
FROM pipeline_events
GROUP BY batch_id;

-- 16. Find batches with no successful event
SELECT batch_id
FROM pipeline_events
GROUP BY batch_id
HAVING SUM(CASE WHEN status = 'SUCCESS' THEN 1 ELSE 0 END) = 0;

-- 17. Important: inspect join grain before aggregating.
-- The following pattern can inflate totals if the join is one-to-many.
CREATE TABLE order_items (
    item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT
);

INSERT INTO order_items VALUES
(1,101,501,2),
(2,101,502,1),
(3,102,503,3),
(4,103,504,1);

SELECT
    o.order_id,
    COUNT(oi.item_id) AS item_count
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY o.order_id;

-- 18. Sort grouped results by aggregate
SELECT customer_id, SUM(amount) AS total_spend
FROM orders
GROUP BY customer_id
ORDER BY total_spend DESC;

-- 19. HAVING with multiple conditions
SELECT department, AVG(salary) AS avg_salary, COUNT(*) AS employee_count
FROM employees
GROUP BY department
HAVING COUNT(*) >= 2
   AND AVG(salary) > 70000;

-- 20. Final challenge: departments with at least two employees
-- and a maximum salary above 90000.
SELECT
    department,
    COUNT(*) AS employee_count,
    MAX(salary) AS max_salary
FROM employees
GROUP BY department
HAVING COUNT(*) >= 2
   AND MAX(salary) > 90000;

-- ============================================================
-- Key Takeaways
-- ============================================================
-- 1. WHERE filters rows before GROUP BY.
-- 2. HAVING filters groups after aggregation.
-- 3. Always identify the business grain before grouping.
-- 4. COUNT(*) and COUNT(column) behave differently with NULL.
-- 5. Check JOIN cardinality before calculating SUM/COUNT.
