-- ============================================================
-- MySQL Data Types - Worked Examples
-- ============================================================

CREATE DATABASE IF NOT EXISTS data_types_demo;
USE data_types_demo;

DROP TABLE IF EXISTS employees;

-- ============================================================
-- 1. Integer types
-- ============================================================
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    age TINYINT UNSIGNED,
    years_experience SMALLINT UNSIGNED,
    employee_count BIGINT UNSIGNED
);

INSERT INTO employees
VALUES (101, 25, 3, 1);

SELECT * FROM employees;

-- ============================================================
-- 2. DECIMAL for exact values
-- ============================================================
DROP TABLE IF EXISTS products;

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(10, 2)
);

INSERT INTO products
VALUES
    (1, 'Keyboard', 2499.99),
    (2, 'Mouse', 799.50);

SELECT
    product_name,
    price
FROM products;

-- ============================================================
-- 3. FLOAT and DOUBLE
-- ============================================================
DROP TABLE IF EXISTS measurements;

CREATE TABLE measurements (
    measurement_id INT PRIMARY KEY,
    sensor_value FLOAT,
    precise_measurement DOUBLE
);

INSERT INTO measurements
VALUES (1, 12.3456, 12.3456789012);

SELECT * FROM measurements;

-- ============================================================
-- 4. CHAR vs VARCHAR
-- ============================================================
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    country_code CHAR(2),
    user_name VARCHAR(100),
    email VARCHAR(255)
);

INSERT INTO users
VALUES
    (1, 'IN', 'Onkar', 'onkar@example.com'),
    (2, 'US', 'Alex', 'alex@example.com');

SELECT * FROM users;

-- ============================================================
-- 5. TEXT
-- ============================================================
DROP TABLE IF EXISTS articles;

CREATE TABLE articles (
    article_id INT PRIMARY KEY,
    title VARCHAR(200),
    content TEXT
);

INSERT INTO articles
VALUES
    (1, 'MySQL Basics', 'SQL is used to work with relational data.');

SELECT * FROM articles;

-- ============================================================
-- 6. DATE, TIME and DATETIME
-- ============================================================
DROP TABLE IF EXISTS events;

CREATE TABLE events (
    event_id INT PRIMARY KEY,
    event_date DATE,
    start_time TIME,
    created_at DATETIME
);

INSERT INTO events
VALUES
    (1, '2026-08-12', '09:30:00', '2026-08-12 09:30:00');

SELECT * FROM events;

-- ============================================================
-- 7. TIMESTAMP
-- ============================================================
DROP TABLE IF EXISTS audit_log;

CREATE TABLE audit_log (
    log_id INT PRIMARY KEY,
    event_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO audit_log (log_id, event_name)
VALUES (1, 'record_created');

SELECT * FROM audit_log;

-- ============================================================
-- 8. BOOLEAN
-- ============================================================
DROP TABLE IF EXISTS accounts;

CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    account_name VARCHAR(100),
    is_active BOOLEAN
);

INSERT INTO accounts
VALUES
    (1, 'Account A', TRUE),
    (2, 'Account B', FALSE);

SELECT * FROM accounts;

-- ============================================================
-- 9. ENUM
-- ============================================================
DROP TABLE IF EXISTS jobs;

CREATE TABLE jobs (
    job_id INT PRIMARY KEY,
    status ENUM('pending', 'running', 'completed', 'failed')
);

INSERT INTO jobs
VALUES
    (1, 'running'),
    (2, 'completed');

SELECT * FROM jobs;

-- ============================================================
-- 10. SET
-- ============================================================
DROP TABLE IF EXISTS developers;

CREATE TABLE developers (
    developer_id INT PRIMARY KEY,
    skills SET('SQL', 'Python', 'Spark', 'Hadoop')
);

INSERT INTO developers
VALUES
    (1, 'SQL,Python,Spark'),
    (2, 'SQL,Hadoop');

SELECT * FROM developers;

-- ============================================================
-- 11. JSON
-- ============================================================
DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    metadata JSON
);

INSERT INTO orders
VALUES
    (1001, '{"source":"api","priority":"high"}');

SELECT * FROM orders;

-- Extract a JSON attribute.
SELECT
    order_id,
    metadata->>'$.source' AS source
FROM orders;

-- ============================================================
-- 12. BINARY / VARBINARY
-- ============================================================
DROP TABLE IF EXISTS binary_demo;

CREATE TABLE binary_demo (
    id INT PRIMARY KEY,
    hash_value VARBINARY(32)
);

INSERT INTO binary_demo
VALUES (1, UNHEX('A1B2C3D4'));

SELECT * FROM binary_demo;

-- ============================================================
-- 13. Data type selection - practical table
-- ============================================================
DROP TABLE IF EXISTS orders_demo;

CREATE TABLE orders_demo (
    order_id BIGINT,
    customer_id BIGINT,
    order_amount DECIMAL(12, 2),
    order_date DATE,
    created_at DATETIME,
    status VARCHAR(30),
    metadata JSON
);

INSERT INTO orders_demo
VALUES
    (10000000001, 501, 12999.95, '2026-08-12', '2026-08-12 10:15:00', 'completed', '{"source":"web"}');

SELECT * FROM orders_demo;

-- ============================================================
-- 14. Inspect column definitions
-- ============================================================
DESCRIBE orders_demo;

SHOW CREATE TABLE orders_demo;

-- ============================================================
-- 15. NULL and data types
-- ============================================================
DROP TABLE IF EXISTS nullable_demo;

CREATE TABLE nullable_demo (
    id INT PRIMARY KEY,
    score DECIMAL(5, 2),
    note VARCHAR(100)
);

INSERT INTO nullable_demo (id, score, note)
VALUES (1, NULL, NULL);

SELECT
    id,
    score,
    note
FROM nullable_demo;

-- NULL is not the same as zero or an empty string.
SELECT
    NULL AS null_value,
    0 AS zero_value,
    '' AS empty_string;

-- ============================================================
-- Key takeaway:
-- Choose data types based on correctness first,
-- then consider storage, performance, and query patterns.
-- ============================================================
