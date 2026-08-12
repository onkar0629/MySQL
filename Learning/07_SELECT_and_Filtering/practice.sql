-- ============================================================
-- 07 — SELECT and Filtering
-- Practice Exercises
-- ============================================================

CREATE DATABASE IF NOT EXISTS select_filtering_practice;
USE select_filtering_practice;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(255),
    city VARCHAR(50),
    status VARCHAR(20),
    signup_date DATE
);

INSERT INTO customers VALUES
(1, 'Amit Sharma', 'amit@example.com', 'Mumbai', 'active', '2026-01-10'),
(2, 'Priya Patil', 'priya@example.com', 'Pune', 'active', '2026-02-15'),
(3, 'Rahul Mehta', NULL, 'Mumbai', 'inactive', '2026-03-05'),
(4, 'Neha Joshi', 'neha@example.com', 'Nashik', 'active', '2026-04-20'),
(5, 'Anita Shah', 'anita@example.com', 'Mumbai', 'active', '2026-05-12');

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    stock_qty INT
);

INSERT INTO products VALUES
(101, 'Keyboard', 'Electronics', 1200.00, 25),
(102, 'Mouse', 'Electronics', 700.00, 50),
(103, 'Notebook', 'Stationery', 150.00, 100),
(104, 'Monitor', 'Electronics', 12000.00, 8),
(105, 'Pen', 'Stationery', 50.00, 200),
(106, 'Headphones', 'Electronics', 2500.00, 15);

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100),
    department_id INT,
    job_title VARCHAR(100),
    salary DECIMAL(12,2),
    manager_id INT NULL
);

INSERT INTO employees VALUES
(1, 'Amit', 10, 'Data Engineer', 85000, NULL),
(2, 'Priya', 10, 'Senior Data Engineer', 105000, 1),
(3, 'Rahul', 20, 'Analyst', 70000, NULL),
(4, 'Neha', 30, 'Data Engineer', 90000, 1),
(5, 'Vikas', 20, 'Senior Analyst', 95000, 3),
(6, 'Anita', 30, 'Engineer', 75000, 4);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATETIME,
    amount DECIMAL(12,2),
    status VARCHAR(20)
);

INSERT INTO orders VALUES
(1001, 1, '2026-08-01 10:15:00', 2500.00, 'completed'),
(1002, 2, '2026-08-05 14:30:00', 1200.00, 'pending'),
(1003, 1, '2026-08-12 09:00:00', 5000.00, 'completed'),
(1004, 4, '2026-08-12 17:30:00', 1800.00, 'completed'),
(1005, 5, '2026-08-20 11:20:00', 3200.00, 'cancelled');

-- SECTION A — SELECT BASICS
-- Q1. Return all columns from customers.
-- Q2. Return only customer_id and customer_name.
-- Q3. Return product_name and price.
-- Q4. Rename customer_name as name using an alias.
-- Q5. Calculate price including 18% tax and call it price_with_tax.
-- Q6. Return employee_name, job_title, and salary.

-- SECTION B — WHERE FILTERING
-- Q7. Find customers from Mumbai.
-- Q8. Find products with price greater than 1000.
-- Q9. Find employees earning at least 90000.
-- Q10. Find completed orders.
-- Q11. Find products with stock less than 20.
-- Q12. Find employees not in department 10.

-- SECTION C — AND / OR / NOT
-- Q13. Find employees in department 10 earning at least 90000.
-- Q14. Find customers who are active and live in Mumbai.
-- Q15. Find employees in department 10 OR 20.
-- Q16. Find Electronics or Stationery products costing more than 500.
-- Q17. Find employees who are NOT in department 30.
-- Q18. Use parentheses for a mixed AND / OR condition.

-- SECTION D — IN / NOT IN / BETWEEN
-- Q19. Find employees whose department_id is 10, 20, or 30 using IN.
-- Q20. Find employees whose department_id is not 10 or 20.
-- Q21. Find products priced between 500 and 2500.
-- Q22. Find employees earning between 75000 and 95000.
-- Q23. Find orders with amounts between 1500 and 5000.

-- SECTION E — LIKE
-- Q24. Find customers whose names start with 'A'.
-- Q25. Find customers whose names end with 'a'.
-- Q26. Find customer names containing 'it'.
-- Q27. Find product names beginning with 'M'.
-- Q28. Use '_' as a single-character wildcard.
-- Q29. Find emails ending with '@example.com'.

-- SECTION F — NULL
-- Q30. Find customers whose email is NULL.
-- Q31. Find employees who have a manager.
-- Q32. Find employees who do not have a manager.
-- Q33. Explain why email = NULL does not work.
-- Q34. Explain NULL vs 0 vs empty string.

-- SECTION G — DISTINCT
-- Q35. Return unique customer cities.
-- Q36. Return unique employee department IDs.
-- Q37. Return unique combinations of department_id and job_title.
-- Q38. Explain whether DISTINCT changes source data.

-- SECTION H — DATE / DATETIME
-- Q39. Find customers who signed up in March 2026.
-- Q40. Find orders placed on 2026-08-12.
-- Q41. Find all orders from August 2026 using a half-open range.
-- Q42. Find orders from August 1 through August 12 inclusive.
-- Q43. Explain why a half-open datetime range is safer than an end-of-day literal.

-- SECTION I — BUSINESS SCENARIOS
-- Q44. Find active customers from Mumbai or Pune.
-- Q45. Find completed orders worth at least 2500.
-- Q46. Find products that need restocking when stock_qty < 20.
-- Q47. Find high-value Electronics products priced above 2000.
-- Q48. Find customers with missing email addresses.
-- Q49. Find Senior-level employees earning above 90000.

-- SECTION J — DATA ENGINEERING SCENARIOS
-- Q50. Write an incremental extraction query for orders on 2026-08-12.
-- Q51. Identify customer records with missing mandatory email values.
-- Q52. Find orders outside the expected August 2026 business-date window.
-- Q53. Explain the use of DISTINCT in a source-data profiling query.
-- Q54. Isolate cancelled orders for a downstream quarantine process.
-- Q55. Explain why explicit columns are preferable to SELECT * in production pipelines.

-- SECTION K — INTERVIEW CHALLENGES
-- Q56. Explain WHERE vs HAVING.
-- Q57. Explain NOT IN with NULL.
-- Q58. Rewrite OR conditions using IN.
-- Q59. Write a safe full-month DATETIME filter.
-- Q60. Explain when DISTINCT may hide a data-quality problem.
-- Q61. Explain the performance issue with DATE(timestamp_column) in a WHERE clause.
-- Q62. Find customers who have never placed an order.
-- Q63. Find products whose price after 18% tax exceeds 2500.
-- Q64. Find active Mumbai/Pune customers with non-null email.
-- Q65. Final challenge: extract completed August orders above 2000 with required columns only.
