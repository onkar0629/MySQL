# 16 — Joins

## 📌 Overview

Joins combine rows from two or more tables using related columns. Joins are fundamental to SQL and are especially important in Data Engineering, where normalized source tables are commonly combined to build analytical datasets.

## 🎯 Learning Objectives

- Understand why joins are required.
- Use INNER, LEFT, RIGHT, and CROSS JOIN.
- Understand join conditions and join cardinality.
- Distinguish filtering in `ON` from filtering in `WHERE`.
- Avoid duplicate rows caused by incorrect join grain.
- Build reliable Data Engineering joins.

## 📚 Concepts

### 1. INNER JOIN

Returns rows that have matching values in both tables.

```sql
SELECT c.customer_id, c.customer_name, o.order_id
FROM customers c
INNER JOIN orders o
    ON c.customer_id = o.customer_id;
```

### 2. LEFT JOIN

Returns every row from the left table and matching rows from the right table. Missing matches produce NULLs.

```sql
SELECT c.customer_id, c.customer_name, o.order_id
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id;
```

### 3. RIGHT JOIN

Returns every row from the right table and matching rows from the left table. In practice, many teams rewrite it as a LEFT JOIN by swapping table order.

### 4. CROSS JOIN

Produces the Cartesian product: every row from one table is paired with every row from the other table.

### 5. Join condition vs filter

A predicate in `ON` controls matching. A predicate in `WHERE` filters the resulting rows. Moving a right-table filter from `ON` to `WHERE` can turn a LEFT JOIN into an effective INNER JOIN.

## 🌎 Real-World / Data Engineering Use Cases

- Combining customers with orders.
- Enriching fact records with dimension attributes.
- Finding unmatched source and target records.
- Building reporting datasets.
- Data reconciliation between systems.
- Detecting orphaned foreign keys.

## ⚠️ Common Mistakes

- Joining on the wrong key.
- Forgetting that one-to-many joins increase row counts.
- Using `SELECT *` when duplicate column names exist.
- Filtering a LEFT JOIN table in `WHERE` unintentionally.
- Joining tables at different grains without aggregating first.
- Accidentally creating a Cartesian product.
- Assuming every join should use an INNER JOIN.

## 🎤 Interview-Focused Questions

### Q1. What is the difference between INNER JOIN and LEFT JOIN?

<details>
<summary><strong>Answer</strong></summary>

INNER JOIN returns only matching rows. LEFT JOIN returns all rows from the left table and matching rows from the right table, with NULLs for unmatched right-side rows.

</details>

### Q2. How do you find customers who have never placed an order?

<details>
<summary><strong>Answer</strong></summary>

Use a LEFT JOIN and filter the right table for NULL:

```sql
SELECT c.customer_id
FROM customers c
LEFT JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
```

</details>

### Q3. Why can a join unexpectedly increase row count?

<details>
<summary><strong>Answer</strong></summary>

A one-to-many or many-to-many relationship can produce multiple output rows for one input row. The output grain must be understood before joining.

</details>

### Q4. What happens if you put a right-table filter in WHERE after a LEFT JOIN?

<details>
<summary><strong>Answer</strong></summary>

Rows where the right side is NULL are removed, so the query can behave like an INNER JOIN. Put the condition in `ON` when unmatched left rows must remain.

</details>

### Q5. How would you find orphan orders?

<details>
<summary><strong>Answer</strong></summary>

LEFT JOIN orders to customers and filter for a NULL customer key in the joined result.

</details>

### Q6. When would you use CROSS JOIN?

<details>
<summary><strong>Answer</strong></summary>

Use it intentionally when every combination is required, such as generating a product-by-date or scenario-by-region matrix. Avoid it accidentally because output size can grow rapidly.

</details>

### Q7. How do you avoid duplicate rows after a join?

<details>
<summary><strong>Answer</strong></summary>

First determine the expected grain, validate key uniqueness, and aggregate or deduplicate the many-side table before joining when appropriate.

</details>

### Q8. Can a LEFT JOIN be rewritten as an INNER JOIN?

<details>
<summary><strong>Answer</strong></summary>

If unmatched left rows are explicitly excluded by a condition requiring a non-NULL right-side match, the result may be equivalent to an INNER JOIN. The intended business semantics should determine which join is used.

</details>

### Q9. Why should join keys have compatible data types?

<details>
<summary><strong>Answer</strong></summary>

Mismatched types can cause implicit conversions, incorrect matches, and poorer performance. Join columns should use compatible definitions and appropriate indexes.

</details>

### Q10. How would you reconcile two systems using joins?

<details>
<summary><strong>Answer</strong></summary>

Use a FULL-OUTER-style reconciliation pattern, or equivalent LEFT/RIGHT joins in MySQL, to identify records present only in the source, only in the target, and present in both but with different attribute values.

</details>

## 🔄 Quick Revision

```text
INNER JOIN → matching rows only
LEFT JOIN  → all left + matching right
RIGHT JOIN → all right + matching left
CROSS JOIN → every combination
ON         → defines matching
WHERE      → filters result
Key rule   → always know the output grain
```

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — worked join examples
- [`practice.sql`](./practice.sql) — hands-on exercises and interview practice
