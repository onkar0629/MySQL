# 22 — Transactions and ACID

> [!NOTE]
> A transaction is a **logical unit of work**. The purpose is not simply to run several SQL statements together; it is to define which changes must succeed together, how concurrent work may interact, and what happens when something fails.

## 📌 What You Should Be Able to Recall Later

After revisiting this topic months from now, you should be able to explain and use:

- What a transaction is and why it is needed
- ACID and what each property means in practice
- `START TRANSACTION`, `COMMIT`, and `ROLLBACK`
- Autocommit
- `SAVEPOINT`
- Transaction boundaries
- MySQL/InnoDB transaction behavior
- Isolation levels
- Dirty, non-repeatable, and phantom reads
- Consistent reads vs locking reads
- `SELECT ... FOR UPDATE`
- Row locking and lock contention
- Deadlocks and retry strategy
- Conditional updates for atomic work claiming
- Why transactions do not provide idempotency
- DML vs DDL transaction behavior
- Transaction design for ETL/Data Engineering workloads
- Performance and operational trade-offs

---

# 1. What Is a Transaction?

A transaction is a sequence of database operations treated as one logical unit of work.

Consider a bank transfer:

```text
Account A: -1000
Account B: +1000
```

These two changes are logically connected.

You do **not** want this state:

```text
Account A: -1000
Account B: unchanged
```

If the second operation fails, the first operation should not remain committed.

Example:

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

If the transaction cannot safely complete:

```sql
ROLLBACK;
```

### Mental model

```text
START
  ↓
statement 1
  ↓
statement 2
  ↓
statement 3
  ↓
COMMIT
  ↓
changes become committed
```

If failure occurs before commit:

```text
START
  ↓
statement 1
  ↓
statement 2 fails
  ↓
ROLLBACK
  ↓
uncommitted changes undone
```

---

# 2. ACID — The Four Properties

ACID describes important transactional guarantees.

| Property | Meaning | Practical question |
|---|---|---|
| **Atomicity** | The transaction is treated as one unit | Did all required changes succeed together? |
| **Consistency** | A successful transaction preserves database rules and valid state | Did the transaction leave the database in a valid state? |
| **Isolation** | Concurrent transactions are controlled according to the isolation level | What can one transaction see from another? |
| **Durability** | Committed changes survive failures according to the engine/configuration guarantees | Will committed data remain after a failure? |

For normal transactional MySQL work, **InnoDB** is the important storage engine.

### Important distinction

ACID does **not** mean:

- every query is automatically correct
- every pipeline is idempotent
- every transaction is fast
- deadlocks cannot occur
- concurrent workloads never block

ACID provides transactional guarantees; application and pipeline design still matter.

---

# 3. Atomicity

Atomicity means related operations are committed as a unit.

Example:

```sql
START TRANSACTION;

UPDATE orders
SET status = 'PAID'
WHERE order_id = 1001;

UPDATE payments
SET status = 'CAPTURED'
WHERE order_id = 1001;

COMMIT;
```

If the payment update cannot be completed, the application can roll back the transaction rather than leaving an inconsistent partial state.

### Data Engineering example

Suppose a load performs:

```text
Insert batch rows
      +
Update load-control table
```

If the load-control update is part of the same atomic unit, you avoid reporting a successful batch when its corresponding data changes were not committed.

---

# 4. Consistency

Consistency means a **successful transaction** preserves the database's defined rules and constraints.

Examples include:

- Primary-key uniqueness
- Foreign-key relationships
- `NOT NULL` requirements
- `CHECK` constraints where enforced
- Application-defined invariants

Example invariant:

```text
account balance must not become negative
```

A transaction can help enforce this when combined with appropriate locking and conditional updates.

Consistency does not mean that MySQL can understand every business rule automatically. The application/query design must enforce rules that are not represented as database constraints.

---

# 5. Isolation

Isolation controls how concurrent transactions interact and what changes one transaction can observe from another.

Consider two workers:

```text
Worker A                  Worker B
   |                         |
   | update row              |
   |                         | read/update row
   |                         |
```

Without appropriate concurrency control, both workers may make decisions using stale or conflicting information.

Isolation is therefore a trade-off between:

```text
stronger guarantees
       ↕
more concurrency / less contention
```

