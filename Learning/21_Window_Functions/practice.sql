-- ============================================================
-- 21 — Window Functions
-- practice.sql
-- ============================================================
-- No solutions. Solve the questions yourself.
-- Use examples.sql tables unless a question defines another schema.
-- Focus on explaining WHY you chose the window function.
-- ============================================================

-- ============================================================
-- BEGINNER — BUILD THE WINDOW MODEL
-- ============================================================

-- Q1. Return every employee with the average salary of their department.
--     Do NOT collapse the employee rows.

-- Q2. Return every employee with the company-wide average salary.

-- Q3. Assign a unique salary row number within each department.
--     Resolve ties deterministically using employee_id.

-- Q4. Show ROW_NUMBER, RANK, and DENSE_RANK for every employee.
--     Use salary DESC as the ranking order.

-- Q5. Explain in comments why PARTITION BY is not the same as GROUP BY.
--     Demonstrate the difference with a query.

-- Q6. Return each employee's salary difference from their department average.

-- ============================================================
-- RANKING — INTERVIEW CORE
-- ============================================================

-- Q7. Return the highest-paid employee in each department.
--     Exactly one employee must be returned per department.
--     If salaries tie, use employee_id as the deterministic tie-breaker.

-- Q8. Return the top 3 employees by salary in each department.
--     Exactly three rows maximum per department.
--     Explain why ROW_NUMBER is appropriate.

-- Q9. Return employees belonging to the top 3 salary levels in each department.
--     All ties must be included.
--     Explain why DENSE_RANK is appropriate.

-- Q10. Return the second-highest DISTINCT salary in every department.

-- Q11. Return the third employee by salary in every department.
--     Clarify why this is different from the third-highest salary level.

-- Q12. The interviewer changes the requirement:
--      "Return the top 3 employees, but include everyone tied with the third salary."
--      Choose the appropriate ranking function and explain your decision.

-- ============================================================
-- LAG / LEAD — PREVIOUS AND NEXT ROW
-- ============================================================

-- Q13. For every customer order, return the previous order amount.

-- Q14. For every customer order, return the previous order date.

-- Q15. For every customer order, return the number of days since the previous order.

-- Q16. For every customer order, return the next order date.

-- Q17. For every customer order, return the amount two orders earlier.
--      Return 0 when that previous row does not exist.

-- Q18. Identify customers whose order amount increased compared with their
--      immediately previous order.

-- Q19. Identify orders where the amount decreased compared with the previous order.

-- Q20. For every user event, return the next event time and the number of
--      minutes until that event.

-- ============================================================
-- RUNNING CALCULATIONS AND FRAMES
-- ============================================================

-- Q21. Calculate a running total of customer spending ordered by order_date.
--      Make the ordering deterministic.

-- Q22. Calculate a running average of order amount.

-- Q23. Calculate a 3-row moving average of order amount.

-- Q24. Calculate a 7-row moving average of daily sales.
--      Explain why this is not necessarily a 7-calendar-day average.

-- Q25. Explain what this frame means:
--      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW

-- Q26. Explain what this frame means:
--      ROWS BETWEEN 6 PRECEDING AND CURRENT ROW

-- Q27. Create a query that demonstrates why duplicate ORDER BY values can matter
--      when choosing window-frame semantics.

-- Q28. Return the highest salary and lowest salary of each department on every
--      employee row using FIRST_VALUE and LAST_VALUE.
--      Use an explicit frame for LAST_VALUE.

-- ============================================================
-- FIRST / LAST / NTH RECORD PATTERNS
-- ============================================================

-- Q29. Find the first order for every customer using ROW_NUMBER.

-- Q30. Find the second order for every customer using ROW_NUMBER.

-- Q31. Find the latest order for every customer using ROW_NUMBER.

-- Q32. Return each customer with both their first order date and latest order date
--      while keeping one row per customer.

-- Q33. Find customers whose second order occurred within 30 days of their first order.

-- Q34. Find customers whose second order amount was greater than their first order amount.

-- ============================================================
-- DEDUPLICATION / DATA ENGINEERING
-- ============================================================

-- Q35. Given staging_customer, keep only the latest record for every customer_id.
--      Use updated_at DESC and record_id DESC as deterministic ordering.

-- Q36. A CDC source contains multiple records for the same business key.
--      Keep the latest event_time and use sequence_id as a tie-breaker.
--      Write the query and explain why the tie-breaker matters.

-- Q37. Find all duplicate records in staging_customer, meaning every row except
--      the latest row for each customer_id.

-- Q38. Write a query that returns only business keys that have more than one
--      staging record and identifies the record that should be retained.

-- Q39. Explain why MAX(updated_at) alone is insufficient when you need all columns
--      from the latest record.

-- ============================================================
-- GAPS AND ISLANDS
-- ============================================================

-- Q40. Given login data(user_id, login_date), identify consecutive login streaks.
--      Use LAG to identify where a new streak starts.

-- Q41. Assign a streak/group number to each consecutive login period.

-- Q42. Return the start date and end date of every login streak.

-- Q43. Return the longest login streak for each user.

-- Q44. Identify users with at least 3 consecutive login days.

-- ============================================================
-- QUERY PROCESSING / CTE
-- ============================================================

-- Q45. Explain why this query is invalid:
--      SELECT employee_id,
--             ROW_NUMBER() OVER (ORDER BY salary DESC) AS rn
--      FROM employees
--      WHERE rn <= 3;
--      Rewrite it correctly using a CTE.

-- Q46. Solve Q45 again using a derived table instead of a CTE.

