# 06 — INSERT, UPDATE and DELETE

## 📌 Overview

`INSERT`, `UPDATE`, and `DELETE` are the core SQL statements used to modify data stored in MySQL tables.

This topic covers data modification from basic syntax through transactions, safe updates, conditional changes, multi-row operations, and Data Engineering scenarios.

## 🎯 Learning Objectives

By the end of this topic, you should be able to:

- Insert single and multiple rows
- Insert data using `INSERT ... SELECT`
- Update one or many rows safely
- Delete rows using conditions
- Understand `NULL` during data modification
- Use `DEFAULT` and `ON DUPLICATE KEY UPDATE`
- Distinguish `DELETE`, `TRUNCATE`, and `DROP`
- Validate changes before executing destructive statements
- Use transactions with `COMMIT` and `ROLLBACK`
- Handle common ETL/ELT data-modification scenarios

---

## 1. INSERT

`INSERT` adds new rows to a table.

```sql
INSERT INTO customers (customer_id, customer_name, city)
VALUES (1, 'Amit', 'Mumbai');
```

### Multiple Rows

```sql
INSERT INTO customers (customer_id, customer_name, city)
VALUES
    (2, 'Priya', 'Pune'),
    (3, 'Rahul', 'Nashik');
```

Always prefer an explicit column list. It makes the statement safer and easier to maintain.

---

## 2. INSERT Using DEFAULT Values

If a column has a default value, it can be omitted from the `INSERT`.

```sql
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    status VARCHAR(20) DEFAULT 'pending'
);

INSERT INTO orders (order_id)
VALUES (101);
```

The new row receives `pending` for `status`.

You can also explicitly request the default:

```sql
INSERT INTO orders (order_id, status)
VALUES (102, DEFAULT);
```

---

## 3. INSERT and NULL

`NULL` represents missing or unknown data. It is different from `0`, an empty string, or the text `'NULL'`.

```sql
INSERT INTO customers (customer_id, customer_name, phone)
VALUES (4, 'Neha', NULL);
```

A `NOT NULL` column cannot receive `NULL`.

---

## 4. INSERT ... SELECT

`INSERT ... SELECT` copies query results into another table.

```sql
INSERT INTO archived_orders (order_id, customer_id, order_date)
SELECT order_id, customer_id, order_date
FROM orders
WHERE order_date < '2025-01-01';
```

This pattern is common in ETL, staging, archival, and transformation workflows.

---

## 5. UPDATE

`UPDATE` changes existing rows.

```sql
UPDATE customers
SET city = 'Mumbai'
WHERE customer_id = 1;
```

### Updating Multiple Columns

```sql
UPDATE customers
SET city = 'Pune',
    status = 'active'
WHERE customer_id = 2;
```

> [!WARNING]
> Always inspect the `WHERE` condition before running an `UPDATE`. Without a `WHERE` clause, every row can be modified.

---

## 6. Conditional UPDATE

Business rules can be applied with expressions.

```sql
UPDATE products
SET price = price * 1.10
WHERE category = 'Electronics';
```

You can also use `CASE`:

```sql
UPDATE employees
SET salary = CASE
    WHEN department_id = 10 THEN salary * 1.10
    WHEN department_id = 20 THEN salary * 1.05
    ELSE salary
END;
```

---

## 7. UPDATE with NULL

Use `IS NULL` to find rows containing `NULL`.

```sql
UPDATE customers
SET phone = '9999999999'
WHERE phone IS NULL;
```

Do not use `phone = NULL`; comparisons with `NULL` require `IS NULL` or `IS NOT NULL`.

---

## 8. DELETE

`DELETE` removes rows from a table.

```sql
DELETE FROM customers
WHERE customer_id = 4;
```

Multiple rows can be deleted:

```sql
DELETE FROM orders
WHERE status = 'cancelled';
```

> [!WARNING]
> A `DELETE` without `WHERE` removes all rows from the table.

---

## 9. DELETE vs TRUNCATE vs DROP

| Statement | What it removes | Table remains? | Typical use |
|---|---|---|---|
| `DELETE` | Selected rows or all rows | Yes | Conditional row deletion |
| `TRUNCATE` | All rows | Yes | Quickly empty a table |
| `DROP TABLE` | Table and its definition | No | Remove the table itself |

`TRUNCATE` and `DROP` are structural/destructive operations and should be used carefully in production.

---

## 10. Safe Data Modification Workflow

For important changes, use this workflow:

```sql
SELECT *
FROM customers
WHERE city = 'Mumbai';

UPDATE customers
SET status = 'active'
WHERE city = 'Mumbai';

SELECT ROW_COUNT();
```

The idea is simple:

1. Identify the target rows with `SELECT`.
2. Verify the result.
3. Run the modification.
4. Check the affected-row count.
5. Validate the final state.

---

## 11. Transactions

Transactions allow related changes to be treated as one unit of work.

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

If something goes wrong before committing:

```sql
ROLLBACK;
```

Transactions are important when multiple modifications must succeed or fail together.

---

## 12. COMMIT vs ROLLBACK

- `COMMIT` makes the transaction changes permanent.
- `ROLLBACK` reverses uncommitted changes.

```sql
START TRANSACTION;

UPDATE products
SET price = price * 1.05;

ROLLBACK;
```

After the rollback, the price changes are undone, subject to the storage engine and transaction behavior involved.

---

## 13. ON DUPLICATE KEY UPDATE

MySQL supports an upsert-style pattern with `INSERT ... ON DUPLICATE KEY UPDATE`.

