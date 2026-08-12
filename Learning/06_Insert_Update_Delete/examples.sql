-- ============================================================
-- 06 — INSERT, UPDATE and DELETE
-- Worked Examples
-- ============================================================

CREATE DATABASE IF NOT EXISTS dml_lab;
USE dml_lab;

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- 1. Create sample tables.
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(50),
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    phone VARCHAR(20)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2) NOT NULL
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    total_amount DECIMAL(12,2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- 2. INSERT one row.
INSERT INTO customers (customer_id, customer_name, city, phone)
VALUES (1, 'Amit Sharma', 'Mumbai', '9876543210');

-- 3. INSERT multiple rows.
INSERT INTO customers (customer_id, customer_name, city, phone)
VALUES
    (2, 'Priya Patil', 'Pune', '9876500001'),
    (3, 'Rahul Mehta', 'Nashik', '9876500002'),
    (4, 'Neha Joshi', 'Mumbai', NULL);

SELECT * FROM customers;

-- 4. INSERT while using DEFAULT for status.
INSERT INTO customers (customer_id, customer_name, city)
VALUES (5, 'Karan Shah', 'Thane');

-- 5. UPDATE one row.
UPDATE customers
SET city = 'Nagpur'
WHERE customer_id = 3;

-- 6. UPDATE multiple columns.
UPDATE customers
SET city = 'Mumbai',
    phone = '9999999999'
WHERE customer_id = 4;

-- 7. Preview rows before a bulk UPDATE.
SELECT *
FROM customers
WHERE city = 'Mumbai';

UPDATE customers
SET status = 'verified'
WHERE city = 'Mumbai';

SELECT ROW_COUNT() AS rows_updated;

-- 8. UPDATE using an expression.
UPDATE products
SET price = price * 1.10
WHERE category = 'Electronics';

-- 9. UPDATE using CASE.
UPDATE customers
SET status = CASE
    WHEN city = 'Mumbai' THEN 'priority'
    WHEN city = 'Pune' THEN 'standard'
    ELSE status
END;

-- 10. UPDATE NULL values safely.
UPDATE customers
SET phone = '8888888888'
WHERE phone IS NULL;

-- 11. INSERT products.
INSERT INTO products (product_id, product_name, category, price)
VALUES
    (101, 'Keyboard', 'Electronics', 1200.00),
    (102, 'Mouse', 'Electronics', 700.00),
    (103, 'Notebook', 'Stationery', 120.00);

-- 12. INSERT orders.
INSERT INTO orders (order_id, customer_id, order_date, total_amount)
VALUES
    (1001, 1, '2026-08-01', 1900.00),
    (1002, 2, '2026-08-02', 120.00),
    (1003, 3, '2026-08-03', 700.00);

-- 13. Update order status.
UPDATE orders
SET status = 'confirmed'
WHERE order_id = 1001;

-- 14. DELETE one row after previewing it.
SELECT *
FROM customers
WHERE customer_id = 5;

DELETE FROM customers
WHERE customer_id = 5;

-- 15. DELETE multiple rows.
DELETE FROM orders
WHERE status = 'cancelled';

-- 16. INSERT ... SELECT for archival.
CREATE TABLE archived_orders AS
SELECT *
FROM orders
WHERE 1 = 0;

INSERT INTO archived_orders
SELECT *
FROM orders
WHERE order_date < '2026-08-02';

SELECT * FROM archived_orders;

-- 17. Transaction example.
START TRANSACTION;

UPDATE customers
SET status = 'active'
WHERE customer_id = 1;

UPDATE orders
SET status = 'processing'
WHERE order_id = 1001;

-- Validate before committing.
SELECT * FROM customers WHERE customer_id = 1;
SELECT * FROM orders WHERE order_id = 1001;

COMMIT;

-- 18. Rollback example.
START TRANSACTION;

UPDATE products
SET price = price * 2
WHERE product_id = 103;

SELECT * FROM products WHERE product_id = 103;

ROLLBACK;

-- 19. Upsert using INSERT ... ON DUPLICATE KEY UPDATE.
INSERT INTO customers (customer_id, customer_name, city)
VALUES (1, 'Amit Sharma Updated', 'Pune')
ON DUPLICATE KEY UPDATE
    customer_name = 'Amit Sharma Updated',
    city = 'Pune';

-- 20. Inspect the final state.
SELECT * FROM customers ORDER BY customer_id;
SELECT * FROM products ORDER BY product_id;
SELECT * FROM orders ORDER BY order_id;

-- Key takeaway:
-- Preview target rows, modify deliberately, validate affected-row counts,
-- and use transactions for changes that must succeed or fail together.
