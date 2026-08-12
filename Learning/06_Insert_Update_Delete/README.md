# 06 — INSERT, UPDATE and DELETE

## 📌 Overview

`INSERT`, `UPDATE`, and `DELETE` are the core SQL statements used to modify data stored in MySQL tables.

For a Data Engineer, these statements are important beyond basic CRUD. They appear in staging loads, incremental pipelines, CDC processing, data correction, archival, reconciliation, and idempotent ingestion workflows.

The most important principle in this topic is **controlled data modification**: know exactly which rows will change before modifying them.

---

## 🎯 Learning Objectives

By the end of this topic, you should be able to:

- Insert single and multiple rows.
- Use explicit column lists safely.
- Use `DEFAULT` and `NULL` during inserts.
- Load data with `INSERT ... SELECT`.
- Update one or many rows safely.
- Use expressions and `CASE` in `UPDATE` statements.
- Delete selected rows safely.
- Distinguish `DELETE`, `TRUNCATE`, and `DROP`.
- Understand transactions and rollback.
- Use MySQL upsert patterns.
- Design safer ETL/ELT data modifications.
- Think about idempotency, batching, and failure recovery.

---

## 🧠 1. What Is DML?

`INSERT`, `UPDATE`, and `DELETE` are Data Manipulation Language operations because they change the rows stored in a table.

```text
INSERT → create rows
UPDATE → change rows
DELETE → remove rows
```

Example table:

```text
customers
+-------------+---------------+---------+
| customer_id | customer_name | city    |
+-------------+---------------+---------+
| 1           | Asha          | Mumbai  |
| 2           | Rahul         | Pune    |
+-------------+---------------+---------+
```

DML changes the data while the table structure remains in place.

---

## ➕ 2. INSERT — Add a Single Row

`INSERT` adds a new row.

```sql
INSERT INTO customers (
    customer_id,
    customer_name,
    city
)
VALUES (
    3,
    'Meera',
    'Delhi'
);
```

After the statement, the table contains the new customer.

### Best practice

Prefer an explicit column list:

```sql
INSERT INTO customers (customer_id, customer_name, city)
VALUES (3, 'Meera', 'Delhi');
```

rather than relying on physical column order.

---

## ➕ 3. INSERT Multiple Rows

Multiple rows can be inserted in one statement.

```sql
INSERT INTO customers (
    customer_id,
    customer_name,
    city
)
VALUES
    (4, 'Vikram', 'Mumbai'),
    (5, 'Neha', 'Nashik'),
    (6, 'Arjun', 'Pune');
```

This is generally more convenient than sending one separate insert statement for every row.

---

## 🛡️ 4. Why Explicit Column Lists Matter

Suppose the table is:

```sql
CREATE TABLE employees (
    employee_id INT,
    employee_name VARCHAR(100),
    department VARCHAR(50),
    salary DECIMAL(12,2)
);
```

Safer:

```sql
INSERT INTO employees (
    employee_id,
    employee_name,
    salary
)
VALUES (101, 'Asha', 90000);
```

This remains readable even when the table contains additional columns with defaults or nullable values.

Avoid depending on:

```sql
INSERT INTO employees
VALUES (...);
```

because a schema change can make the statement incorrect.

---

## 🎯 5. INSERT with DEFAULT

Suppose:

```sql
CREATE TABLE jobs (
    job_id INT PRIMARY KEY,
    status VARCHAR(20) DEFAULT 'PENDING',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

You can omit defaulted columns:

```sql
INSERT INTO jobs (job_id)
VALUES (1);
```

MySQL can populate the default values.

You can also explicitly request a default:

```sql
INSERT INTO jobs (job_id, status)
VALUES (2, DEFAULT);
```

---

## NULL 6. INSERT and NULL

`NULL` means the value is missing or unknown.

It is different from:

```text
NULL       → missing / unknown
0          → numeric zero
''         → empty string
'NULL'     → text containing four characters
```

Example:

```sql
INSERT INTO customers (
    customer_id,
    customer_name,
    phone
)
VALUES (
    7,
    'Isha',
    NULL
);
```

If `phone` is nullable, this is valid.

If `phone` is defined as `NOT NULL`, the insert cannot store `NULL` there.

---

## 🔄 7. INSERT ... SELECT

`INSERT ... SELECT` inserts rows produced by a query.

```sql
INSERT INTO archived_orders (
    order_id,
    customer_id,
    order_date
)
SELECT
    order_id,
    customer_id,
    order_date
