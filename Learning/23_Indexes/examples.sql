-- 23_Indexing — Examples
-- Run in a test database. Inspect plans with EXPLAIN before/after indexes.

CREATE DATABASE IF NOT EXISTS indexing_demo;
USE indexing_demo;

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id BIGINT PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    status VARCHAR(20) NOT NULL,
    created_at DATETIME NOT NULL
) ENGINE = InnoDB;

CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    order_date DATETIME NOT NULL,
    updated_at DATETIME NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) ENGINE = InnoDB;

INSERT INTO customers VALUES
(1, 'a@example.com', 'ACTIVE', '2026-01-01 10:00:00'),
(2, 'b@example.com', 'ACTIVE', '2026-01-02 10:00:00'),
(3, 'c@example.com', 'INACTIVE', '2026-01-03 10:00:00');

INSERT INTO orders VALUES
(1001, 1, '2026-08-01 09:00:00', '2026-08-01 09:30:00', 1200.00, 'PAID'),
(1002, 1, '2026-08-05 11:00:00', '2026-08-05 11:20:00', 800.00, 'PAID'),
(1003, 2, '2026-08-06 12:00:00', '2026-08-06 12:30:00', 2500.00, 'PENDING'),
(1004, 3, '2026-08-08 15:00:00', '2026-08-08 15:10:00', 400.00, 'CANCELLED');

-- 1. Inspect the plan before creating an index.
EXPLAIN
SELECT *
FROM orders
WHERE customer_id = 1;

-- 2. Create a single-column index for customer lookups.
CREATE INDEX idx_orders_customer
ON orders(customer_id);

EXPLAIN
SELECT *
FROM orders
WHERE customer_id = 1;

-- 3. Composite index for customer + date filtering.
CREATE INDEX idx_orders_customer_date
ON orders(customer_id, order_date);

EXPLAIN
SELECT order_id, order_date, amount
FROM orders
WHERE customer_id = 1
  AND order_date >= '2026-08-01'
  AND order_date < '2026-09-01'
ORDER BY order_date;

-- 4. Demonstrate the leading-column idea.
-- This query starts with customer_id, so the composite index is a natural candidate.
EXPLAIN
SELECT *
FROM orders
WHERE customer_id = 1
  AND order_date >= '2026-08-01';

-- This query only filters by order_date.
-- Check whether MySQL chooses the composite index; do not assume it will.
EXPLAIN
SELECT *
FROM orders
WHERE order_date >= '2026-08-01';

-- 5. Covering-index candidate for a narrow reporting query.
CREATE INDEX idx_orders_customer_date_amount
ON orders(customer_id, order_date, amount);

EXPLAIN
SELECT customer_id, order_date, amount
FROM orders
WHERE customer_id = 1
  AND order_date >= '2026-08-01';

-- 6. Join-key index.
EXPLAIN
SELECT
    o.order_id,
    c.email,
    o.amount
FROM orders o
JOIN customers c
    ON c.customer_id = o.customer_id
WHERE o.customer_id = 1;

-- 7. Sargable date-range predicate.
EXPLAIN
SELECT *
FROM orders
WHERE updated_at >= '2026-08-01 00:00:00'
  AND updated_at <  '2026-09-01 00:00:00';

CREATE INDEX idx_orders_updated_at
ON orders(updated_at);

EXPLAIN
SELECT *
FROM orders
WHERE updated_at >= '2026-08-01 00:00:00'
  AND updated_at <  '2026-09-01 00:00:00';

-- 8. Function-wrapped date comparison.
-- Compare this plan with the range form above.
EXPLAIN
SELECT *
FROM orders
WHERE DATE(updated_at) = '2026-08-01';

-- 9. Prefix vs leading-wildcard LIKE.
CREATE INDEX idx_customers_email
ON customers(email);

EXPLAIN
SELECT *
FROM customers
WHERE email LIKE 'a%';

EXPLAIN
SELECT *
FROM customers
WHERE email LIKE '%example.com';

-- 10. Inspect existing indexes.
SHOW INDEX FROM orders;
SHOW INDEX FROM customers;

-- 11. Unique business key.
CREATE UNIQUE INDEX ux_customers_email
ON customers(email);

-- 12. Optional: inspect actual execution behavior in a test environment.
-- EXPLAIN ANALYZE
-- SELECT order_id, order_date, amount
-- FROM orders
-- WHERE customer_id = 1
--   AND order_date >= '2026-08-01'
--   AND order_date < '2026-09-01'
-- ORDER BY order_date;

-- 13. Cleanup examples if needed.
-- DROP INDEX idx_orders_customer ON orders;
-- DROP INDEX idx_orders_customer_date ON orders;
-- DROP INDEX idx_orders_customer_date_amount ON orders;
-- DROP INDEX idx_orders_updated_at ON orders;
-- DROP INDEX ux_customers_email ON customers;
