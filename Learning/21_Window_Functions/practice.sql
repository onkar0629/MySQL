-- 21_Window_Functions — Practice
-- No solutions. Solve each problem using window functions where appropriate.

-- Use the tables from examples.sql unless the question defines another schema.

-- Q1. Return every employee with the average salary of their department.

-- Q2. Assign a unique salary row number within each department.
--     Resolve ties deterministically using employee_id.

-- Q3. Return the highest-paid employee in each department.

-- Q4. Return the top 3 employees by salary in each department.
--     Decide whether ROW_NUMBER, RANK, or DENSE_RANK matches the requirement.

-- Q5. Return employees whose salary is greater than their department average.

-- Q6. For every customer order, return the previous order amount.

-- Q7. For every customer order, return the number of days since the previous order.

-- Q8. For every customer order, return the next order date.

-- Q9. Calculate a running total of customer spending ordered by order_date.
--     Make the ordering deterministic.

-- Q10. Calculate the change in amount between each order and the customer's
--      previous order.

-- Q11. Given a staging table with duplicate customer records, keep only the
--      latest record for each customer_id.

-- Q12. Return the second-highest salary in every department.
--      Consider how ties should affect the answer.

-- Q13. Find the first order and latest order for every customer using window
--      functions rather than GROUP BY.

-- Q14. Identify customers whose order amount increased compared with their
--      previous order.

-- Q15. Calculate a 7-row moving average of daily sales.
--      Explain why this is not necessarily a 7-calendar-day average.

-- Q16. Find consecutive login/event periods using LAG and a generated group key.
--      This is a gaps-and-islands problem.

-- Q17. Explain why a window-function alias cannot normally be filtered directly
--      in WHERE and rewrite the query using a CTE.

-- Q18. A LEFT JOIN multiplies rows before a window calculation. Explain how
--      this can produce incorrect results and how you would fix the grain.

-- Q19. Compare ROW_NUMBER, RANK, and DENSE_RANK for a top-3 business rule.
--      State which one you would choose and why.

-- Q20. Design a query to identify the latest CDC record for each business key,
--      using event_time and a unique sequence/id as deterministic ordering keys.