FROM orders
WHERE order_date < '2025-01-01';
```

This is one of the most useful patterns for Data Engineering because the data can move directly inside the database.

### Common uses

- Staging → target
- Archival
- Derived tables
- Historical snapshots
- Data migration
- Controlled transformations

---

## ✏️ 8. UPDATE — Modify Existing Rows

`UPDATE` changes existing rows.

```sql
UPDATE customers
SET city = 'Mumbai'
WHERE customer_id = 1;
```

Only customer `1` is targeted.

### Multiple columns

```sql
UPDATE customers
SET city = 'Pune',
    status = 'ACTIVE'
WHERE customer_id = 2;
```

---

## 🚨 9. The Most Important UPDATE Rule

Never blindly execute:

```sql
UPDATE customers
SET city = 'Mumbai';
```

This updates **every row**.

Instead, preview the target:

```sql
SELECT *
FROM customers
WHERE city = 'Pune';
```

Then update:

```sql
UPDATE customers
SET city = 'Mumbai'
WHERE city = 'Pune';
```

### Safe modification habit

```text
SELECT target rows
       ↓
Verify count / data
       ↓
UPDATE
       ↓
Check affected rows
       ↓
Validate result
```

---

## 🧮 10. UPDATE Using Expressions

The new value can depend on the old value.

```sql
UPDATE products
SET price = price * 1.10
WHERE category = 'Electronics';
```

This increases the price by 10%.

Another example:

```sql
UPDATE accounts
SET balance = balance - 500
WHERE account_id = 101;
```

The calculation happens from the existing value.

---

## 🧠 11. UPDATE Using CASE

Business rules can be implemented with `CASE`.

```sql
UPDATE employees
SET salary = CASE
    WHEN department = 'Engineering' THEN salary * 1.10
    WHEN department = 'Sales' THEN salary * 1.05
    ELSE salary
END;
```

This allows different rows to receive different transformations in one statement.

This pattern is common in ETL transformations and data correction jobs.

---

## NULL 12. UPDATE and NULL

To find NULL values, use `IS NULL`.

Correct:

```sql
UPDATE customers
SET phone = '9999999999'
WHERE phone IS NULL;
```

Incorrect:

```sql
WHERE phone = NULL
```

`NULL` requires three-valued SQL logic and cannot be tested with ordinary equality.

---

## 🗑️ 13. DELETE — Remove Rows

`DELETE` removes rows from a table.

```sql
DELETE FROM customers
WHERE customer_id = 7;
```

The table remains; only the matching row is removed.

### Delete multiple rows

```sql
DELETE FROM orders
WHERE status = 'CANCELLED';
```

---

## 🚨 14. DELETE Without WHERE

This statement:

```sql
DELETE FROM customers;
```

removes every row from the table.

The table definition remains.

For production work, always verify the intended target before executing destructive DML.

---

## ⚖️ 15. DELETE vs TRUNCATE vs DROP

| Statement | Removes rows | Removes table definition | Conditional? | Typical purpose |
|---|---:|---:|---:|---|
| `DELETE` | Yes | No | Yes | Remove selected rows |
| `TRUNCATE` | All | No | No | Empty a table |
| `DROP TABLE` | All | Yes | No | Remove table completely |

These commands have different transactional, logging, locking, and metadata behavior. Do not treat them as interchangeable.

---

## 🧹 16. TRUNCATE

```sql
TRUNCATE TABLE staging_orders;
```

This removes all rows while keeping the table.

A common Data Engineering use case is clearing a staging table before a full reload.

```text
Previous staging data
        ↓
