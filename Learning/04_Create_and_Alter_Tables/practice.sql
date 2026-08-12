-- ============================================================
-- MySQL Learning: 04 — Create and Alter Tables
-- Practice Exercises
-- ============================================================
-- Instructions:
-- 1. Create a practice database.
-- 2. Solve each exercise yourself.
-- 3. Do not look at examples.sql until you have attempted it.
-- ============================================================

CREATE DATABASE IF NOT EXISTS table_practice_db;
USE table_practice_db;

-- ------------------------------------------------------------
-- Section A — CREATE TABLE
-- ------------------------------------------------------------

-- Q1. Create a table named departments with:
--     department_id INT
--     department_name VARCHAR(100)

-- Q2. Create an employees table with:
--     employee_id INT PRIMARY KEY
--     employee_name VARCHAR(100) NOT NULL
--     department_id INT
--     salary DECIMAL(12,2)

-- Q3. Create a customers table using CREATE TABLE IF NOT EXISTS.
--     Include customer_id, customer_name, email, and signup_date.

-- Q4. Create a products table with an AUTO_INCREMENT primary key.
--     Include product_name, price, and is_active.

-- Q5. Add suitable DEFAULT values to the products table for
--     price and is_active.

-- ------------------------------------------------------------
-- Section B — INSPECTION
-- ------------------------------------------------------------

-- Q6. Display the columns of employees using DESCRIBE.

-- Q7. Display the complete CREATE TABLE statement for employees.

-- Q8. List all tables in the current database.

-- Q9. Explain when SHOW CREATE TABLE is more useful than DESCRIBE.

-- ------------------------------------------------------------
-- Section C — ALTER TABLE
-- ------------------------------------------------------------

-- Q10. Add a phone column to employees.

-- Q11. Add both city and hire_date to employees in one ALTER TABLE.

-- Q12. Change salary from DECIMAL(12,2) to DECIMAL(14,2).

-- Q13. Rename employee_name to full_name.

-- Q14. Rename full_name back to employee_name using CHANGE COLUMN.

-- Q15. Rename a column using RENAME COLUMN instead of CHANGE COLUMN.

-- Q16. Remove the phone column.

-- Q17. Rename employees to staff.

-- Q18. Rename staff back to employees.

-- ------------------------------------------------------------
-- Section D — DEFAULTS AND CONSTRAINTS
-- ------------------------------------------------------------

-- Q19. Add a status column to employees with a default value of
--     'active'.

-- Q20. Add a UNIQUE constraint for customer email.

-- Q21. Explain why adding a NOT NULL column to a populated table
--     requires checking existing rows.

-- Q22. Add an order_amount column to orders as DECIMAL(12,2),
--     NOT NULL, with a default of 0.00.

-- ------------------------------------------------------------
-- Section E — CREATE TABLE AS SELECT
-- ------------------------------------------------------------

-- Q23. Create an employee_backup table containing employee_id,
--     employee_name, and salary from employees.

-- Q24. Inspect employee_backup and determine which structural
--     properties were not automatically reproduced.

-- ------------------------------------------------------------
-- Section F — Data Engineering Scenarios
-- ------------------------------------------------------------

-- Q25. A production orders table has 50 million rows. You need to
--     add a nullable source_system column. What should you check
--     before applying the migration?

-- Q26. An ETL pipeline references employees.employee_name. The
--     business wants the column renamed to full_name. Describe a
--     safe migration approach.

-- Q27. A developer used CREATE TABLE AS SELECT to create a backup.
--     What should you verify before treating it as a full structural
--     copy of the original table?

-- Q28. You need to remove an obsolete column from a table used by
--     dashboards and ETL jobs. List the dependency checks you would do.

-- Q29. A new NOT NULL column is required on a populated customer
--     table. Design a migration strategy that avoids invalid existing
--     rows.

-- Q30. Explain why schema changes should be version-controlled in a
--     Data Engineering project.

-- ------------------------------------------------------------
-- Section G — Interview Challenges
-- ------------------------------------------------------------

-- Q31. What is the difference between MODIFY COLUMN and CHANGE COLUMN?

-- Q32. Does CREATE TABLE IF NOT EXISTS update an existing table?

-- Q33. What happens to the data when a column is dropped?

-- Q34. Does CREATE TABLE AS SELECT copy indexes and primary keys?

-- Q35. What is the difference between RENAME TABLE and ALTER TABLE ... RENAME TO?

-- Q36. Why can adding a NOT NULL column be more complicated than
--     adding a nullable column?

-- Q37. How would you safely rename a table that is referenced by an
--     application and several ETL jobs?

-- Q38. What factors influence the risk of an ALTER TABLE operation
--     on a large production table?

-- ------------------------------------------------------------
-- Section H — Final Practical Challenge
-- ------------------------------------------------------------

-- Q39. Design a sales_orders table for a Data Engineering project.
--     Requirements:
--       - order_id: auto-incrementing primary key
--       - customer_id: large integer
--       - order_amount: exact monetary value
--       - order_date: business date
--       - created_at: date and time
--       - status: required with a sensible default
--       - source_system: optional string
--
--     Then:
--       1. Create the table.
--       2. Inspect it with SHOW CREATE TABLE.
--       3. Add a processed_at column.
--       4. Change source_system to a more appropriate length.
--       5. Rename status to order_status.
--       6. Inspect the final definition.

-- ------------------------------------------------------------
-- Self-check questions
-- ------------------------------------------------------------

-- Q40. Can you explain CREATE TABLE vs ALTER TABLE without notes?
-- Q41. Can you choose between MODIFY COLUMN and CHANGE COLUMN?
-- Q42. Can you explain the risk of DROP COLUMN?
-- Q43. Can you explain why CTAS does not replace proper table DDL?
-- Q44. Can you describe a safe production schema migration?

-- ============================================================
