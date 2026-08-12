-- ============================================================
-- MySQL Learning: 04 — Create and Alter Tables
-- ============================================================
-- Purpose: Worked examples for creating, inspecting, and
--          modifying table structures.
-- ============================================================

CREATE DATABASE IF NOT EXISTS table_learning_db;
USE table_learning_db;

-- 1. Create a basic table
DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    employee_id INT,
    employee_name VARCHAR(100),
    salary DECIMAL(10, 2)
);

-- Inspect the table
DESCRIBE employees;
SHOW CREATE TABLE employees;

-- 2. Create a table with common column attributes
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(255) UNIQUE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- 3. Add a column
ALTER TABLE employees
ADD COLUMN hire_date DATE;

-- 4. Add multiple columns
ALTER TABLE employees
ADD COLUMN department VARCHAR(50),
ADD COLUMN city VARCHAR(50);

-- 5. Modify a column definition
ALTER TABLE employees
MODIFY COLUMN salary DECIMAL(12, 2);

-- 6. Rename a column
ALTER TABLE employees
RENAME COLUMN employee_name TO full_name;

-- 7. Rename it back using CHANGE COLUMN
ALTER TABLE employees
CHANGE COLUMN full_name employee_name VARCHAR(100);

-- 8. Drop a column
ALTER TABLE employees
DROP COLUMN city;

-- 9. Rename a table
RENAME TABLE employees TO staff;

-- Rename it back
ALTER TABLE staff RENAME TO employees;

-- 10. Create a table with a default value
DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    order_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    order_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    order_date DATE NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'pending'
);

-- 11. Insert sample data
INSERT INTO orders (customer_id, order_amount, order_date)
VALUES
    (101, 1250.50, '2026-08-01'),
    (102, 499.99, '2026-08-02');

SELECT * FROM orders;

-- 12. Create a table from a query
DROP TABLE IF EXISTS order_backup;

CREATE TABLE order_backup AS
SELECT
    order_id,
    customer_id,
    order_amount,
    order_date
FROM orders;

DESCRIBE order_backup;
SELECT * FROM order_backup;

-- Note: CREATE TABLE ... AS SELECT should not be assumed to
-- reproduce primary keys, indexes, foreign keys, or every table property.

-- 13. Add a constraint after table creation
ALTER TABLE orders
ADD CONSTRAINT uq_orders_customer_date
UNIQUE (customer_id, order_date);

SHOW CREATE TABLE orders;

-- 14. Temporary table example
DROP TEMPORARY TABLE IF EXISTS staging_employees;

CREATE TEMPORARY TABLE staging_employees (
    employee_id INT,
    employee_name VARCHAR(100)
);

INSERT INTO staging_employees
VALUES
    (1, 'Aarav'),
    (2, 'Meera');

SELECT * FROM staging_employees;

-- 15. Fully qualified table reference
SELECT *
FROM table_learning_db.orders;

-- 16. Final inspection
SHOW TABLES;
DESCRIBE employees;
DESCRIBE orders;
SHOW CREATE TABLE employees;
SHOW CREATE TABLE orders;

-- ============================================================
-- Key Takeaways
-- ============================================================
-- CREATE TABLE  -> creates a new table
-- ALTER TABLE   -> changes an existing table structure
-- ADD COLUMN    -> adds a column
-- MODIFY COLUMN -> changes a column definition
-- CHANGE COLUMN -> renames and redefines a column
-- RENAME COLUMN -> renames a column
-- DROP COLUMN   -> removes a column and its data
-- SHOW CREATE TABLE -> shows the stored table definition
-- ============================================================
