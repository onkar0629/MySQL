-- 16_Joins: worked examples

CREATE DATABASE IF NOT EXISTS sql_learning_16;
USE sql_learning_16;

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    city VARCHAR(30)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    amount DECIMAL(10,2)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    category VARCHAR(30)
);

INSERT INTO customers VALUES
(1,'Asha','Mumbai'),
(2,'Rahul','Pune'),
(3,'Meera','Delhi'),
(4,'Vikram','Mumbai'),
(5,'Neha','Nashik');

INSERT INTO orders VALUES
(101,1,'2026-08-01',1200.00),
(102,1,'2026-08-05',800.00),
(103,2,'2026-08-03',1500.00),
(104,4,'2026-08-07',500.00),
(105,99,'2026-08-08',700.00);

INSERT INTO products VALUES
(1,'Laptop','Electronics'),
(2,'Keyboard','Electronics'),
(3,'Chair','Furniture');

-- 1. INNER JOIN: customers with orders.
SELECT c.customer_id, c.customer_name, o.order_id, o.amount
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id;

-- 2. LEFT JOIN: all customers, including customers without orders.
SELECT c.customer_id, c.customer_name, o.order_id
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id;

-- 3. Find customers without orders.
SELECT c.customer_id, c.customer_name
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- 4. RIGHT JOIN: all orders, including orphan orders.
SELECT c.customer_name, o.order_id, o.amount
FROM customers c
RIGHT JOIN orders o
    ON c.customer_id = o.customer_id;

-- 5. Find orphan orders.
SELECT o.order_id, o.customer_id
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- 6. CROSS JOIN: every customer-product combination.
SELECT c.customer_name, p.product_name
FROM customers c
CROSS JOIN products p;

-- 7. Filter inside ON to preserve unmatched customers.
SELECT c.customer_name, o.order_id, o.amount
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
   AND o.amount >= 1000;

-- 8. The WHERE version removes customers without qualifying orders.
SELECT c.customer_name, o.order_id, o.amount
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.amount >= 1000;

-- 9. Aggregate after a one-to-many join.
SELECT
    c.customer_id,
    c.customer_name,
    COALESCE(SUM(o.amount), 0) AS total_spend
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

-- 10. Count orders per customer without losing zero-order customers.
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS order_count
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

-- 11. Reconciliation-style classification.
SELECT
    o.order_id,
    CASE
        WHEN c.customer_id IS NULL THEN 'ORPHAN'
        ELSE 'MATCHED'
    END AS reconciliation_status
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id;

DROP DATABASE sql_learning_16;
