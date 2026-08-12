-- 22_Transactions_and_ACID — Practice
-- No solutions. Use the transactions_demo tables from examples.sql.

-- Q1. Transfer 2500 from account 1 to account 2 atomically.
--     Roll back if either update does not affect exactly one row.

-- Q2. Write a transaction that cancels an order and updates related inventory.
--     Explain why both changes belong in one transaction.

-- Q3. Demonstrate ROLLBACK by changing an account balance and proving that
--     the original balance is restored.

-- Q4. Use SAVEPOINT to keep the first update in a transaction but undo the
--     second update.

-- Q5. Check the session autocommit and transaction isolation level.

-- Q6. Explain the difference between READ COMMITTED and REPEATABLE READ
--     for repeated reads of the same row.

-- Q7. Design a safe inventory decrement using SELECT ... FOR UPDATE.
--     Prevent stock_quantity from becoming negative.

-- Q8. Two transactions update the same two accounts in opposite order.
--     Explain how this can create a deadlock and how you would reduce the risk.

-- Q9. Design an atomic claim operation for a PENDING pipeline run so that
--     two workers cannot both successfully claim the same run.

-- Q10. Explain why ROW_COUNT() should be checked after a conditional UPDATE
--      used to claim work.

-- Q11. Design a transaction that updates a target table and its load-control
--      record together. Decide what should happen if the control update fails.

-- Q12. Explain why a transaction does not automatically make a pipeline
--      idempotent when a client retries after losing the response.

-- Q13. Give an example where a long-running API call inside a transaction
--      creates unnecessary lock contention. Redesign the transaction boundary.

-- Q14. Explain dirty reads, non-repeatable reads, and phantom reads.

-- Q15. Choose an isolation level for a workload that requires committed reads
--      but can tolerate a row changing between two reads. Justify the choice.

-- Q16. Explain why SELECT ... FOR UPDATE is different from an ordinary SELECT
--      and when it is appropriate.

-- Q17. A batch updates 10 million rows in one transaction. List the operational
--      risks and propose a safer batching strategy.

-- Q18. Explain why DDL should not be assumed to participate in the same rollback
--      behavior as ordinary DML in MySQL.

-- Q19. Design a retry strategy for a deadlocked transaction. Include bounded
--      retries and backoff.

-- Q20. Explain the four ACID properties using a bank-transfer or ETL example.
