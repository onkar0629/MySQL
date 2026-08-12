-- 20_Views — Examples

CREATE DATABASE IF NOT EXISTS views_demo;
USE views_demo;

DROP VIEW IF EXISTS customer_order_summary;
DROP VIEW IF EXISTS active_customers;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150),
    status VARCHAR(20) NOT NULL
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO customers VALUES
(1, 'Amit', 'amit@example.com', 'ACTIVE'),
(2, 'Neha', 'neha@example.com', 'ACTIVE'),
(3, 'Rahul', 'rahul@example.com', 'INACTIVE');

INSERT INTO orders VALUES
(101, 1, '2026-08-01', 1200),
(102, 1, '2026-08-03', 800),
(103, 2, '2026-08-05', 2500);

-- 1. Simple filtered view
CREATE VIEW active_customers AS
SELECT
    customer_id,
    customer_name,
    email
FROM customers
WHERE status = 'ACTIVE';

SELECT *
FROM active_customers;

-- 2. View over a join and aggregation
CREATE VIEW customer_order_summary AS
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS order_count,
    COALESCE(SUM(o.amount), 0) AS total_spend
FROM customers c
LEFT JOIN orders o
    ON o.customer_id = c.customer_id
GROUP BY
    c.customer_id,
    c.customer_name;

SELECT *
FROM customer_order_summary;

-- 3. Filter a view like a table
SELECT
    customer_id,
    customer_name,
    total_spend
FROM customer_order_summary
WHERE total_spend >= 2000
ORDER BY total_spend DESC;

-- 4. Replace a view definition
CREATE OR REPLACE VIEW active_customers AS
SELECT
    customer_id,
    customer_name,
    email,
    status
FROM customers
WHERE status = 'ACTIVE';

-- 5. Inspect view definitions
SHOW CREATE VIEW active_customers;
SHOW CREATE VIEW customer_order_summary;

-- 6. Drop views when no longer needed
-- DROP VIEW IF EXISTS active_customers;
-- DROP VIEW IF EXISTS customer_order_summary;

-- Key lessons:
-- * Views provide reusable query definitions.
-- * A normal view should not be treated as stored result data.
-- * Keep view interfaces stable and expose only required columns.
-- * Always inspect the underlying query when troubleshooting performance.