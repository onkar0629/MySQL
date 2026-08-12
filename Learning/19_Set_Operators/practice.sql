-- 19_Set_Operators — Practice
-- Solve each problem yourself. Do not add answers here.

-- 1. Return a distinct list of customer IDs that appear in either
--    online_customers or store_customers using UNION.

-- 2. Return all customer ID occurrences from both tables using UNION ALL.
--    Do not remove duplicates.

-- 3. Find customers who exist in both online_customers and store_customers.
--    Use INTERSECT.

-- 4. Find customers who exist in online_customers but not store_customers.
--    Use EXCEPT.

-- 5. Find customers who exist in store_customers but not online_customers.
--    Reverse the EXCEPT operation.

-- 6. Combine two source-system customer tables with UNION ALL and add
--    a source_system column containing the originating system.

-- 7. Create one consolidated customer result and sort the final result
--    by customer_id ascending.

-- 8. Compare source_customers and target_customers using customer_id.
--    Return IDs present in source but missing from target.

-- 9. Reverse the previous comparison and return target-only customer IDs.

-- 10. Compare source_customers and target_customers using customer_id,
--     customer_name, and email. Identify complete rows present in source
--     but not target.

-- 11. Build a single data-quality exception result containing:
--     a) customers with NULL email
--     b) customers whose email does not contain '@'
--     Include an issue column and preserve both exception types.

-- 12. Write a query that takes the top 5 highest-value orders from each
--     of two source tables and then combines those two top-5 sets.
--     The LIMIT must apply independently to each source.

-- 13. Explain in a SQL comment why UNION may be more expensive than
--     UNION ALL. Then write an example where UNION ALL is the correct choice.

-- 14. Given two datasets containing customer IDs, determine whether they
--     contain exactly the same distinct customer set. Use set operations.

-- 15. Design a source-to-target reconciliation query that reports:
--     SOURCE_ONLY, TARGET_ONLY, and COMMON customer IDs in one result.
--     Preserve the category in an issue/status column.

-- Interview challenge:
-- 16. A daily pipeline receives records from CRM_A and CRM_B with the same
--     schema. Some customers legitimately exist in both systems. Explain
--     whether you would use UNION or UNION ALL and why. Then write the SQL.