The correct choice depends on the workload.

---

# 6. Durability

After a transaction is successfully committed, the database provides durability according to the storage engine and server configuration.

For practical learning:

```text
COMMIT
  ↓
transaction becomes committed
  ↓
changes are intended to survive failure
```

Do not interpret durability as an absolute promise independent of configuration, hardware, storage, or failure mode.

---

# 7. START TRANSACTION

Explicit transaction:

```sql
START TRANSACTION;

UPDATE orders
SET status = 'SHIPPED'
WHERE order_id = 1001;

UPDATE inventory
SET stock_quantity = stock_quantity - 1
WHERE product_id = 101;

COMMIT;
```

`BEGIN` can also be used as a transaction-start statement in MySQL, but `START TRANSACTION` is explicit and clear when teaching transaction boundaries.

---

# 8. COMMIT

`COMMIT` ends the transaction and commits its changes.

```sql
START TRANSACTION;

UPDATE accounts
SET balance = balance - 100
WHERE account_id = 1;

COMMIT;
```

After commit, the changes are no longer part of the current uncommitted transaction.

---

# 9. ROLLBACK

`ROLLBACK` ends the current transaction and undoes its uncommitted transactional changes.

```sql
START TRANSACTION;

UPDATE accounts
SET balance = balance - 100
WHERE account_id = 1;

ROLLBACK;
```

The original balance is restored for the transaction's uncommitted change.

### Important

Do not assume `ROLLBACK` can undo every statement in MySQL. Transaction behavior depends on the statement and storage engine; DDL requires special attention.

---

# 10. Autocommit

Check the current session setting:

```sql
SELECT @@autocommit;
```

With autocommit enabled, successful individual statements are normally committed automatically.

That means a simple statement such as:

```sql
UPDATE employees
SET salary = salary + 1000
WHERE employee_id = 101;
```

normally becomes its own transaction unless you explicitly start a transaction.

### Why this matters

If two statements must succeed together:

```sql
START TRANSACTION;

statement_1;
statement_2;

COMMIT;
```

Do not rely on autocommit to make unrelated statements atomic.

---

# 11. SAVEPOINT

A savepoint creates a point inside a transaction to which you can partially roll back.

```sql
START TRANSACTION;

UPDATE accounts
SET balance = balance - 100
WHERE account_id = 1;

SAVEPOINT after_debit;

UPDATE accounts
SET balance = balance + 100
WHERE account_id = 2;

ROLLBACK TO SAVEPOINT after_debit;

COMMIT;
```

`ROLLBACK TO SAVEPOINT` does **not** end the transaction.

Mental model:

```text
START
  ↓
update A
  ↓
SAVEPOINT
  ↓
update B
  ↓
ROLLBACK TO SAVEPOINT
  ↓
update B undone
update A remains
  ↓
COMMIT
```

---

# 12. Transaction Boundary — A Very Important Design Decision

The transaction boundary determines what must succeed together.

Ask:

> If operation B fails, should operation A remain committed?

If the answer is **no**, they likely belong to the same transaction.

### Too small

```text
transaction A → commit
transaction B → commit
```

A failure between them can leave partial business state.

### Too large

```text
START
  ↓
10 million rows
  ↓
external call
  ↓
more updates
  ↓
COMMIT
```

This can cause long lock durations, contention, large rollback work, and difficult recovery.

### Goal

Keep the transaction **large enough for the required atomicity but small enough for operational safety**.

---

# 13. Isolation Levels in MySQL

MySQL/InnoDB supports these standard isolation levels:

| Isolation Level | Main idea |
|---|---|
| `READ UNCOMMITTED` | Weakest isolation; dirty reads can occur |
| `READ COMMITTED` | Reads committed data; repeated reads can see later commits |
| `REPEATABLE READ` | Consistent reads use a transaction snapshot |
| `SERIALIZABLE` | Strongest standard isolation; concurrent access becomes more restrictive |

Check the session isolation level:

```sql
SELECT @@transaction_isolation;
```

Set the session level:

```sql
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
```

> [!NOTE]
> MySQL/InnoDB's default isolation level is `REPEATABLE READ`. Do not assume another database uses the same default.

---

# 14. Dirty Read

