# 22 — Transactions and ACID

## 📌 Overview

A transaction groups related SQL operations into one logical unit of work. Transactions are essential when multiple changes must either succeed together or be rolled back together.

For Data Engineering, the important topics are **ACID, COMMIT, ROLLBACK, savepoints, autocommit, isolation levels, locking, deadlocks, and transaction boundaries**.

## 1. What Is a Transaction?

A transaction is a sequence of operations treated as one unit of work.

```sql
START TRANSACTION;

UPDATE accounts
SET balance = balance - 1000
WHERE account_id = 1;

UPDATE accounts
SET balance = balance + 1000
WHERE account_id = 2;

COMMIT;
```

If a later operation fails before commit, the transaction can be rolled back.

## 2. ACID

| Property | Meaning |
|---|---|
| **Atomicity** | All required changes succeed together or are rolled back |
| **Consistency** | A successful transaction preserves database rules and valid state |
| **Isolation** | Concurrent transactions follow the selected isolation guarantees |
| **Durability** | Committed changes are intended to survive failures subject to engine/configuration guarantees |

For transactional MySQL workloads, **InnoDB** is the relevant storage engine.

## 3. COMMIT and ROLLBACK

```sql
START TRANSACTION;

UPDATE orders
SET status = 'SHIPPED'
WHERE order_id = 1001;

COMMIT;
```

```sql
START TRANSACTION;

UPDATE orders
SET status = 'CANCELLED'
WHERE order_id = 1001;

ROLLBACK;
```

## 4. Autocommit

Check the session setting:

```sql
SELECT @@autocommit;
```

With autocommit enabled, successful individual statements are normally committed automatically. Use explicit transaction blocks when multiple statements must be atomic.

## 5. SAVEPOINT

```sql
START TRANSACTION;

UPDATE orders
SET status = 'PROCESSING'
WHERE order_id = 1001;

SAVEPOINT order_updated;

UPDATE order_items
SET quantity = quantity + 1
WHERE order_id = 1001;

ROLLBACK TO SAVEPOINT order_updated;

COMMIT;
```

`ROLLBACK TO SAVEPOINT` does not end the transaction.

## 6. Transaction Boundaries

A transaction should contain the smallest logical unit that must be atomic.

Too large can cause long locks, contention, larger undo/rollback cost, and difficult recovery. Too small can break atomicity when related operations are committed separately.

## 7. Isolation Levels

| Level | Key behavior |
|---|---|
| `READ UNCOMMITTED` | Allows dirty reads |
| `READ COMMITTED` | Reads committed data; repeated reads may change |
| `REPEATABLE READ` | Consistent reads use a transaction snapshot |
| `SERIALIZABLE` | Strongest standard isolation; more restrictive concurrency |

Check:

```sql
SELECT @@transaction_isolation;
```

Set for the session:

```sql
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
```

## 8. Concurrency Anomalies

- **Dirty read:** reading another transaction's uncommitted change.
- **Non-repeatable read:** the same row returns a different committed value later in the transaction.
- **Phantom read:** a repeated range query sees a different set of matching rows.

The isolation level determines which behaviors are possible.

## 9. Ordinary Read vs Locking Read

Ordinary read:

```sql
SELECT balance
FROM accounts
WHERE account_id = 1;
```

Locking read:

```sql
SELECT balance
FROM accounts
WHERE account_id = 1
FOR UPDATE;
```

Use `FOR UPDATE` when a transaction needs to read rows and then make a modification based on them while coordinating concurrent work.

## 10. Inventory Pattern

```sql
START TRANSACTION;

SELECT stock_quantity
FROM inventory
WHERE product_id = 101
FOR UPDATE;

UPDATE inventory
SET stock_quantity = stock_quantity - 1
WHERE product_id = 101
  AND stock_quantity >= 1;

COMMIT;
```

The application should verify the affected-row count and handle insufficient stock.

## 11. Deadlocks

A deadlock occurs when transactions form a cycle of lock dependencies:

```text
Transaction A → locks Row 1
Transaction B → locks Row 2
A waits for Row 2
B waits for Row 1
```

InnoDB detects the deadlock and rolls back one transaction. Applications should safely retry operations that are designed to be retryable.

## 12. Reducing Deadlocks

- Access shared rows in a consistent order.
- Keep transactions short.
- Lock only required rows.
- Use appropriate indexes.
- Avoid external API calls while holding locks.
- Retry deadlock victims with bounded backoff.

## 13. DDL and Transactions

Do not assume every MySQL statement has the same rollback behavior as ordinary DML. Many DDL operations can cause implicit commits.

Therefore, do not mix schema changes into a business-data transaction when atomic rollback of both is required.

## 14. Data Engineering Use Cases

Transactions are useful for:

- Atomic control-table updates
- Claiming pipeline work
- Small atomic batch loads
- Job status transitions
- Related metadata changes
- Inventory/counter updates

For very large ETL workloads, transaction size must be balanced against locking, undo growth, recovery time, and downstream availability.

## 15. Transactions vs Idempotency

A transaction does **not** make a pipeline idempotent.

