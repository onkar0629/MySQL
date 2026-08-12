-- 17_Subqueries — Practice
-- Do not add solutions here.
-- Solve each problem yourself using MySQL.

USE subqueries_demo;

-- Q1. Find employees whose salary is greater than the overall
--     average salary.

-- Q2. Find employees who work in departments where the
--     maximum salary is greater than 80000.

-- Q3. Find the employee(s) with the highest salary in each department.
--     Do not assume department names are unique.

-- Q4. Find employees who earn more than the average salary
--     of their own department.

-- Q5. Find departments that have at least one employee earning
--     more than 85000 using EXISTS.

-- Q6. Find departments that have no employee earning more than 90000
--     using NOT EXISTS.

-- Q7. Find customers whose total order amount is greater than
--     the average total spend per customer.

-- Q8. Find customers who have placed more orders than the
--     average number of orders per customer.

-- Q9. Find orders whose amount is greater than the average order
--     amount for the same customer.

-- Q10. Find the second-highest salary using a subquery.
--      Do not use LIMIT/OFFSET.

-- Q11. Find employees who belong to the department with the
--      highest average salary.

-- Q12. Find customers who have placed at least one order above
--      the overall average order amount using EXISTS.

-- Q13. Find customers who have never placed an order above 2000
--      using NOT EXISTS.

-- Q14. Identify customers whose total spend is above the average
--      customer spend and return customer_id and total_spend.

-- Q15. Solve Q4 again using a JOIN and compare it conceptually
--      with the correlated-subquery approach.

-- Interview Challenge:
-- A fact table contains multiple orders per customer and a customer
-- dimension contains one row per customer.
-- Write a query to identify customers whose latest order amount is
-- greater than that customer's average order amount.
-- Think carefully about the grain and how the subquery is correlated.