```sql
INSERT INTO customers (customer_id, customer_name, city)
VALUES (1, 'Amit', 'Pune')
ON DUPLICATE KEY UPDATE
    customer_name = VALUES(customer_name),
    city = VALUES(city);
```

This is useful when a load should insert new records and update existing records based on a duplicate key.

For modern MySQL, use the current row-alias syntax where appropriate rather than assuming older `VALUES()` behavior in new code.

---

## 14. INSERT IGNORE

`INSERT IGNORE` can suppress certain errors and warnings and skip problematic rows depending on the constraint/error involved.

```sql
INSERT IGNORE INTO customers (customer_id, customer_name)
VALUES (1, 'Amit');
```

Use this deliberately. Silently ignoring data-quality problems can hide issues in ETL pipelines.

---

## 15. Data Engineering Perspective

Data modification statements appear in many pipeline patterns:

- Loading staging tables with `INSERT`
- Updating dimensions or status records
- Deleting invalid or expired records
- Archiving old data
- Incremental loads using upsert logic
- Applying CDC events
- Reconciling source and target tables
- Building idempotent ingestion workflows

A production pipeline should consider **idempotency, duplicate handling, transaction boundaries, auditability, and failure recovery**.

---

## 16. Common Mistakes

- Forgetting the `WHERE` clause in `UPDATE`
- Forgetting the `WHERE` clause in `DELETE`
- Inserting values in the wrong column order
- Treating `NULL` as `0` or an empty string
- Using `= NULL` instead of `IS NULL`
- Updating data before previewing affected rows
- Using `INSERT IGNORE` to hide data-quality problems
- Running large destructive changes without a transaction or recovery plan
- Confusing `DELETE`, `TRUNCATE`, and `DROP`
- Assuming every update is automatically reversible

---

## 17. Interview-Focused Questions

### Q1. What is the difference between INSERT, UPDATE, and DELETE?

<details>
<summary><strong>Answer</strong></summary>

`INSERT` adds new rows, `UPDATE` modifies existing rows, and `DELETE` removes existing rows. All three are data manipulation operations and should be used with carefully defined target conditions.

</details>

---

### Q2. What happens if you run UPDATE without a WHERE clause?

<details>
<summary><strong>Answer</strong></summary>

The `UPDATE` applies to every row in the table. This is one of the most common and dangerous SQL mistakes because it can overwrite a large amount of data.

</details>

---

### Q3. What happens if DELETE is executed without WHERE?

<details>
<summary><strong>Answer</strong></summary>

All rows are deleted from the table, while the table definition remains. A transaction may allow the operation to be rolled back when the statement is executed in a transactional context and has not been committed.

</details>

---

### Q4. What is the difference between DELETE and TRUNCATE?

<details>
<summary><strong>Answer</strong></summary>

`DELETE` removes rows and can use a `WHERE` condition. `TRUNCATE` removes all rows from a table and is intended for quickly emptying the table. Their transactional, locking, logging, and auto-increment behavior differ, so the choice matters in production.

</details>

---

### Q5. How would you safely update 1 million rows in production?

<details>
<summary><strong>Answer</strong></summary>

First identify and validate the target rows, review the execution plan and indexes, estimate the affected row count, consider batching, transaction size, locking, replication impact, and rollback/recovery strategy, then monitor the operation. Avoid blindly running one huge update.

</details>

---

### Q6. How do you insert new records and update existing records in MySQL?

<details>
<summary><strong>Answer</strong></summary>

Use an upsert pattern such as `INSERT ... ON DUPLICATE KEY UPDATE`, with a suitable primary or unique key defining when a record already exists.

</details>

---

### Q7. Why is INSERT ... SELECT useful in Data Engineering?

<details>
<summary><strong>Answer</strong></summary>

It allows rows produced by a query to be inserted into another table. This is useful for staging-to-target loads, archival, transformations, and controlled data movement without exporting the data through an external application.

</details>

---

### Q8. How should you handle NULL when updating a column?

<details>
<summary><strong>Answer</strong></summary>

Use `IS NULL` or `IS NOT NULL` in the condition. For example, `UPDATE customers SET status = 'active' WHERE status IS NULL`. `status = NULL` does not correctly test for SQL `NULL`.

</details>

---

### Q9. When would you use ROLLBACK instead of COMMIT?

<details>
<summary><strong>Answer</strong></summary>

Use `ROLLBACK` when a transaction should be discarded because validation failed, an error occurred, or the business operation cannot be completed consistently. Use `COMMIT` after all required changes have been validated and should become permanent.

</details>

---

### Q10. How would you design an idempotent incremental load?

<details>
<summary><strong>Answer</strong></summary>

Define a stable business or technical key, identify inserts versus existing records deterministically, use upsert or staging-and-merge logic, record processing state where needed, and ensure rerunning the same input does not create duplicates or incorrect repeated changes.

</details>

---

## 18. Quick Revision

| Concept | Key Point |
|---|---|
| `INSERT` | Adds rows |
| `UPDATE` | Modifies existing rows |
| `DELETE` | Removes rows |
| `INSERT ... SELECT` | Inserts query results into a table |
| `DEFAULT` | Supplies omitted column values |
| `IS NULL` | Tests for SQL `NULL` |
| `TRUNCATE` | Removes all rows while keeping the table |
| `DROP` | Removes the table definition and data |
| `COMMIT` | Makes transaction changes permanent |
| `ROLLBACK` | Reverses uncommitted transaction changes |
| Upsert | Insert new rows and update existing rows |
| Idempotency | Repeated processing produces the intended same state |

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — worked examples for INSERT, UPDATE, DELETE, and transactions
- [`practice.sql`](./practice.sql) — hands-on exercises and interview practice