A dirty read happens when transaction B reads data written by transaction A **before A commits**.

```text
Transaction A
UPDATE salary = 100000
(no COMMIT)

Transaction B
reads salary = 100000
```

If A later rolls back, B observed a value that was never committed.

`READ UNCOMMITTED` allows this behavior.

---

# 15. Non-Repeatable Read

Transaction A reads a row.

Transaction B changes and commits that row.

Transaction A reads again and gets a different committed value.

```text
A: SELECT balance → 1000
B: UPDATE balance → 800
B: COMMIT
A: SELECT balance → 800
```

The same transaction observed different committed values for the same row.

---

# 16. Phantom Read

A transaction performs a range query.

Another transaction inserts a row matching that range and commits.

A repeated range query may see a different set of matching rows depending on the isolation/read semantics.

Example concept:

```sql
SELECT *
FROM orders
WHERE amount >= 1000;
```

The second execution may encounter a changed matching set under weaker/concurrent conditions.

---

# 17. Consistent Read vs Locking Read

An ordinary query:

```sql
SELECT balance
FROM accounts
WHERE account_id = 1;
```

is a normal read.

A locking read:

```sql
SELECT balance
FROM accounts
WHERE account_id = 1
FOR UPDATE;
```

requests the appropriate row locks for a transaction that intends to coordinate a subsequent update.

### Typical pattern

```text
Read current state
      ↓
Lock the relevant row
      ↓
Validate business rule
      ↓
Update
      ↓
COMMIT
```

---

# 18. `SELECT ... FOR UPDATE`

Use `FOR UPDATE` when the transaction needs to read rows and then modify them based on that state, while preventing conflicting concurrent work from changing the locked rows before the transaction completes.

Example inventory reservation:

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

The application should check the affected-row count.

### Do not use it everywhere

Unnecessary locking can reduce concurrency and increase contention.

---

# 19. Safe Conditional Update

Sometimes a separate read is unnecessary.

For example:

```sql
UPDATE inventory
SET stock_quantity = stock_quantity - 1
WHERE product_id = 101
  AND stock_quantity >= 1;
```

Then:

```sql
SELECT ROW_COUNT();
```

If one row was updated, the reservation succeeded.

If zero rows were updated, the condition was not satisfied or the target row was not found.

This pattern can be simpler and safer than:

```text
SELECT
 ↓
application decision
 ↓
UPDATE
```

when the business rule can be expressed atomically in the `UPDATE` predicate.

---

# 20. Atomic Work Claiming

This is highly relevant to Data Engineering.

Suppose multiple workers process pipeline jobs:

```text
Worker A ─┐
          ├──> PENDING job
Worker B ─┘
```

You do not want both workers to claim the same job.

Use a conditional update:

```sql
START TRANSACTION;

UPDATE pipeline_runs
SET status = 'RUNNING',
    started_at = CURRENT_TIMESTAMP
WHERE run_id = 5001
  AND status = 'PENDING';

SELECT ROW_COUNT();

COMMIT;
```

If `ROW_COUNT()` is `1`, this worker successfully changed the job from `PENDING` to `RUNNING`.

If it is `0`, another worker may already have claimed it.

---

# 21. Deadlocks

A deadlock occurs when transactions form a circular dependency on locks.

Example:

```text
Transaction A                Transaction B
     |                             |
 locks Row 1                  locks Row 2
     |                             |
 waits for Row 2             waits for Row 1
     |                             |
     └──────── cycle ──────────────┘
```

Neither transaction can proceed.

InnoDB detects the deadlock and rolls back one transaction so the other can continue.

### Important interview point

A deadlock is not necessarily a database bug. It is a concurrency condition that the application should be designed to handle.

---

# 22. How to Reduce Deadlocks

### 1. Access rows in a consistent order

Bad pattern:

```text
Transaction A: Row 1 → Row 2
Transaction B: Row 2 → Row 1
```

Better:

```text
Both transactions: Row 1 → Row 2
```

### 2. Keep transactions short

Do not hold locks while doing unnecessary work.

### 3. Use appropriate indexes

Poorly indexed predicates can cause more rows to be examined/locked than expected.

### 4. Avoid external calls inside transactions

Do not hold database locks while waiting for an API response when it can be avoided.

