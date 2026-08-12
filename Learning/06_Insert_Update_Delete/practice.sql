-- ============================================================
-- 06 — INSERT, UPDATE and DELETE
-- Practice Exercises
-- ============================================================

CREATE DATABASE IF NOT EXISTS dml_practice;
USE dml_practice;

-- Use the exercises after studying README.md and examples.sql.
-- Write your SQL below each question.

-- ============================================================
-- SECTION A — INSERT
-- ============================================================

-- Q1. Create a customers table with customer_id, customer_name, city, and status.
-- Q2. Insert one customer.
-- Q3. Insert five customers in one statement.
-- Q4. Insert a customer while allowing the DEFAULT status to apply.
-- Q5. Explicitly insert NULL into an optional phone column.
-- Q6. Explain why an explicit column list is safer than INSERT INTO table VALUES (...).
-- Q7. Insert products with product_id, product_name, category, and price.
-- Q8. Insert orders that reference existing customers.

-- ============================================================
-- SECTION B — INSERT ... SELECT
-- ============================================================

-- Q9. Create an archived_orders table with the same required columns as orders.
-- Q10. Copy orders older than a specified date into archived_orders.
-- Q11. Copy only completed orders into a reporting table.
-- Q12. Explain when INSERT ... SELECT is preferable to moving data through Python.

-- ============================================================
-- SECTION C — UPDATE
-- ============================================================

-- Q13. Update one customer's city.
-- Q14. Update a customer's city and phone number together.
-- Q15. Increase all Electronics product prices by 10%.
-- Q16. Set order status to 'confirmed' for one order.
-- Q17. Update all pending orders to 'processing' for a selected date.
-- Q18. Use CASE to assign customer priority based on city.
-- Q19. Replace NULL phone numbers with a supplied value.
-- Q20. Preview rows with SELECT before performing a bulk UPDATE.
-- Q21. Return the number of rows affected by an UPDATE.

-- ============================================================
-- SECTION D — DELETE
-- ============================================================

-- Q22. Delete one customer by customer_id.
-- Q23. Delete all cancelled orders.
-- Q24. Preview rows before deleting them.
-- Q25. Explain what happens when DELETE is executed without WHERE.
-- Q26. Explain why deleting a parent row can fail when child rows reference it.
-- Q27. Compare DELETE and TRUNCATE.
-- Q28. Compare TRUNCATE and DROP TABLE.

-- ============================================================
-- SECTION E — NULL AND DEFAULT
-- ============================================================

-- Q29. Insert a row while omitting a column with a DEFAULT value.
-- Q30. Set a nullable column to NULL using UPDATE.
-- Q31. Find rows where a column is NULL.
-- Q32. Explain why column_name = NULL does not work as expected.
-- Q33. Distinguish NULL, 0, empty string, and the text 'NULL'.

-- ============================================================
-- SECTION F — TRANSACTIONS
-- ============================================================

-- Q34. Start a transaction and update two related records.
-- Q35. Validate the changes and COMMIT them.
-- Q36. Make a change and ROLLBACK it.
-- Q37. Explain the difference between COMMIT and ROLLBACK.
-- Q38. Design a bank-transfer example where both updates must succeed together.
-- Q39. Explain why transaction boundaries matter in ETL workflows.

-- ============================================================
-- SECTION G — UPSERT AND DATA LOADING
-- ============================================================

-- Q40. Insert a customer and update the existing row when the primary key already exists.
-- Q41. Design an upsert using a unique business key such as email.
-- Q42. Explain the risks of INSERT IGNORE in a production data pipeline.
-- Q43. Design an incremental load that can be safely rerun.
-- Q44. Explain how duplicate keys can affect an upsert.

-- ============================================================
-- SECTION H — DATA ENGINEERING SCENARIOS
-- ============================================================

-- Q45. A daily source file contains new and existing customers. Design an approach
--     that inserts new customers and updates existing customers.

-- Q46. A pipeline fails after updating half of a batch. How could transactions help?

-- Q47. You need to archive orders older than two years and then remove them from
--     the operational table. Design a safe sequence of operations.

-- Q48. A production UPDATE accidentally targets 10 million rows. What should you
--     check immediately, and how could you reduce this risk next time?

-- Q49. A source sends NULL for a required customer name. How should the pipeline
--     handle the record before INSERT?

-- Q50. A table contains 100 million rows and a large DELETE is required. What
--     operational concerns should you evaluate before running it?

-- Q51. Design an idempotent customer-load strategy using a stable business key.

-- ============================================================
-- SECTION I — INTERVIEW CHALLENGES
-- ============================================================

-- Q52. Write SQL to update only the latest order for a customer.
-- Q53. Write SQL to delete duplicate staging records while retaining one record.
-- Q54. Explain how you would safely run a destructive DELETE in production.
-- Q55. What happens to uncommitted changes if a transaction is rolled back?
-- Q56. Explain why a transaction does not automatically make a bad UPDATE safe.
-- Q57. When would you choose INSERT ... SELECT over a row-by-row INSERT loop?
-- Q58. Explain DELETE vs TRUNCATE from a Data Engineering perspective.
-- Q59. How would you process a CDC stream containing INSERT, UPDATE, and DELETE events?
-- Q60. Design a retry strategy for a failed incremental load without creating duplicates.

-- ============================================================
-- FINAL CHALLENGE
-- ============================================================

-- Q61. Build a complete incremental ecommerce load:
--      1. Load new customers.
--      2. Update changed customers.
--      3. Insert new orders.
--      4. Update changed order statuses.
--      5. Handle duplicate source events.
--      6. Keep the process idempotent.
--      7. Use transactions where appropriate.
--      8. Validate row counts before committing.

-- Final self-check:
-- [ ] INSERT
-- [ ] Multiple-row INSERT
-- [ ] INSERT ... SELECT
-- [ ] UPDATE
-- [ ] Conditional UPDATE
-- [ ] DELETE
-- [ ] NULL handling
-- [ ] DEFAULT handling
-- [ ] Transactions
-- [ ] COMMIT / ROLLBACK
-- [ ] Upsert
-- [ ] Idempotent loading
-- [ ] Safe production modifications