```text
Transaction succeeds
      ↓
response is lost
      ↓
client retries
      ↓
operation runs again
```

Idempotency may require unique business keys, upserts, batch identifiers, deduplication, or checkpoints.

## 16. Atomic Pipeline Claim

```sql
START TRANSACTION;

UPDATE pipeline_runs
SET status = 'RUNNING',
    started_at = CURRENT_TIMESTAMP
WHERE run_id = 5001
  AND status = 'PENDING';

-- Verify affected_rows = 1.
COMMIT;
```

The predicate prevents an already-claimed run from being claimed again.

## ⚡ Performance and Operational Considerations

- Keep transactions short.
- Index predicates used by critical updates and locking reads.
- Avoid external calls while holding locks.
- Monitor deadlocks and lock waits.
- Choose isolation based on requirements.
- Batch large loads appropriately.
- Consider rollback cost before creating very large transactions.
- Verify affected-row counts for critical state transitions.

## ⚠️ Common Mistakes

- Forgetting to `COMMIT` an explicit transaction.
- Assuming every statement is rollback-safe.
- Keeping transactions open during API/network calls.
- Using `FOR UPDATE` unnecessarily.
- Acquiring locks in inconsistent order.
- Assuming ACID means idempotent.
- Using one enormous transaction for a large ETL job without considering operational impact.
- Changing isolation levels without understanding the workload.

## 🎤 Interview-Focused Questions

### Q1. What is a transaction?
<details>
<summary><strong>Answer</strong></summary>

A transaction is a logical unit of work whose related changes are committed together or rolled back together.
</details>

### Q2. Explain ACID.
<details>
<summary><strong>Answer</strong></summary>

Atomicity provides all-or-nothing execution. Consistency preserves valid database state and rules. Isolation controls concurrent transaction behavior. Durability makes committed changes persistent according to the storage engine and configuration.
</details>

### Q3. COMMIT vs ROLLBACK?
<details>
<summary><strong>Answer</strong></summary>

`COMMIT` commits the transaction's changes. `ROLLBACK` undoes uncommitted changes in the current transaction.
</details>

### Q4. What is SAVEPOINT?
<details>
<summary><strong>Answer</strong></summary>

A savepoint marks a position inside a transaction so you can roll back to that point without ending the transaction.
</details>

### Q5. What is autocommit?
<details>
<summary><strong>Answer</strong></summary>

With autocommit enabled, successful individual statements are normally committed automatically. Explicit transactions are used when multiple statements must be atomic.
</details>

### Q6. What are MySQL's standard isolation levels?
<details>
<summary><strong>Answer</strong></summary>

`READ UNCOMMITTED`, `READ COMMITTED`, `REPEATABLE READ`, and `SERIALIZABLE`.
</details>

### Q7. What is a deadlock?
<details>
<summary><strong>Answer</strong></summary>

A deadlock occurs when transactions wait on locks held by each other, creating a cycle. InnoDB detects it and rolls back one transaction.
</details>

### Q8. How do you reduce deadlocks?
<details>
<summary><strong>Answer</strong></summary>

Keep transactions short, access shared rows consistently, use suitable indexes, avoid unnecessary locks, and safely retry deadlocked transactions.
</details>

### Q9. Why use SELECT FOR UPDATE?
<details>
<summary><strong>Answer</strong></summary>

Use it when a transaction must read rows and then modify them while coordinating concurrent transactions.
</details>

### Q10. Does a transaction make an ETL pipeline idempotent?
<details>
<summary><strong>Answer</strong></summary>

No. Transactions provide atomic database changes, but retries can still repeat a business effect. Idempotency needs additional design such as unique keys, deduplication, upserts, or batch identifiers.
</details>

### Q11. Why avoid API calls inside a database transaction?
<details>
<summary><strong>Answer</strong></summary>

The transaction may hold locks while waiting for the external service, increasing lock duration and contention. Keep external calls outside the critical transaction where possible.
</details>

### Q12. Why can a huge ETL transaction be problematic?
<details>
<summary><strong>Answer</strong></summary>

It can hold locks for a long time, increase undo and rollback cost, increase contention, and make recovery harder. Appropriate batching can reduce these operational risks.
</details>

## 🔄 Quick Revision

| Concept | Key Point |
|---|---|
| Transaction | Logical unit of work |
| Atomicity | All-or-nothing |
| Consistency | Preserves valid state/rules |
| Isolation | Controls concurrent behavior |
| Durability | Committed changes persist subject to configuration |
| `COMMIT` | Commit changes |
| `ROLLBACK` | Undo uncommitted changes |
| `SAVEPOINT` | Partial rollback point |
| Autocommit | Automatically commits individual statements |
| Isolation level | Controls concurrency guarantees |
| `FOR UPDATE` | Locking read |
| Deadlock | Cyclic lock dependency |
| Idempotency | Safe repeated business effect; separate from ACID |

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — transaction, savepoint, isolation, and locking examples
- [`practice.sql`](./practice.sql) — transaction and Data Engineering interview exercises without solutions
