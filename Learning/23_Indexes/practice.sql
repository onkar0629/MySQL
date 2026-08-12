-- 23_Indexing — Practice
-- No solutions. Use indexing_demo from examples.sql.
-- For every question, explain WHY the index you choose matches the query.

-- Q1. Create an index for frequent lookups by customer_id.

-- Q2. Design a composite index for:
--     WHERE customer_id = ? AND order_date >= ?

-- Q3. The query filters by customer_id and orders by order_date.
--     Propose the index and explain the column order.

-- Q4. Explain whether (customer_id, order_date) is a good index for:
--     WHERE order_date >= ?
--     Verify your reasoning with EXPLAIN.

-- Q5. Create a covering-index candidate for a query returning:
--     customer_id, order_date, amount
--     filtered by customer_id and an order_date range.

-- Q6. Use EXPLAIN to compare a query before and after creating an index.
--     Record key, type, and estimated rows.

-- Q7. Create a unique index for the customers.email business rule.

-- Q8. Explain why a normal B-tree index is less useful for:
--     WHERE email LIKE '%example.com'

-- Q9. Rewrite a DATE(created_at) equality filter as an index-friendly range.

-- Q10. Find existing indexes on orders and identify any overlapping indexes.

-- Q11. Design an index for a join between orders and customers on customer_id.

-- Q12. A status column contains only ACTIVE and INACTIVE. Decide whether a
--      standalone status index is likely to be useful. Explain what data and
--      workload information you would inspect before deciding.

-- Q13. A query selects only columns contained in a composite index. Explain
--      why this may become a covering-index access pattern.

-- Q14. Explain why adding ten indexes to a high-volume staging table can hurt
--      ingestion performance.

-- Q15. A query uses an index but still examines millions of rows. Explain why
--      index usage alone does not prove the query is efficient.

-- Q16. Design an index for an incremental extraction query using updated_at.

-- Q17. A composite index is (status, customer_id, order_date). Explain which
--      of these query patterns can naturally use its leading portion:
--      a) status = ?
--      b) status = ? AND customer_id = ?
--      c) customer_id = ? AND order_date >= ?

-- Q18. Compare these predicates from an indexing perspective:
--      a) order_date >= '2026-08-01'
--      b) DATE(order_date) = '2026-08-01'

-- Q19. A production query is slow after a new index is created. Use EXPLAIN
--      to determine whether MySQL chose the index and whether the index actually
--      reduced the estimated work.

-- Q20. Explain why a large primary key can increase secondary-index size in
--      InnoDB.

-- Q21. Design an index for latest-record lookup by business_key and updated_at.
--      Explain how the query's ordering affects your design.

-- Q22. A table has both (customer_id) and (customer_id, order_date). Determine
--      whether the single-column index is redundant for a given workload.
--      Do not answer from column names alone; inspect query patterns.

-- Q23. Explain why MySQL might choose a full table scan even when an appropriate
--      index exists.

-- Q24. Use EXPLAIN ANALYZE in a test environment to compare two candidate index
--      designs. Record the actual rows and timing information.

-- Q25. Final interview scenario:
--      A 500-million-row orders table has these queries:
--      1. Find orders for a customer in a date range.
--      2. Incrementally extract rows by updated_at.
--      3. Join orders to customers by customer_id.
--      4. Produce a narrow customer/date/amount report.
--      Design a small set of indexes that supports the workload without creating
--      unnecessary write amplification. Explain your trade-offs.
