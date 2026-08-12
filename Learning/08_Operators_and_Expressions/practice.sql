-- ============================================================
-- 08 — Operators and Expressions
-- Practice Exercises
-- ============================================================

CREATE DATABASE IF NOT EXISTS mysql_learning_08_practice;
USE mysql_learning_08_practice;

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    category VARCHAR(50),
    quantity INT,
    unit_price DECIMAL(10,2),
    discount DECIMAL(10,2),
    status VARCHAR(20),
    order_date DATETIME
);

INSERT INTO orders VALUES
(101, 'Amit', 'Electronics', 2, 1500, 100, 'completed', '2026-08-01 10:00:00'),
(102, 'Priya', 'Books', 4, 500, NULL, 'completed', '2026-08-01 15:30:00'),
(103, 'Rahul', 'Electronics', 1, 2500, 250, 'cancelled', '2026-08-02 09:00:00'),
(104, 'Sneha', 'Furniture', 3, 4000, 500, 'completed', '2026-08-02 12:00:00'),
(105, 'Vikas', NULL, 1, 750, NULL, 'pending', '2026-08-03 18:00:00'),
(106, 'Neha', 'Books', 5, 300, 50, 'completed', '2026-08-03 23:00:00');

-- ============================================================
-- Basic Arithmetic
-- ============================================================

-- Q1. Calculate the gross amount for every order.

-- Q2. Calculate the discount-adjusted amount.

-- Q3. Calculate the annual equivalent of a monthly value of 75000.

-- Q4. Find the remainder when quantity is divided by 2.

-- Q5. Compare normal division with integer division using 17 and 5.

-- ============================================================
-- Comparison Operators
-- ============================================================

-- Q6. Find orders where unit_price is greater than 1000.

-- Q7. Find orders where quantity is exactly 1.

-- Q8. Find orders whose status is not cancelled.

-- Q9. Find orders where the gross amount is at least 5000.

-- Q10. Find orders where discount is less than 200.

-- ============================================================
-- AND / OR / NOT
-- ============================================================

-- Q11. Find completed Electronics orders.

-- Q12. Find completed orders with quantity greater than 2.

-- Q13. Find orders from Books or Furniture.

-- Q14. Find orders that are neither cancelled nor pending.

-- Q15. Find Electronics or Books orders with unit_price above 400.
-- Use parentheses so the business rule is explicit.

-- ============================================================
-- BETWEEN
-- ============================================================

-- Q16. Find orders with unit_price between 500 and 2000 inclusive.

-- Q17. Find orders with quantity between 2 and 5 inclusive.

-- Q18. Explain why BETWEEN is inclusive.

-- Q19. Write a safer timestamp filter for all orders on 2026-08-02.

-- ============================================================
-- IN / NOT IN
-- ============================================================

-- Q20. Find orders in Electronics, Books, or Furniture.

-- Q21. Exclude cancelled and pending orders.

-- Q22. Explain why NOT IN can be dangerous when NULL exists in a subquery.

-- ============================================================
-- LIKE
-- ============================================================

-- Q23. Find customers whose names begin with 'A'.

-- Q24. Find customers whose names contain 'e'.

-- Q25. Find customer names ending in 'a'.

-- Q26. Write a LIKE pattern that matches a three-character code
-- beginning with A and ending with 1.

-- ============================================================
-- NULL and Three-Valued Logic
-- ============================================================

-- Q27. Find orders where discount is NULL.

-- Q28. Find orders where discount is NOT NULL.

-- Q29. Explain why discount = NULL does not work.

-- Q30. Explain TRUE, FALSE, and UNKNOWN in SQL.

-- ============================================================
-- Conditional Expressions
-- ============================================================

-- Q31. Categorize orders as:
-- Large: gross amount >= 10000
-- Medium: gross amount >= 5000
-- Small: otherwise.

-- Q32. Create a status label using CASE.

-- Q33. Categorize orders as high-value when gross amount is above 8000.

-- ============================================================
-- Data Engineering Scenarios
-- ============================================================

-- Q34. Filter all records loaded during one calendar day using a
-- half-open timestamp range.

-- Q35. Find records with missing category values.

-- Q36. Find potentially invalid records where quantity <= 0.

-- Q37. Find suspicious orders where discount is greater than unit_price.

-- Q38. Exclude cancelled orders while retaining NULL categories.

-- Q39. Find completed orders with a non-null discount.

-- Q40. Build a net_amount expression treating NULL discount as zero.

-- Q41. Identify orders with gross amount between 1000 and 10000.

-- Q42. Build a business rule where Electronics OR Books orders must have
-- unit_price >= 500.

-- Q43. Rewrite Q42 with explicit parentheses and explain the difference.

-- ============================================================
-- Interview Practice
-- ============================================================

-- Q44. What is the difference between = NULL and IS NULL?

-- Q45. Why does SQL use three-valued logic?

-- Q46. Is BETWEEN inclusive?

-- Q47. What is the difference between IN and multiple OR conditions?

-- Q48. Why can NOT IN return no rows when NULL exists in the subquery?

-- Q49. What is operator precedence? Why should parentheses be used?

-- Q50. Why are half-open timestamp ranges preferred in ETL pipelines?

-- Q51. What do % and _ mean in LIKE?

-- Q52. Why does arithmetic involving NULL usually return NULL?

-- Q53. How would you safely replace NULL numeric values with zero?

-- Q54. When might bitwise operators be useful in a data pipeline?

-- ============================================================
-- Final Data Engineering Challenge
-- ============================================================

-- Q55. Build one query that returns:
--   order_id
--   customer_name
--   gross_amount
--   net_amount
--   value_band
--   order_date
--
-- Rules:
--   1. Treat NULL discount as zero.
--   2. Exclude cancelled orders.
--   3. Gross amount = quantity * unit_price.
--   4. Net amount = gross amount - discount.
--   5. value_band:
--        >= 10000 -> 'Large'
--        >= 5000  -> 'Medium'
--        otherwise -> 'Small'
--   6. Return only records from 2026-08-01.
--   7. Use a half-open timestamp range.

-- Q56. Modify Q55 to return only Large orders.

-- Q57. Modify Q55 to identify orders with missing category.

-- Q58. Modify Q55 to exclude orders with NULL discount.

-- Q59. Explain which conditions should be evaluated in WHERE and which
-- calculations belong in SELECT.

-- Q60. Explain how NULL affects the final net_amount calculation if
-- COALESCE is removed.

-- Q61. Rewrite the final challenge using explicit parentheses wherever
-- AND and OR are combined.
