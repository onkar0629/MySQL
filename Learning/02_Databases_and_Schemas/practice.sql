-- ============================================================
-- Databases and Schemas - Practice
-- MySQL
-- ============================================================

-- Instructions:
-- 1. Try each exercise yourself before checking examples.sql.
-- 2. Run the statements in a safe learning environment.
-- 3. Do not execute DROP DATABASE against production databases.
-- 4. Write your SQL below each question.

-- ============================================================
-- Q1. Create a database named data_engineering_db.
-- ============================================================


-- ============================================================
-- Q2. Create a schema named analytics_db if it does not exist.
-- ============================================================


-- ============================================================
-- Q3. List all databases visible to your MySQL account.
-- ============================================================


-- ============================================================
-- Q4. Select data_engineering_db as the current database.
-- ============================================================


-- ============================================================
-- Q5. Write a query to display the currently selected database.
-- ============================================================


-- ============================================================
-- Q6. Create a table named employees inside data_engineering_db.
-- Columns:
-- employee_id INT PRIMARY KEY
-- employee_name VARCHAR(100)
-- department VARCHAR(100)
-- salary DECIMAL(10,2)
-- ============================================================


-- ============================================================
-- Q7. List all tables in data_engineering_db.
-- ============================================================


-- ============================================================
-- Q8. Describe data_engineering_db.employees.
-- ============================================================


-- ============================================================
-- Q9. Query data_engineering_db.employees using a fully qualified name.
-- ============================================================


-- ============================================================
-- Q10. Create a table named departments in data_engineering_db
-- WITHOUT first using USE data_engineering_db.
-- ============================================================


-- ============================================================
-- Q11. Query INFORMATION_SCHEMA.SCHEMATA to return:
-- schema name
-- default character set
-- default collation
-- ============================================================


-- ============================================================
-- Q12. Filter INFORMATION_SCHEMA.SCHEMATA to show only
-- data_engineering_db.
-- ============================================================


-- ============================================================
-- Q13. Create a database named unicode_demo with utf8mb4.
-- Use an appropriate utf8mb4 collation supported by your MySQL version.
-- ============================================================


-- ============================================================
-- Q14. Explain in SQL comments why database and schema are synonyms
-- in MySQL but may mean different things in other RDBMS products.
-- ============================================================


-- ============================================================
-- Q15. Assume sales_db and reporting_db both contain a table named
-- orders. Write two queries that clearly identify which database
-- each orders table belongs to.
-- ============================================================


-- ============================================================
-- Interview Practice
-- ============================================================

-- Q16. What is the difference between a database and a schema in MySQL?
-- Write your answer as SQL comments.


-- Q17. What does USE database_name do?
-- Write your answer as SQL comments.


-- Q18. Why should you run SELECT DATABASE() before a destructive
-- operation when working with unqualified object names?
-- Write your answer as SQL comments.


-- Q19. What is INFORMATION_SCHEMA and why is it useful for Data Engineers?
-- Write your answer as SQL comments.


-- Q20. What is a fully qualified table name?
-- Give one example in SQL comments.


-- ============================================================
-- Business Challenge
-- ============================================================

-- Q21. You are preparing a MySQL development environment for an
-- e-commerce project.
--
-- Create a database named ecommerce_dev.
-- Then create these tables inside it:
--
-- customers(customer_id, customer_name, email)
-- products(product_id, product_name, price)
-- orders(order_id, customer_id, order_date)
--
-- Use appropriate basic MySQL data types and primary keys.
-- Do not add foreign keys yet; that is covered in a later topic.


-- ============================================================
-- Q22. Environment Safety Challenge
-- ============================================================
-- Write SQL that:
-- 1. Creates staging_db only if it does not exist.
-- 2. Selects staging_db.
-- 3. Verifies that staging_db is the current database.
-- 4. Lists its tables.
--
-- Do not drop the database.


-- ============================================================
-- Q23. Metadata Challenge
-- ============================================================
-- Write one query against INFORMATION_SCHEMA.SCHEMATA that returns
-- all schemas whose name contains the word 'db'.


-- ============================================================
-- Q24. Cross-Database Challenge
-- ============================================================
-- Assume company_db.employees exists.
-- Write a query that reads employee_name and department without
-- changing the current database with USE.


-- ============================================================
-- Final Interview Challenge
-- ============================================================

-- Q25. An interviewer asks:
-- "You are connected to a MySQL server containing sales_db,
-- analytics_db, and reporting_db. You need to inspect analytics_db
-- without accidentally querying sales_db. What commands would you
-- use, and how would you verify the active database?"
--
-- Write the SQL commands and explain your reasoning using comments.
