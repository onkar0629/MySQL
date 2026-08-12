-- ============================================================
-- 05 — Constraints and Keys
-- Practice Exercises
-- ============================================================

CREATE DATABASE IF NOT EXISTS constraints_practice;
USE constraints_practice;

-- Use the following exercises after studying README.md and examples.sql.

-- ============================================================
-- SECTION A — BASIC CONSTRAINTS
-- ============================================================

-- Q1. Create a customers table with customer_id as the PRIMARY KEY.
-- Q2. Make customer_name NOT NULL.
-- Q3. Make email UNIQUE.
-- Q4. Add a status column with DEFAULT 'active'.
-- Q5. Add an age CHECK constraint requiring age >= 18.

-- ============================================================
-- SECTION B — PRIMARY AND COMPOSITE KEYS
-- ============================================================

-- Q6. Create products with product_id as the PRIMARY KEY.
-- Q7. Create order_items where (order_id, product_id) is the composite PRIMARY KEY.
-- Q8. Explain why product_id alone cannot identify a row in order_items.
-- Q9. Design a warehouse_stock table using (warehouse_id, product_id) as the primary key.
-- Q10. Identify a suitable candidate key for a users table containing user_id and email.

-- ============================================================
-- SECTION C — FOREIGN KEYS
-- ============================================================

-- Q11. Create departments and employees tables with department_id as a FOREIGN KEY.
-- Q12. Insert a valid employee referencing an existing department.
-- Q13. Attempt to insert an employee referencing a non-existent department.
-- Q14. Explain the referential-integrity error.
-- Q15. Add a foreign key to an already-created orders table using ALTER TABLE.

-- ============================================================
-- SECTION D — FOREIGN KEY ACTIONS
-- ============================================================

-- Q16. Create a parent/child relationship using ON DELETE CASCADE.
-- Q17. Demonstrate what happens to child rows when the parent is deleted.
-- Q18. Create a relationship using ON DELETE SET NULL.
-- Q19. Explain when SET NULL is preferable to CASCADE.
-- Q20. Create a relationship using ON UPDATE CASCADE.
-- Q21. Explain why CASCADE should be used carefully in production.

-- ============================================================
-- SECTION E — UNIQUE, DEFAULT, NOT NULL, CHECK
-- ============================================================

-- Q22. Create a products table where SKU must be unique.
-- Q23. Add a CHECK constraint requiring price >= 0.
-- Q24. Add a CHECK constraint requiring quantity > 0.
-- Q25. Add a default status of 'pending'.
-- Q26. Determine which columns should be NOT NULL in an orders table.
-- Q27. Create a composite UNIQUE constraint on (warehouse_id, product_id).

-- ============================================================
-- SECTION F — ALTER TABLE
-- ============================================================

-- Q28. Add a PRIMARY KEY to an existing table.
-- Q29. Add a UNIQUE constraint using ALTER TABLE.
-- Q30. Add a CHECK constraint using ALTER TABLE.
-- Q31. Add a FOREIGN KEY using ALTER TABLE.
-- Q32. Drop a FOREIGN KEY safely.
-- Q33. Inspect the table definition before and after changing constraints.

-- ============================================================
-- SECTION G — KEY DESIGN
-- ============================================================

-- Q34. Explain candidate key vs primary key.
-- Q35. Explain primary key vs alternate key.
-- Q36. Compare natural keys and surrogate keys.
-- Q37. Choose a key strategy for an ecommerce customer table.
-- Q38. Choose a key strategy for a fact table in a Data Warehouse.
-- Q39. Explain why a business identifier may not always be a good primary key.

-- ============================================================
-- SECTION H — DATA ENGINEERING SCENARIOS
-- ============================================================

-- Q40. A daily customer file contains duplicate customer emails. Which constraint
--     would protect the operational table from duplicate emails?

-- Q41. An orders pipeline contains customer_ids that do not exist in the customer
--     table. Explain how a FOREIGN KEY can detect this problem.

-- Q42. A source system sends negative product prices. Design a CHECK constraint
--     to reject them.

-- Q43. A warehouse can store a product only once. Design the appropriate key.

-- Q44. You need to delete a customer and automatically remove dependent records.
--     Which foreign-key action could be used, and what is the risk?

-- Q45. A nullable manager_id references employees.employee_id. Design the relationship
--     so deleting the manager sets manager_id to NULL.

-- Q46. Existing production data violates a proposed UNIQUE constraint. What should
--     you do before adding the constraint?

-- Q47. A pipeline loads records into a table with NOT NULL columns but some source
--     records are missing those fields. How should the pipeline handle this?

-- Q48. Design an order_items table where the same product cannot appear twice in
--     the same order.

-- Q49. Explain why database constraints should complement, rather than completely
--     replace, ETL data-quality validation.

-- ============================================================
-- SECTION I — INTERVIEW CHALLENGES
-- ============================================================

-- Q50. An employee table has employee_id, email, and phone_number. Both email and
--     phone_number are guaranteed unique. Which are candidate keys, and which one
--     would you choose as the primary key? Explain.

-- Q51. Can a table have multiple primary keys? Explain the correct interpretation
--     when multiple columns participate in one primary key.

-- Q52. Can a foreign key reference a UNIQUE key instead of a PRIMARY KEY?
--     Verify this behavior in MySQL and explain the result.

-- Q53. A parent table has 10,000 child rows. What operational risk should you consider
--     before using ON DELETE CASCADE?

-- Q54. A table has a composite primary key (customer_id, product_id). Can another
--     table reference only product_id from that composite key? Investigate and explain.

-- Q55. You need to add a FOREIGN KEY to a table containing 50 million rows. What
--     data-quality and operational checks should happen before the migration?

-- Q56. Design a production-ready schema for customers, orders, and order_items using
--     appropriate primary keys, foreign keys, unique constraints, and checks.

-- ============================================================
-- FINAL CHALLENGE
-- ============================================================

-- Q57. Design an ecommerce schema with:
--      customers(customer_id, email, name)
--      products(product_id, sku, name, price)
--      orders(order_id, customer_id, order_date, status)
--      order_items(order_id, product_id, quantity)
--
-- Requirements:
--      1. IDs uniquely identify rows.
--      2. Customer email must be unique.
--      3. Product SKU must be unique.
--      4. Price cannot be negative.
--      5. Quantity must be greater than zero.
--      6. Orders must reference existing customers.
--      7. Order items must reference existing orders and products.
--      8. The same product cannot appear twice in one order.
--
-- Implement the complete schema using appropriate constraints.

-- Self-check:
-- [ ] PRIMARY KEY
-- [ ] FOREIGN KEY
-- [ ] UNIQUE
-- [ ] NOT NULL
-- [ ] DEFAULT
-- [ ] CHECK
-- [ ] Composite key
-- [ ] Foreign-key actions
-- [ ] ALTER TABLE
-- [ ] Natural vs surrogate key decisions