TRUNCATE
        ↓
Fresh load
```

Use caution: it is not a conditional row-level operation.

---

## 💣 17. DROP TABLE

```sql
DROP TABLE staging_orders;
```

This removes both:

- The table definition
- The stored data

It is a DDL operation and should be treated as a schema/destructive change rather than ordinary row-level DML.

---

## 🔐 18. Transactions

Transactions group related changes into one logical unit.

Example: transferring money.

```sql
START TRANSACTION;

UPDATE accounts
SET balance = balance - 500
WHERE account_id = 1;

UPDATE accounts
SET balance = balance + 500
WHERE account_id = 2;

COMMIT;
```

Both changes are intended to become permanent together.

If validation fails:

```sql
ROLLBACK;
```

---

## ↩️ 19. COMMIT vs ROLLBACK

### COMMIT

Makes the transaction changes permanent.

```sql
COMMIT;
```

### ROLLBACK

Reverses uncommitted transaction changes when supported by the transaction/storage context.

```sql
ROLLBACK;
```

Think of a transaction as:

```text
START TRANSACTION
       ↓
   changes
       ↓
validation
   ↙       ↘
ROLLBACK   COMMIT
```

---

## 🔁 20. Savepoints

For more controlled transactions, savepoints allow partial rollback.

```sql
START TRANSACTION;

UPDATE products
SET price = price * 1.05;

SAVEPOINT price_update;

UPDATE products
SET stock = stock - 10;

ROLLBACK TO SAVEPOINT price_update;

COMMIT;
```

The second change can be rolled back while preserving the earlier transaction work.

---

## 🔄 21. Upsert — INSERT or UPDATE

An upsert means:

```text
If row exists → update
If row does not exist → insert
```

MySQL supports this with `INSERT ... ON DUPLICATE KEY UPDATE`.

Example:

```sql
INSERT INTO customers (
    customer_id,
    customer_name,
    city
)
VALUES (1, 'Asha', 'Pune')
ON DUPLICATE KEY UPDATE
    customer_name = 'Asha',
    city = 'Pune';
```

The duplicate condition is determined by an applicable unique or primary key.

### Data Engineering use case

This is useful for incremental loads where the source contains both new and changed records.

---

## ⚠️ 22. INSERT IGNORE

MySQL also supports:

```sql
INSERT IGNORE INTO customers (customer_id, customer_name)
VALUES (1, 'Asha');
```

Depending on the error/warning, MySQL can suppress certain problems rather than failing normally.

### Why should Data Engineers be careful?

Using `INSERT IGNORE` everywhere can hide data-quality issues.

A failed record may need to be:

```text
Rejected
    ↓
Logged
    ↓
Investigated
    ↓
Corrected / Reprocessed
```

rather than silently discarded.

---

## 🧪 23. Safe Data Modification Workflow

A robust workflow is:

### Step 1 — Identify

```sql
SELECT *
FROM customers
WHERE city = 'Pune';
```

### Step 2 — Count

```sql
SELECT COUNT(*)
FROM customers
WHERE city = 'Pune';
```

### Step 3 — Modify

```sql
UPDATE customers
SET city = 'Mumbai'
WHERE city = 'Pune';
```

### Step 4 — Check affected rows

```sql
SELECT ROW_COUNT();
```

### Step 5 — Validate

```sql
SELECT *
FROM customers
WHERE city = 'Mumbai';
```

For important production changes, wrap related modifications in a transaction when appropriate.

---

## 🏗️ 24. Data Engineering Use Cases

### Incremental load

```text
Source changes
      ↓
Staging
      ↓
Identify inserts / updates
      ↓
