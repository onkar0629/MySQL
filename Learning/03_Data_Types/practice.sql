-- ============================================================
-- MySQL Data Types - Practice
-- ============================================================

-- Instructions:
-- 1. Try each exercise without looking at examples.sql.
-- 2. Write your solution below each question.
-- 3. Focus on choosing the correct data type, not just making SQL run.

CREATE DATABASE IF NOT EXISTS data_types_practice;
USE data_types_practice;

DROP TABLE IF EXISTS products;

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(10, 2),
    quantity INT UNSIGNED,
    launch_date DATE,
    created_at DATETIME,
    is_active BOOLEAN
);

INSERT INTO products
VALUES
    (101, 'Keyboard', 2499.99, 50, '2026-01-10', '2026-01-10 09:30:00', TRUE),
    (102, 'Mouse', 799.50, 100, '2026-02-15', '2026-02-15 11:45:00', TRUE),
    (103, 'Monitor', 15999.00, 20, '2026-03-20', '2026-03-20 14:10:00', FALSE),
    (104, 'Laptop Stand', 3499.75, 35, '2026-04-05', '2026-04-05 16:20:00', TRUE);

-- ============================================================
-- Basic Practice
-- ============================================================

-- Q1. Create a table employees with:
-- employee_id as INT
-- employee_name as VARCHAR(100)
-- age as TINYINT UNSIGNED
-- salary as DECIMAL(10,2)


-- Q2. Create a table customers with:
-- customer_id as BIGINT
-- customer_name as VARCHAR(150)
-- email as VARCHAR(255)


-- Q3. Create a table inventory where quantity cannot be negative.
-- Choose an appropriate integer type and use UNSIGNED.


-- Q4. Create a products table where price must support two decimal places.
-- Choose an appropriate exact numeric type.


-- Q5. Create a locations table with a fixed two-character country code.
-- Choose the most appropriate string type.


-- Q6. Create a users table with a variable-length email address.
-- Choose an appropriate string type.


-- Q7. Create a table events with:
-- event_date for the date only
-- start_time for the time only
-- created_at for date and time


-- Q8. Create a table accounts with an is_active boolean column.


-- Q9. Create a jobs table where status can only be:
-- pending, running, completed, failed
-- Use ENUM.


-- Q10. Create a developers table that can store multiple skills from:
-- SQL, Python, Spark, Hadoop
-- Use SET.


-- ============================================================
-- Data Type Selection
-- ============================================================

-- Q11. Which data type would you choose for an employee ID that may grow
-- beyond the INT range? Explain your choice in SQL comments.


-- Q12. Which data type should normally be used for salary and why?


-- Q13. Which data type would you choose for a person's birth date?


-- Q14. Which data type would you choose for an application event timestamp?
-- Explain DATE vs DATETIME vs TIMESTAMP in comments.


-- Q15. Which is more appropriate for a name: CHAR(100) or VARCHAR(100)?
-- Explain why.


-- Q16. When would TEXT be more appropriate than VARCHAR?


-- Q17. Why should FLOAT or DOUBLE generally not be used for monetary values?


-- Q18. Explain the difference between signed and UNSIGNED integers.


-- ============================================================
-- Practical Schema Design
-- ============================================================

-- Q19. Design a customers table with appropriate data types for:
-- customer_id
-- first_name
-- last_name
-- email
-- date_of_birth
-- registration timestamp
-- is_active


-- Q20. Design an orders table with appropriate types for:
-- order_id
-- customer_id
-- order_amount
-- order_date
-- created_at
-- status


-- Q21. Design a sensor_readings table containing:
-- reading_id
-- sensor_id
-- temperature
-- recorded_at
-- Choose appropriate numeric and date/time types.


-- Q22. Design an API_events table containing:
-- event_id
-- event_type
-- event_time
-- payload
-- Use JSON for the payload.


-- ============================================================
-- Analysis Questions
-- ============================================================

-- Q23. Explain why using VARCHAR for every column is a poor schema design.


-- Q24. A column stores values such as 10.25, 20.50 and 99.99 for product prices.
-- Which data type would you choose and why?


-- Q25. A column stores values between 0 and 255 only.
-- What integer type could be appropriate if negative values are impossible?


-- Q26. A country code is always exactly two characters.
-- Would CHAR or VARCHAR be more appropriate? Explain.


-- Q27. An attribute contains semi-structured data whose keys may change over time.
-- Would you use normal columns or JSON? Explain the trade-off.


-- Q28. Why can choosing a data type that is too small become a production problem?


-- Q29. Why can choosing a data type that is unnecessarily large also matter?
-- Consider storage, indexes, and large tables.


-- Q30. Explain why data type selection is important in Data Engineering systems.


-- ============================================================
-- Interview Challenge
-- ============================================================

-- Q31. Design an orders table for a production-style e-commerce system.
-- Include at least:
-- order_id
-- customer_id
-- total_amount
-- order_date
-- created_at
-- status
-- metadata
--
-- Choose every data type yourself and explain each choice in comments.


-- Q32. An interviewer asks:
-- "DECIMAL(10,2) — what do 10 and 2 mean?"
-- Write the answer as SQL comments.


-- Q33. An interviewer asks:
-- "Is BOOLEAN a separate storage type in MySQL?"
-- Write the answer as SQL comments.


-- Q34. An interviewer asks:
-- "What is the difference between DATETIME and TIMESTAMP?"
-- Write a concise interview-ready answer as SQL comments.


-- Q35. An interviewer asks:
-- "When would you use BIGINT instead of INT?"
-- Write an interview-ready answer as SQL comments.


-- ============================================================
-- Final Challenge
-- ============================================================

-- Q36. Create a data_engineering_jobs table with suitable types for:
-- job_id
-- pipeline_name
-- status
-- records_processed
-- processing_time_seconds
-- started_at
-- completed_at
-- error_message
-- metadata
--
-- Think about:
-- - Range
-- - Precision
-- - Variable-length strings
-- - Date/time semantics
-- - Semi-structured metadata

