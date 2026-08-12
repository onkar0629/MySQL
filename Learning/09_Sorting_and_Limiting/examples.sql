-- ============================================================
-- 09 — Sorting and Limiting
-- Worked Examples
-- ============================================================

CREATE DATABASE IF NOT EXISTS mysql_learning_09;
USE mysql_learning_09;

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    amount DECIMAL(10,2),
    status VARCHAR(20),
    order_date DATETIME
);

INSERT INTO orders VALUES
(101, 'Amit', 'Electronics', 1500.00, 'completed', '2026-08-01 10:00:00'),
(102, 'Priya', 'Books', 500.00, 'completed', '2026-08-01 15:30:00'),
(103, 'Rahul', 'Electronics', 2500.00, 'cancelled', '2026-08-02 09:00:00'),
(104, 'Sneha', 'Furniture', 4000.00, 'completed', '2026-08-02 12:00:00'),
(105, 'Vikas', NULL, NULL, 'pending', '2026-08-03 18:00:00'),
(106, 'Neha', 'Books', 500.00, 'completed', '2026-08-03 23:00:00'),
(107, 'Riya', 'Electronics', 2500.00, 'completed', '2026-08-04 08:00:00');

-- 1. Ascending order
SELECT *
FROM orders
ORDER BY amount ASC;

-- 2. Descending order
SELECT *
FROM orders
ORDER BY amount DESC;

-- 3. Multiple sort keys
SELECT *
FROM orders
ORDER BY category ASC, amount DESC, order_id ASC;

-- 4. Sort using a calculated expression
SELECT order_id, amount, amount * 12 AS annualized_amount
FROM orders
ORDER BY annualized_amount DESC;

-- 5. Top 3 orders
SELECT order_id, customer_name, amount
FROM orders
ORDER BY amount DESC, order_id ASC
LIMIT 3;

-- 6. Bottom 3 orders
SELECT order_id, customer_name, amount
FROM orders
WHERE amount IS NOT NULL
ORDER BY amount ASC, order_id ASC
LIMIT 3;

-- 7. LIMIT with OFFSET
SELECT order_id, customer_name, amount
FROM orders
ORDER BY order_id ASC
LIMIT 2 OFFSET 2;

-- 8. Explicit NULL ordering: non-NULL values first
SELECT order_id, amount
FROM orders
ORDER BY (amount IS NULL), amount DESC, order_id ASC;

-- 9. Latest order
SELECT *
FROM orders
ORDER BY order_date DESC, order_id DESC
LIMIT 1;

-- 10. Latest five completed orders
SELECT *
FROM orders
WHERE status = 'completed'
ORDER BY order_date DESC, order_id DESC
LIMIT 5;

-- 11. Simple page: rows 21-30
SELECT *
FROM orders
ORDER BY order_id ASC
LIMIT 10 OFFSET 20;

-- 12. Keyset pagination example
-- Continue after the last seen order_id = 103.
SELECT *
FROM orders
WHERE order_id > 103
ORDER BY order_id ASC
LIMIT 3;

-- 13. Composite keyset pagination for descending timestamp order
SELECT *
FROM orders
WHERE (order_date, order_id) < ('2026-08-03 23:00:00', 106)
ORDER BY order_date DESC, order_id DESC
LIMIT 3;

-- 14. Find the three most recent completed orders with ties handled
SELECT order_id, customer_name, order_date
FROM orders
WHERE status = 'completed'
ORDER BY order_date DESC, order_id DESC
LIMIT 3;

-- 15. Deterministic sorting for equal amounts
SELECT order_id, customer_name, amount
FROM orders
ORDER BY amount DESC, order_id ASC;

-- Key takeaway:
-- LIMIT chooses how many rows to return; ORDER BY determines which
-- rows are meaningfully first. Always use stable tie-breakers when
-- the result is used for pagination or production processing.