Upsert target
```

### Archival

```sql
INSERT INTO archived_orders
SELECT *
FROM orders
WHERE order_date < '2024-01-01';
```

Then, after validation, old rows may be deleted according to the retention policy.

### Data correction

```sql
UPDATE customers
SET city = TRIM(city);
```

### Staging refresh

```sql
TRUNCATE TABLE staging_orders;
```

### CDC processing

Incoming events can represent:

```text
INSERT → create target record
UPDATE → modify target record
DELETE → remove / expire target record
```

---

## 🔄 25. Idempotency

An idempotent pipeline can be rerun without creating incorrect duplicate effects.

Suppose an order with:

```text
order_id = 1001
```

is received twice.

A naive insert may create a duplicate.

A better design uses a stable key and deterministic upsert/deduplication logic.

```text
Same input
   ↓
Run 1 → expected state
Run 2 → same expected state
```

Idempotency is an important Data Engineering interview concept.

---

## 📦 26. Batching Large Updates and Deletes

Updating millions of rows in one transaction can create operational problems such as:

- Long locks
- Large transaction logs/undo requirements
- Replication pressure
- Long-running transactions
- Difficult recovery

Depending on the workload, batch processing can be safer:

```text
1,000,000 rows
      ↓
Batch 1
Batch 2
Batch 3
...
Batch N
```

The exact batch strategy should be based on table size, indexes, workload, transaction behavior, and operational requirements.

---

## ⚡ 27. Performance Considerations

### Index the target condition when appropriate

If you frequently run:

```sql
UPDATE customers
SET status = 'ACTIVE'
WHERE customer_id = 1001;
```

an index on `customer_id` can help locate the target row efficiently.

### Be careful with huge updates

Large modifications can generate substantial I/O and affect concurrent workloads.

### Check the target before changing it

The cost of an accidental full-table update is not only performance—it is data correctness.

### Avoid unnecessary writes

Do not update a column to the value it already contains when a condition can avoid unnecessary modifications.

---

## ⚠️ 28. Common Mistakes

- Forgetting `WHERE` in `UPDATE`.
- Forgetting `WHERE` in `DELETE`.
- Using the wrong column order during `INSERT`.
- Using `phone = NULL` instead of `phone IS NULL`.
- Confusing `DELETE`, `TRUNCATE`, and `DROP`.
- Assuming every change can be rolled back after commit.
- Using `INSERT IGNORE` to hide data-quality failures.
- Running huge modifications without considering transaction size.
- Not validating affected-row counts.
- Creating non-idempotent incremental loads.

---

## 🎤 29. Interview-Focused Questions

### Q1. What is the difference between INSERT, UPDATE, and DELETE?

<details>
<summary><strong>Answer</strong></summary>

`INSERT` adds new rows, `UPDATE` changes existing rows, and `DELETE` removes rows. All three modify table data and should be executed with clear target conditions.

</details>

---

### Q2. What happens if UPDATE is executed without a WHERE clause?

<details>
<summary><strong>Answer</strong></summary>

The statement updates every row in the table. This is a dangerous mistake because a missing condition can overwrite a large amount of production data.

</details>

---

### Q3. What happens if DELETE is executed without WHERE?

<details>
<summary><strong>Answer</strong></summary>

Every row is deleted while the table definition remains. If the operation occurs inside an appropriate transaction and has not been committed, rollback may be possible.

</details>

---

### Q4. What is the difference between DELETE and TRUNCATE?

<details>
<summary><strong>Answer</strong></summary>

`DELETE` is a row-level DML operation and can use `WHERE`. `TRUNCATE` removes all rows and is intended to empty a table efficiently. Their transaction, locking, logging, and metadata behavior differ, so the choice should be deliberate.

</details>

---

### Q5. What is the difference between DELETE and DROP?

<details>
<summary><strong>Answer</strong></summary>

`DELETE` removes rows but keeps the table structure. `DROP TABLE` removes the table itself, including its definition and data.

</details>

---

### Q6. How would you safely update one million rows?

<details>
<summary><strong>Answer</strong></summary>

First identify and validate the target set, inspect the execution plan and relevant indexes, estimate the affected rows, consider batching and transaction size, evaluate locking and replication impact, test the operation, and monitor it in production. A single huge update is not automatically the best strategy.

</details>

---

### Q7. What is INSERT ... SELECT used for in Data Engineering?

<details>
<summary><strong>Answer</strong></summary>

It moves query results directly into another table and is useful for staging-to-target loads, archival, transformations, snapshots, and migrations without transferring the data through an external application.

</details>

---

### Q8. How do you insert a row only if it does not already exist?

<details>
<summary><strong>Answer</strong></summary>

One MySQL approach is an insert using a unique or primary key together with an appropriate duplicate-handling strategy. `INSERT ... ON DUPLICATE KEY UPDATE` is used when existing rows should be updated; a separate duplicate-safe insert strategy can be used when existing rows should remain unchanged.

</details>

---

### Q9. What is an upsert?

<details>
<summary><strong>Answer</strong></summary>

An upsert combines insert and update behavior: if the identifying key does not exist, insert the row; if it already exists, update the existing row. It is common in incremental ingestion pipelines.

</details>

---

### Q10. How would you design an idempotent incremental load?

<details>
<summary><strong>Answer</strong></summary>

Use a stable business or technical key, stage and validate incoming records, deterministically identify inserts and updates, apply upsert/deduplication logic, record processing state where required, and ensure rerunning the same input produces the intended same target state rather than duplicate effects.

</details>

---

### Q11. Why can INSERT IGNORE be dangerous in a pipeline?

<details>
<summary><strong>Answer</strong></summary>

It can suppress certain errors or warnings. If used indiscriminately, invalid or duplicate records may be skipped without receiving the investigation, logging, and remediation they require. Production pipelines should make data-quality failures observable.

</details>

---

### Q12. When should you use a transaction for UPDATE/DELETE operations?

<details>
<summary><strong>Answer</strong></summary>

Use a transaction when multiple related changes should succeed or fail together, or when you need a controlled validation point before committing. Transaction size and duration should still be appropriate for the workload.

</details>

---

### Q13. How can you safely delete records older than a retention period?

<details>
<summary><strong>Answer</strong></summary>

First preview and count the target rows, verify the retention rule, ensure appropriate indexing, consider batching for large tables, execute within an operationally safe transaction strategy, and validate the final row counts. For archival requirements, copy and validate the records before deletion.

</details>

---

### Q14. What would you do if an UPDATE accidentally modified too many rows?

<details>
<summary><strong>Answer</strong></summary>

If the transaction is still uncommitted, stop and `ROLLBACK`. If it has already been committed, recovery depends on backups, binary logs, replication, audit history, or another recovery mechanism. This is why target validation and transaction planning are critical before destructive changes.

</details>

---

## 🔄 30. Quick Revision

| Concept | Key Point |
|---|---|
| `INSERT` | Adds rows |
| Multi-row `INSERT` | Adds several rows in one statement |
| `INSERT ... SELECT` | Inserts query results into another table |
| `UPDATE` | Changes existing rows |
| `DELETE` | Removes selected rows |
| `TRUNCATE` | Removes all rows while retaining table structure |
| `DROP` | Removes the table definition and data |
| `DEFAULT` | Supplies an omitted value |
| `IS NULL` | Tests SQL `NULL` |
| `COMMIT` | Makes transaction changes permanent |
| `ROLLBACK` | Reverses uncommitted changes |
| `SAVEPOINT` | Creates a partial rollback point |
| Upsert | Insert or update based on a key |
| Idempotency | Repeated processing produces the intended same state |

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — worked examples for INSERT, UPDATE, DELETE, transactions, and upserts
- [`practice.sql`](./practice.sql) — hands-on exercises, safe-modification practice, and interview scenarios