-- Q47. Explain the difference between filtering rows BEFORE a window calculation
--      and filtering the generated window result AFTER the calculation.

-- ============================================================
-- GRAIN AND JOIN TRAPS
-- ============================================================

-- Q48. A LEFT JOIN changes one customer row into five rows because the customer
--      has five transactions. You then apply ROW_NUMBER(). Explain why the result
--      may be wrong for a customer-level ranking.

-- Q49. Design a fix for Q48 by aggregating or filtering to the required grain before
--      applying the window function.

-- Q50. Given a one-to-many JOIN, identify the expected grain before and after the JOIN.
--      Write comments showing where the window calculation should occur.

-- ============================================================
-- BUSINESS SCENARIOS — DATA ENGINEER INTERVIEW LEVEL
-- ============================================================

-- Q51. E-commerce:
--      Find the top 2 products by revenue in every category, including ties.

-- Q52. E-commerce:
--      Find each customer's first purchase, second purchase, and latest purchase.

-- Q53. Banking:
--      For every transaction, calculate the customer's running account balance.
--      State the assumptions about the starting balance.

-- Q54. Banking:
--      Identify the first transaction after a customer's balance changed.

-- Q55. Logistics:
--      For every shipment, calculate the time until the next shipment for the same
--      customer.

-- Q56. Streaming:
--      For every user, find the previous video watched and the time between watches.

-- Q57. Application logs:
--      Find the next event after every ERROR event for the same application/user.

-- Q58. Data Quality:
--      A daily pipeline receives duplicate customer snapshots. Keep the latest
--      snapshot per customer and report how many duplicates were removed.

-- Q59. CDC:
--      A source emits INSERT/UPDATE events with event_time and sequence_id.
--      Return the latest state for every business key.

-- Q60. Reporting:
--      Return each employee, department average salary, department maximum salary,
--      employee rank, and difference from department average in one query.

-- ============================================================
-- INTERVIEW THEORY — EXPLAIN, DON'T CODE
-- ============================================================

-- Q61. What is a window function?

-- Q62. What is the purpose of OVER()?

-- Q63. What does PARTITION BY do?

-- Q64. What is the difference between window ORDER BY and final query ORDER BY?

-- Q65. Difference between ROW_NUMBER, RANK, and DENSE_RANK?

-- Q66. When would you prefer ROW_NUMBER over RANK?

-- Q67. When would DENSE_RANK return more rows than ROW_NUMBER for Top-N?

-- Q68. Why should ROW_NUMBER often include a unique tie-breaker?

-- Q69. What does LAG do?

-- Q70. What does LEAD do?

-- Q71. What is a window frame?

-- Q72. What is the difference between a partition and a frame?

-- Q73. Why can a 7-row moving average differ from a 7-day moving average?

-- Q74. Why is LAST_VALUE commonly misunderstood?

-- Q75. Why can a JOIN before a window function produce incorrect results?

-- Q76. Why can't a window-function alias normally be used in WHERE?

-- Q77. When is GROUP BY better than a window function?

-- Q78. When would you use a self JOIN instead of LAG/LEAD?

-- Q79. What performance issues can large window partitions cause?

-- Q80. What would you inspect in EXPLAIN when troubleshooting a slow window query?

-- ============================================================
-- FINAL CHALLENGES — NO HINTS
-- ============================================================

-- Q81. A customer can place multiple orders on the same day. Return the customer's
--      second order chronologically. Use order_id as the deterministic tie-breaker.

-- Q82. Find the third-highest DISTINCT salary in each department and return every
--      employee who earns that salary.

-- Q83. Find customers whose latest order amount is greater than their first order amount.

-- Q84. Find the largest gap in days between consecutive orders for every customer.

-- Q85. Find the order immediately before each customer's largest order.

-- Q86. Find each customer's longest period between consecutive orders.

-- Q87. Identify customers who placed orders in three consecutive calendar months.

-- Q88. Given status records for machines, identify uninterrupted periods where each
--      machine remained in the same status.

-- Q89. Given employee salary history, return the latest salary record and the previous
--      salary record for every employee, including the salary change.

-- Q90. A CDC table contains multiple updates per business key and multiple updates can
--      share the same timestamp. Return exactly one deterministic latest record per key.

-- Q91. Find the top 3 products by sales in every month, including ties at rank 3.

-- Q92. Find users whose current event differs from their previous event type.

-- Q93. Find the first event after every LOGIN event for the same user.

-- Q94. Identify sessions where the gap between consecutive events exceeds 30 minutes.

-- Q95. Convert the session boundaries from Q94 into a session_id using window functions.

-- Q96. Find the longest session for each user.

-- Q97. Find employees whose salary is above their department average but below the
--      department maximum.

-- Q98. Return each employee's salary percentile within their department using an
--      appropriate ranking/window approach. Explain your choice.

-- Q99. Build a single query that reports, for each customer: first order date, latest
--      order date, order count, latest amount, previous amount, and total spend.

-- Q100. FINAL INTERVIEW CHALLENGE:
--       A retail company's order table contains duplicate events, late-arriving records,
--       multiple orders on the same date, and customers with irregular purchase gaps.
--       Design a query strategy that:
--         1. Deduplicates the source deterministically.
--         2. Finds each customer's first and latest valid order.
--         3. Calculates previous-order amount and date.
--         4. Calculates days between orders.
--         5. Calculates customer running spend.
--         6. Identifies the longest purchase gap.
--         7. Produces the top 3 customers by spend in each customer segment.
--       Before writing SQL, state the grain at every major step.
