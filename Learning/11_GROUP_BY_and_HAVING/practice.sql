-- ============================================================
-- 11 — GROUP BY and HAVING | Practice
-- ============================================================

-- Setup
DROP DATABASE IF EXISTS mysql_practice_11;
CREATE DATABASE mysql_practice_11;
USE mysql_practice_11;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    city VARCHAR(50),
    segment VARCHAR(30)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    amount DECIMAL(12,2),
    status VARCHAR(20)
);

INSERT INTO customers VALUES
(1,'Aarav','Mumbai','Retail'),
(2,'Diya','Pune','Retail'),
(3,'Kabir','Mumbai','Enterprise'),
(4,'Isha','Delhi','Enterprise'),
(5,'Rohan','Pune','SMB'),
(6,'Anaya','Mumbai','SMB');

INSERT INTO orders VALUES
(101,1,'2026-01-05',1200,'COMPLETED'),
(102,1,'2026-01-20',800,'COMPLETED'),
(103,1,'2026-02-10',1500,'CANCELLED'),
(104,2,'2026-01-12',2500,'COMPLETED'),
(105,2,'2026-02-02',1800,'COMPLETED'),
(106,3,'2026-01-18',5000,'COMPLETED'),
(107,3,'2026-02-15',4200,'COMPLETED'),
(108,3,'2026-03-01',3000,'COMPLETED'),
(109,4,'2026-02-10',700,'CANCELLED'),
(110,4,'2026-02-20',900,'COMPLETED'),
(111,5,'2026-03-05',600,'COMPLETED'),
(112,6,'2026-03-06',1100,'COMPLETED');

-- ============================================================
-- Basic GROUP BY
-- ============================================================

-- Q1. Count the number of customers in each city.

-- Q2. Count customers in each segment.

-- Q3. Find the number of orders per customer.

-- Q4. Find total order amount per customer.

-- Q5. Find average order amount per customer.

-- Q6. Find minimum and maximum order amount per customer.

-- Q7. Find total sales by order status.

-- Q8. Find total completed sales by customer.

-- Q9. Find the number of completed orders per customer.

-- Q10. Find total sales by city.

-- ============================================================
-- GROUP BY Multiple Columns
-- ============================================================

-- Q11. Find order count by customer and status.

-- Q12. Find total sales by city and customer segment.

-- Q13. Find monthly order count using YEAR() and MONTH().

-- Q14. Find monthly completed sales.

-- Q15. Find sales by customer and month.

-- ============================================================
-- WHERE + GROUP BY
-- ============================================================

-- Q16. Find customers with completed orders only.

-- Q17. Find total completed sales for orders above 1000.

-- Q18. Find city-level sales using only completed orders.

-- Q19. Find customer order counts for orders placed after 2026-02-01.

-- Q20. Find average completed order amount per customer.

-- ============================================================
-- HAVING
-- ============================================================

-- Q21. Find customers with more than 2 orders.

-- Q22. Find customers whose total order value exceeds 4000.

-- Q23. Find customers whose average order value exceeds 1500.

-- Q24. Find cities having more than 2 customers.

-- Q25. Find customer segments containing at least 2 customers.

-- Q26. Find customers with at least 2 completed orders.

-- Q27. Find customers whose completed sales exceed 4000.

-- Q28. Find months with total completed sales greater than 5000.

-- Q29. Find customer groups where the maximum order exceeds 3000.

-- Q30. Find customers with at least 2 orders and total sales above 3000.

-- ============================================================
-- Conditional Aggregation
-- ============================================================

-- Q31. For each customer, count completed and cancelled orders separately.

-- Q32. For each customer, calculate completed sales and cancelled sales.

-- Q33. For each city, count customers in each segment using CASE.

-- Q34. Find customers where completed orders are more than cancelled orders.

-- Q35. Find customers with at least one cancelled order.

-- ============================================================
-- Data Engineering Scenarios
-- ============================================================

-- Q36. A daily pipeline loads orders. Find the number of rows per load date.

-- Q37. Find load dates where fewer than 3 orders were loaded.

-- Q38. Find customers appearing more than once in a supposedly unique customer feed.

-- Q39. Find duplicate order IDs in a staging table.

-- Q40. Calculate daily source totals for reconciliation.

-- Q41. Calculate daily completed-order totals for reconciliation.

-- Q42. Find dates where completed sales exceed 5000.

-- Q43. Find customer segments with total completed sales above 5000.

-- Q44. Find cities where the average completed order value exceeds 1500.

-- Q45. Find months with more than 5 completed orders.

-- ============================================================
-- Join + GROUP BY Scenarios
-- ============================================================

-- Q46. Calculate total completed sales by customer city.

-- Q47. Calculate order count by customer segment.

-- Q48. Find cities with more than 3 completed orders.

-- Q49. Find customer segments with average completed order value above 2000.

-- Q50. Find customers with no completed orders using LEFT JOIN + GROUP BY.

-- ============================================================
-- Interview Challenges
-- ============================================================

-- Q51. Explain why HAVING is required for COUNT(*) > 2.

-- Q52. Rewrite a query that incorrectly uses WHERE COUNT(*).

-- Q53. Explain the difference between COUNT(*) and COUNT(status).

-- Q54. A JOIN doubles the order rows. Explain why SUM(amount) becomes incorrect.

-- Q55. Define the grain of: customer_id + month.

-- Q56. Find the top 3 customers by completed sales using GROUP BY and ORDER BY.

-- Q57. Find the second-highest city by total completed sales.

-- Q58. Find customers whose completed sales are above the overall average customer sales.

-- Q59. Find the month with the highest completed sales.

-- Q60. Build a reconciliation query comparing source and target totals by date.

-- Q61. FINAL CHALLENGE:
-- Identify customer segments with:
--   1. At least 2 customers
--   2. At least 3 completed orders
--   3. Completed sales above 5000
-- Return segment, customer count, order count, and total sales.

-- ============================================================
-- Self-check
-- ============================================================
-- Before considering this topic complete, make sure you can explain:
-- 1. WHERE vs HAVING
-- 2. GROUP BY grain
-- 3. COUNT(*) vs COUNT(column)
-- 4. Conditional aggregation
-- 5. GROUP BY after JOIN
-- 6. How JOIN multiplication can inflate aggregates
-- 7. How to use HAVING with multiple aggregate conditions
