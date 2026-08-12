-- ============================================================
-- 09 — Sorting and Limiting
-- Practice Exercises
-- ============================================================

CREATE DATABASE IF NOT EXISTS mysql_learning_09_practice;
USE mysql_learning_09_practice;

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    category VARCHAR(50),
    amount DECIMAL(10,2),
    status VARCHAR(20),
    order_date DATETIME
);

INSERT INTO orders VALUES
(101, 'Amit', 'Electronics', 1500, 'completed', '2026-08-01 10:00:00'),
(102, 'Priya', 'Books', 500, 'completed', '2026-08-01 15:30:00'),
(103, 'Rahul', 'Electronics', 2500, 'cancelled', '2026-08-02 09:00:00'),
(104, 'Sneha', 'Furniture', 4000, 'completed', '2026-08-02 12:00:00'),
(105, 'Vikas', NULL, NULL, 'pending', '2026-08-03 18:00:00'),
(106, 'Neha', 'Books', 500, 'completed', '2026-08-03 23:00:00'),
(107, 'Riya', 'Electronics', 2500, 'completed', '2026-08-04 08:00:00'),
(108, 'Karan', 'Furniture', 4000, 'completed', '2026-08-04 12:00:00');

-- ============================================================
-- Basic ORDER BY
-- ============================================================

-- Q1. Sort all orders by amount from lowest to highest.

-- Q2. Sort all orders by amount from highest to lowest.

-- Q3. Sort customers alphabetically by customer_name.

-- Q4. Sort orders by order_date from newest to oldest.

-- Q5. Sort orders by category and then amount descending.

-- Q6. Sort by status ascending and order_date descending.

-- ============================================================
-- Multiple Sort Keys and Ties
-- ============================================================

-- Q7. Sort by amount descending and use order_id as a tie-breaker.

-- Q8. Explain why a unique tie-breaker is useful in production SQL.

-- Q9. Sort completed orders by date descending and order_id descending.

-- Q10. Return all orders in deterministic order even when amounts tie.

-- ============================================================
-- LIMIT
-- ============================================================

-- Q11. Return the first five orders by order_id.

-- Q12. Find the three highest-value orders.

-- Q13. Find the three lowest non-NULL amounts.

-- Q14. Return the latest order.

-- Q15. Return the five latest completed orders.

-- Q16. Find the two most expensive Electronics orders.

-- ============================================================
-- OFFSET and Pagination
-- ============================================================

-- Q17. Return rows 1-3 when ordered by order_id.

-- Q18. Return rows 4-6 using LIMIT and OFFSET.

-- Q19. Return the third page when each page contains two rows.

-- Q20. Explain why a large OFFSET can become expensive.

-- Q21. Write a keyset pagination query that continues after order_id 103.

-- Q22. Explain the difference between OFFSET pagination and keyset pagination.

-- ============================================================
-- NULL Ordering
-- ============================================================

-- Q23. Sort orders so NULL amounts appear last.

-- Q24. Sort orders so NULL amounts appear first.

-- Q25. Explain why NULL ordering should be made explicit when business
-- requirements depend on it.

-- ============================================================
-- Expressions and Aliases
-- ============================================================

-- Q26. Calculate annualized amount as amount * 12 and sort by it.

-- Q27. Calculate amount_with_tax using a 10% tax and sort descending.

-- Q28. Explain whether an ORDER BY clause can reference a SELECT alias.

-- ============================================================
-- Data Engineering Scenarios
-- ============================================================

-- Q29. Return the ten most recently updated records from a staging table.

-- Q30. Return the latest pipeline run using run_time and run_id.

-- Q31. Return the latest 100 events with a deterministic ordering.

-- Q32. Return the oldest five records for a backfill investigation.

-- Q33. Find the top five customers by order amount.
-- Assume one row per order; first sort by amount.

-- Q34. Return completed orders only, sorted newest first.

-- Q35. Return pending orders sorted by oldest first.

-- Q36. Build a reproducible extraction query that returns exactly 100 rows.

-- Q37. Explain why SELECT * with LIMIT 100 is not a reliable business
-- definition of a sample.

-- ============================================================
-- Interview Practice
-- ============================================================

-- Q38. What does ORDER BY do?

-- Q39. What is the default ORDER BY direction?

-- Q40. Why should LIMIT normally be paired with ORDER BY?

-- Q41. What is the purpose of OFFSET?

-- Q42. Why can large OFFSET values hurt performance?

-- Q43. What is deterministic ordering?

-- Q44. How do you handle ties in a top-N query?

-- Q45. What is keyset pagination?

-- Q46. Why is keyset pagination often preferred for large datasets?

-- Q47. Can you rely on physical table row order without ORDER BY?

-- Q48. How would you return NULL values last?

-- Q49. How would you find the latest record from a table?

-- Q50. Why is a timestamp plus a unique ID a useful pagination key?

-- ============================================================
-- Final Data Engineering Challenge
-- ============================================================

-- Q51. Return the five most recent completed orders.
-- Requirements:
--   1. Sort by order_date descending.
--   2. Use order_id as a deterministic tie-breaker.
--   3. Return only five rows.

-- Q52. Modify Q51 to return page 2 when the page size is five.

-- Q53. Rewrite Q52 using keyset pagination after a supplied last-seen
-- order_date and order_id.

-- Q54. Return the top three non-NULL amounts while making ties deterministic.

-- Q55. Return the latest 100 records for an incremental data extraction.
-- Explain why deterministic ordering matters.

-- Q56. Design a pagination query for a table containing 100 million rows.
-- Compare OFFSET and keyset pagination.

-- Q57. Build a query that places NULL amounts last, sorts by amount
-- descending, and uses order_id as the final tie-breaker.
