-- ============================================================
-- 07 — SELECT and Filtering
-- Worked Examples
-- ============================================================

CREATE DATABASE IF NOT EXISTS select_filtering_lab;
USE select_filtering_lab;

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(255),
    city VARCHAR(50),
    status VARCHAR(20),
    signup_date DATE
);

INSERT INTO customers VALUES
(1, 'Amit Sharma', 'amit@example.com', 'Mumbai', 'active', '2026-01-10'),
(2, 'Priya Patil', 'priya@example.com', 'Pune', 'active', '2026-02-15'),
(3, 'Rahul Mehta', NULL, 'Mumbai', 'inactive', '2026-03-05'),
(4, 'Neha Joshi', 'neha@example.com', 'Nashik', 'active', '2026-04-20');

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    stock_qty INT
);

INSERT INTO products VALUES
(101, 'Keyboard', 'Electronics', 1200.00, 25),
(102, 'Mouse', 'Electronics', 700.00, 50),
(103, 'Notebook', 'Stationery', 150.00, 100),
(104, 'Monitor', 'Electronics', 12000.00, 8),
(105, 'Pen', 'Stationery', 50.00, 200);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100),
    department_id INT,
    job_title VARCHAR(100),
    salary DECIMAL(12,2),
    manager_id INT NULL
);

INSERT INTO employees VALUES
(1, 'Amit', 10, 'Data Engineer', 85000, NULL),
(2, 'Priya', 10, 'Senior Data Engineer', 105000, 1),
(3, 'Rahul', 20, 'Analyst', 70000, NULL),
(4, 'Neha', 30, 'Data Engineer', 90000, 1),
(5, 'Vikas', 20, 'Senior Analyst', 95000, 3);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATETIME,
    amount DECIMAL(12,2),
    status VARCHAR(20)
);

INSERT INTO orders VALUES
(1001, 1, '2026-08-01 10:15:00', 2500.00, 'completed'),
(1002, 2, '2026-08-05 14:30:00', 1200.00, 'pending'),
(1003, 1, '2026-08-12 09:00:00', 5000.00, 'completed'),
(1004, 4, '2026-09-01 11:20:00', 1800.00, 'completed');

SELECT customer_id, customer_name, city FROM customers;
SELECT * FROM products;
SELECT customer_name AS name, email AS customer_email FROM customers;
SELECT product_name, price, price * 1.18 AS price_with_tax FROM products;
SELECT * FROM products WHERE price >= 1000;
SELECT * FROM customers WHERE city = 'Mumbai';
SELECT * FROM employees WHERE department_id <> 10;
SELECT * FROM employees WHERE department_id = 10 AND salary >= 90000;
SELECT * FROM employees WHERE department_id IN (10, 20);
SELECT * FROM employees WHERE department_id NOT IN (10, 20);
SELECT * FROM products WHERE price BETWEEN 500 AND 2000;
SELECT * FROM customers WHERE customer_name LIKE 'A%';
SELECT * FROM customers WHERE customer_name LIKE '%ha%';
SELECT * FROM customers WHERE email IS NULL;
SELECT * FROM employees WHERE manager_id IS NOT NULL;
SELECT DISTINCT city FROM customers;
SELECT DISTINCT department_id, job_title FROM employees;
SELECT * FROM customers WHERE signup_date BETWEEN '2026-01-01' AND '2026-03-31';
SELECT * FROM orders WHERE order_date >= '2026-08-01' AND order_date < '2026-09-01';
SELECT * FROM products WHERE price * 1.18 > 1000;
SELECT customer_id, customer_name FROM customers WHERE status = 'active' AND city = 'Mumbai';
SELECT order_id, customer_id, amount FROM orders WHERE status = 'completed' AND amount >= 2500;
SELECT product_id, product_name, stock_qty FROM products WHERE stock_qty < 20;
SELECT customer_id, customer_name FROM customers WHERE email IS NULL;
SELECT * FROM orders WHERE order_date >= '2026-08-12 00:00:00' AND order_date < '2026-08-13 00:00:00';
SELECT 10 + 20 AS total;

SELECT c.customer_id, c.customer_name
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);

-- Key takeaway:
-- SELECT chooses what to return; WHERE determines which rows qualify.