### 5. Retry safely

A deadlock victim may need to retry the entire transaction.

---

# 23. Deadlock Retry Pattern

A production application should treat deadlock errors as potentially retryable when the operation is designed for safe retry.

Conceptually:

```text
attempt 1
   ↓
deadlock
   ↓
rollback
   ↓
short backoff
   ↓
attempt 2
   ↓
success
```

Use bounded retries and backoff rather than infinite retries.

The transaction should be retried from the beginning; do not assume partially executed statements remain valid after the deadlock rollback.

---

# 24. Lock Contention

Lock contention occurs when one transaction waits for another transaction's lock.

```text
Transaction A
holds lock
   ↓
Transaction B
waits
```

Long transactions increase the time other transactions may wait.

Common causes:

- Large transactions
- Slow queries inside transactions
- Missing/poor indexes
- Unnecessary locking reads
- External work while locks are held
- High-concurrency updates to the same rows

---

# 25. Transactions and ETL/ELT

Transactions are useful in controlled parts of a Data Engineering pipeline.

Examples:

### Control-table update

```text
load data
   ↓
update load_control
   ↓
commit together when atomicity is required
```

### Job state transition

```text
PENDING → RUNNING → SUCCESS
```

### Small batch load

```text
batch 101
   ↓
insert/update
   ↓
validate
   ↓
commit
```

For very large warehouse loads, transaction design must account for engine behavior, lock duration, rollback cost, and workload concurrency.

---

# 26. Transactions Do Not Make a Pipeline Idempotent

This is a very important Data Engineering interview concept.

Imagine:

```text
Client sends request
       ↓
DB transaction commits
       ↓
response is lost
       ↓
client retries
       ↓
operation executes again
```

The first transaction was fully ACID-compliant.

But the business operation may still happen twice.

### Idempotency may require

- Unique business keys
- Batch/run identifiers
- Upserts
- Deduplication
- Checkpoints
- Exactly-once business semantics where appropriate

Therefore:

```text
ACID ≠ Idempotency
```

---

# 27. Transaction vs Batch Size

Suppose an ETL job processes 10 million rows.

One enormous transaction can create operational problems:

- Long lock duration
- Large undo/rollback work
- Increased contention
- Longer recovery if something fails
- More difficult troubleshooting

Batching may be preferable:

```text
10M rows
   ↓
1M transaction
   ↓
commit
   ↓
1M transaction
   ↓
commit
   ↓
...
```

But do not blindly batch everything. The correct size depends on the workload and the atomicity requirement.

---

# 28. DML vs DDL

DML examples:

```sql
INSERT
UPDATE
DELETE
```

DDL examples:

```sql
CREATE TABLE
ALTER TABLE
DROP TABLE
```

Do not assume DDL behaves like ordinary transactional DML.

MySQL statements involving DDL can have implicit-commit behavior.

Therefore, do not design a workflow assuming:

```text
START TRANSACTION
  ↓
DML
  ↓
DDL
  ↓
ROLLBACK
```

will behave like one ordinary all-or-nothing DML transaction.

> [!WARNING]
> Treat schema changes separately from business-data transactions unless you have explicitly verified the exact MySQL statement behavior and deployment strategy.

---

# 29. Transaction Isolation — Choosing a Level

Do not answer interview questions by saying “SERIALIZABLE is safest, so always use it.”

The real question is:

> What concurrency behavior does the business requirement need?

### Example

If a reporting workload only needs committed data and can tolerate a row changing between two reads, `READ COMMITTED` may be a reasonable choice.

If stronger repeatable-read semantics are required, another level may be appropriate.

Higher isolation can reduce concurrency or increase locking/coordination costs.

The correct level is a workload decision.

---

# 30. Practical Transaction Design Checklist

Before writing a transaction, ask:

```text
1. What is the logical unit of work?
2. Which statements must succeed together?
3. What happens if statement 2 fails?
4. Could two workers touch the same rows?
5. Do I need a locking read?
6. Could this transaction become long-running?
7. What happens if a deadlock occurs?
8. Can the operation be retried safely?
9. Is the operation idempotent?
10. Am I mixing DDL with transactional DML?
11. Are the critical predicates indexed appropriately?
12. What isolation level does the workload require?
```

