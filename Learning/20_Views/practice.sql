-- 20_Views — Practice
-- Do not add solutions here.

-- Use the customers and orders tables from examples.sql.

-- Q1. Create a view containing only ACTIVE customers.

-- Q2. Create a view showing customer_id, customer_name, and total order count.

-- Q3. Create a view showing customer_id and total spending.

-- Q4. Modify the active-customer view to expose the customer's status.

-- Q5. Query the customer summary view and return customers with total spend >= 2000.

-- Q6. Create a view containing orders from the current month.

-- Q7. Create a view that exposes only order_id, customer_id, order_date,
--     and amount from the orders table.

-- Q8. Create a view that returns customers who have never placed an order.

-- Q9. Create a view that summarizes daily order count and daily sales.

-- Q10. Explain whether the view from Q9 is expected to be directly updatable.

-- Q11. Create a view that hides the email column and exposes only the
--     customer fields required by an analyst.

-- Q12. Write a query using a view and EXPLAIN it to investigate performance.

-- Q13. Compare a CTE and a view for the same customer-spending calculation.
--      Decide which is more appropriate when the logic is reused by many queries.

-- Q14. Identify a potential problem with using SELECT * in a long-lived view.

-- Q15. Design a view that can act as a stable reporting interface even if
--      the underlying base table contains additional columns.