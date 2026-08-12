-- ============================================================
-- Databases and Schemas - Worked Examples
-- MySQL
-- ============================================================

-- These examples create temporary learning databases.
-- Do NOT run DROP DATABASE commands in a production environment.

-- ============================================================
-- 1. Create a database
-- ============================================================
CREATE DATABASE IF NOT EXISTS company_db;

-- ============================================================
-- 2. Create a schema
-- In MySQL, SCHEMA is a synonym for DATABASE.
-- ============================================================
CREATE SCHEMA IF NOT EXISTS analytics_db;

-- ============================================================
-- 3. List databases visible to the current account
-- ============================================================
SHOW DATABASES;

-- ============================================================
-- 4. Select a database
-- ============================================================
USE company_db;

-- ============================================================
-- 5. Check the current database
-- ============================================================
SELECT DATABASE();

-- ============================================================
-- 6. Create a table in the selected database
-- ============================================================
DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100),
    department VARCHAR(100),
    salary DECIMAL(10, 2)
);

-- ============================================================
-- 7. List tables in the current database
-- ============================================================
SHOW TABLES;

-- ============================================================
-- 8. Create a table using a fully qualified database name
-- ============================================================
CREATE TABLE IF NOT EXISTS company_db.departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100)
);

-- ============================================================
-- 9. Query a table using a fully qualified name
-- ============================================================
SELECT *
FROM company_db.employees;

-- ============================================================
-- 10. Inspect table structure
-- ============================================================
DESCRIBE company_db.employees;

-- Equivalent short form:
DESC company_db.employees;

-- ============================================================
-- 11. Show the database creation statement
-- ============================================================
SHOW CREATE DATABASE company_db;

-- ============================================================
-- 12. Database metadata from INFORMATION_SCHEMA
-- ============================================================
SELECT
    SCHEMA_NAME,
    DEFAULT_CHARACTER_SET_NAME,
    DEFAULT_COLLATION_NAME
FROM information_schema.SCHEMATA
WHERE SCHEMA_NAME = 'company_db';

-- ============================================================
-- 13. List tables from a specific database
-- ============================================================
SHOW TABLES FROM company_db;

-- ============================================================
-- 14. Create a database with explicit character set/collation
-- ============================================================
CREATE DATABASE IF NOT EXISTS customer_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

-- ============================================================
-- 15. Inspect the new database defaults
-- ============================================================
SELECT
    SCHEMA_NAME,
    DEFAULT_CHARACTER_SET_NAME,
    DEFAULT_COLLATION_NAME
FROM information_schema.SCHEMATA
WHERE SCHEMA_NAME = 'customer_db';

-- ============================================================
-- 16. Cross-database object reference
-- ============================================================
CREATE TABLE IF NOT EXISTS customer_db.customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100)
);

INSERT INTO customer_db.customers (customer_id, customer_name)
VALUES
    (1, 'Amit'),
    (2, 'Priya');

SELECT *
FROM customer_db.customers;

-- ============================================================
-- 17. Switch database and verify
-- ============================================================
USE customer_db;
SELECT DATABASE();

-- ============================================================
-- 18. Return to company_db
-- ============================================================
USE company_db;
SELECT DATABASE();

-- ============================================================
-- 19. Database metadata: list all schemas
-- ============================================================
SELECT
    SCHEMA_NAME
FROM information_schema.SCHEMATA
ORDER BY SCHEMA_NAME;

-- ============================================================
-- 20. Safe cleanup of learning databases
-- Run only when you no longer need the examples.
-- ============================================================
-- DROP DATABASE IF EXISTS company_db;
-- DROP DATABASE IF EXISTS analytics_db;
-- DROP DATABASE IF EXISTS customer_db;

-- ============================================================
-- Key Takeaways
-- ============================================================
-- Database / Schema → logical container in MySQL
-- SHOW DATABASES    → list visible databases
-- USE db_name       → select current database
-- DATABASE()        → show current database
-- db.table          → fully qualified object name
-- INFORMATION_SCHEMA → database metadata