These questions are more valuable than memorizing transaction syntax.

---

# ⚡ Performance and Production Considerations

Transactions affect more than correctness.

### Keep transactions short

Shorter transactions generally reduce lock duration and contention.

### Index critical predicates

An update such as:

```sql
UPDATE pipeline_runs
SET status = 'RUNNING'
WHERE run_id = 5001
  AND status = 'PENDING';
```

should have an efficient access path for the workload.

### Avoid external work inside transactions

Prefer:

```text
prepare external work
      ↓
short DB transaction
      ↓
commit
```

rather than holding locks during network calls.

### Monitor

Production troubleshooting should consider:

- Deadlocks
- Lock waits
- Long-running transactions
- Transaction throughput
- Rollback events
- Batch duration

---

# ⚠️ Common Mistakes

1. Thinking `COMMIT` is optional after an explicit transaction.
2. Assuming `ROLLBACK` can undo every MySQL statement.
3. Treating ACID and idempotency as the same concept.
4. Keeping transactions open while calling external services.
5. Using `FOR UPDATE` for ordinary read-only queries.
6. Ignoring affected-row counts in conditional state transitions.
7. Locking rows in inconsistent order.
8. Creating unnecessarily large transactions.
9. Choosing an isolation level without understanding the workload.
10. Assuming a deadlock means the database is broken.
11. Retrying only the failed statement instead of safely retrying the transaction.
12. Mixing DDL into a transaction without understanding implicit-commit behavior.
13. Forgetting that transaction behavior depends on the storage engine and statement type.

---

# 🎤 Interview-Focused Questions

> [!QUESTION]
>
> ## Interview Follow-Up Questions

### Q1. What is a transaction?

<details>
<summary><strong>Answer</strong></summary>

A transaction is a logical unit of database work whose related changes are committed or rolled back according to the transaction outcome.
</details>

### Q2. Explain ACID using a bank transfer.

<details>
<summary><strong>Answer</strong></summary>

Atomicity means the debit and credit succeed together. Consistency means database rules remain valid. Isolation controls how concurrent transfers interact. Durability means a committed transfer remains committed according to the database's durability guarantees.
</details>

### Q3. What is the difference between COMMIT and ROLLBACK?

<details>
<summary><strong>Answer</strong></summary>

`COMMIT` makes the transaction's changes committed. `ROLLBACK` undoes uncommitted changes in the current transaction.
</details>

### Q4. What is SAVEPOINT?

<details>
<summary><strong>Answer</strong></summary>

A savepoint creates a rollback point inside a transaction. `ROLLBACK TO SAVEPOINT` undoes changes after that point without ending the entire transaction.
</details>

### Q5. What is autocommit?

<details>
<summary><strong>Answer</strong></summary>

When autocommit is enabled, successful individual statements are normally committed automatically. Explicit transactions are required when several statements must behave as one atomic unit.
</details>

### Q6. What are the four MySQL isolation levels?

<details>
<summary><strong>Answer</strong></summary>

`READ UNCOMMITTED`, `READ COMMITTED`, `REPEATABLE READ`, and `SERIALIZABLE`.
</details>

### Q7. What is a dirty read?

<details>
<summary><strong>Answer</strong></summary>

Reading another transaction's uncommitted changes.
</details>

### Q8. What is a non-repeatable read?

<details>
<summary><strong>Answer</strong></summary>

A transaction reads the same row twice and observes different committed values because another transaction changed and committed the row between the reads.
</details>

### Q9. What is a phantom read?

<details>
<summary><strong>Answer</strong></summary>

A repeated range query can observe a changed set of matching rows because concurrent transactions inserted, deleted, or otherwise changed rows that satisfy the range.
</details>

### Q10. Why use SELECT FOR UPDATE?

<details>
<summary><strong>Answer</strong></summary>

Use it when a transaction reads rows and then needs to modify them based on that state while coordinating concurrent transactions.
</details>

### Q11. How would you prevent two workers from claiming the same pipeline job?

<details>
<summary><strong>Answer</strong></summary>

Use an atomic conditional update such as `WHERE status = 'PENDING'`, then verify the affected-row count. Only the worker that successfully changes the row should proceed.
</details>

### Q12. What is a deadlock?

<details>
<summary><strong>Answer</strong></summary>

A deadlock occurs when transactions wait on locks held by each other, creating a cycle. InnoDB detects the cycle and rolls back one transaction.
</details>

### Q13. How do you reduce deadlocks?

<details>
<summary><strong>Answer</strong></summary>

Keep transactions short, acquire shared resources in a consistent order, use appropriate indexes, avoid unnecessary locks, and safely retry deadlocked transactions.
</details>

### Q14. Should you retry a deadlocked statement or the whole transaction?

<details>
<summary><strong>Answer</strong></summary>

Normally retry the transaction as a whole because the deadlock caused one transaction to be rolled back. The application should restart the logical unit of work safely.
</details>

### Q15. Why is a long API call inside a transaction dangerous?

<details>
<summary><strong>Answer</strong></summary>

The database transaction may hold locks while waiting for the network call. This increases lock duration and can cause other transactions to wait unnecessarily.
</details>

### Q16. Does ACID make an ETL pipeline idempotent?

<details>
<summary><strong>Answer</strong></summary>

No. A transaction can commit successfully and the client can still retry after losing the response. Idempotency requires additional design such as unique keys, batch identifiers, upserts, or deduplication.
</details>

### Q17. Why can a 10-million-row transaction be problematic?

<details>
<summary><strong>Answer</strong></summary>

It can increase lock duration, undo/rollback cost, contention, recovery time, and operational risk. Appropriate batching can reduce those effects when the business requirement permits it.
</details>

### Q18. Why shouldn't you assume DDL can be rolled back like DML?

<details>
<summary><strong>Answer</strong></summary>

MySQL DDL statements can have implicit-commit behavior. Their transaction semantics are therefore not the same as ordinary transactional DML.
</details>

### Q19. When would you use a conditional UPDATE instead of SELECT FOR UPDATE?

<details>
<summary><strong>Answer</strong></summary>

If the business rule can be expressed atomically in the `UPDATE` predicate, a conditional update can avoid a separate read. For example, decrement inventory only when `stock_quantity >= 1` and check `ROW_COUNT()`.
</details>

### Q20. What determines the correct isolation level?

<details>
<summary><strong>Answer</strong></summary>

The required consistency/concurrency behavior of the workload. Higher isolation is not automatically better because stronger guarantees can reduce concurrency or increase contention.
</details>

---

# 🔄 Quick Revision

| Concept | Remember |
|---|---|
| Transaction | Logical unit of work |
| Atomicity | Related changes succeed/fail together |
| Consistency | Valid database state/rules preserved |
| Isolation | Controls concurrent visibility/behavior |
| Durability | Committed changes persist according to guarantees |
| `START TRANSACTION` | Begins explicit transaction |
| `COMMIT` | Commits changes |
| `ROLLBACK` | Undoes uncommitted changes |
| `SAVEPOINT` | Partial rollback point |
| Autocommit | Individual statements normally commit automatically |
| `READ UNCOMMITTED` | Weakest isolation |
| `READ COMMITTED` | Reads committed data |
| `REPEATABLE READ` | Consistent reads use a snapshot |
| `SERIALIZABLE` | Strongest standard isolation |
| `FOR UPDATE` | Locking read for coordinated updates |
| Deadlock | Circular lock dependency |
| Conditional UPDATE | Atomic state transition pattern |
| Idempotency | Separate from ACID |
| DDL | May have implicit-commit behavior |

---

# 🧠 Final Mental Model

When you see a transaction problem in an interview, think in this order:

```text
1. What is the business unit of work?
            ↓
2. Which changes must succeed together?
            ↓
3. Can concurrent workers touch the same rows?
            ↓
4. Do I need locking or an atomic conditional UPDATE?
            ↓
5. What isolation behavior is required?
            ↓
6. How long will the transaction remain open?
            ↓
7. What happens if there is a deadlock?
            ↓
8. Can the operation be safely retried?
            ↓
9. Is the operation idempotent?
            ↓
10. Are there DDL/implicit-commit concerns?
```

That decision process is more valuable than memorizing transaction syntax.

---

# 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — executable transaction, savepoint, locking, isolation, and pipeline examples
- [`practice.sql`](./practice.sql) — transaction and Data Engineering interview exercises without solutions
