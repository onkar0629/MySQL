# 16 — Joins

## 📌 Overview

A **JOIN** combines rows from multiple tables using a relationship between columns. Joins are one of the most important SQL skills for Data Engineers because source systems are usually normalized, while analytics and warehouse workloads require data from several tables to be combined.

The most important skill is not memorizing JOIN syntax. It is understanding **table grain, join cardinality, keys, unmatched rows, and how the JOIN changes the number of rows**.

---

## 🎯 Learning Objectives

By the end of this topic, you should be able to:

- Explain why joins are required.
- Use `INNER JOIN`, `LEFT JOIN`, `RIGHT JOIN`, and `CROSS JOIN`.
- Understand self joins and non-equi joins.
- Understand join cardinality: one-to-one, one-to-many, and many-to-many.
- Predict how a join affects row count.
- Distinguish filtering in `ON` from filtering in `WHERE`.
- Find unmatched and orphan records.
- Reconcile source and target datasets.
- Avoid accidental many-to-many multiplication.
- Pre-aggregate data before joining when required.
- Understand why MySQL has no native `FULL OUTER JOIN`.
- Choose join keys and indexes appropriately.

---

## 🧠 1. What Is a JOIN?

Suppose we have:

**customers**

| customer_id | customer_name |
|---:|---|
| 1 | Asha |
| 2 | Rahul |
| 3 | Neha |

**orders**

| order_id | customer_id | amount |
|---:|---:|---:|
| 101 | 1 | 500 |
| 102 | 1 | 300 |
| 103 | 2 | 700 |

The relationship is:

```text
customers.customer_id
        ↓
orders.customer_id
```

A JOIN lets us combine the customer attributes with their orders.

```sql
SELECT
    c.customer_id,
    c.customer_name,
    o.order_id,
    o.amount
FROM customers AS c
JOIN orders AS o
    ON c.customer_id = o.customer_id;
```

Before writing a JOIN, identify:

1. What is the grain of each table?
2. What is the join key?
3. Is the key unique on either side?
4. Should unmatched rows be retained?
5. What should the output grain be?

---

## 🔑 2. Join Key

A **join key** is the column or set of columns used to match rows.

Simple key:

```sql
ON c.customer_id = o.customer_id
```

Composite key:

```sql
ON s.order_id = t.order_id
AND s.line_number = t.line_number
```

A good join key should represent the actual business relationship. Joining on a non-unique or incorrect column can silently create incorrect results.

### Data Engineering rule

Never assume a column is unique. Validate it when uniqueness matters.

```sql
SELECT customer_id, COUNT(*) AS row_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;
```

---

## 📊 3. Join Cardinality

Cardinality describes how many rows can match between the two tables.

### One-to-one

One row in A matches at most one row in B.

```text
customer → customer_profile
```

### One-to-many

One row in A can match many rows in B.

```text
customer → orders
```

One customer can have many orders, so one customer row can appear multiple times in the result.

### Many-to-many

Multiple rows in A can match multiple rows in B.

This can multiply rows very quickly and is a common source of incorrect aggregates.

### Critical rule

> **The output row count is determined by the matching relationships, not simply by the row count of either input table.**

---

## 🔵 4. INNER JOIN

Returns only rows that have a match on both sides.

```sql
SELECT
    c.customer_id,
    c.customer_name,
    o.order_id
FROM customers AS c
INNER JOIN orders AS o
    ON c.customer_id = o.customer_id;
```

Unmatched customers are removed.

### Use when

The business requirement says that a matching record is mandatory.

Examples:

- Orders with valid customers.
- Employees with valid departments.
- Fact records with matching dimension rows.

---

## 🟢 5. LEFT JOIN

Returns every row from the left table and matching rows from the right table.

```sql
SELECT
    c.customer_id,
    c.customer_name,
    o.order_id
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id;
```

If no order exists, the order columns are `NULL`.

### Common use

Find customers with no orders:

```sql
SELECT c.customer_id, c.customer_name
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
```

This is an **anti-join pattern**.

---

## 🟠 6. RIGHT JOIN

Returns every row from the right table and matching rows from the left table.

```sql
SELECT
    c.customer_id,
    o.order_id
FROM customers AS c
RIGHT JOIN orders AS o
    ON c.customer_id = o.customer_id;
```

In practice, `RIGHT JOIN` is often rewritten as a `LEFT JOIN` by swapping table order:

```sql
SELECT
    c.customer_id,
    o.order_id
FROM orders AS o
LEFT JOIN customers AS c
    ON c.customer_id = o.customer_id;
```

The second form is often easier to read because the preserved table is consistently on the left.

---

## 🟣 7. CROSS JOIN

Produces every possible combination of rows.

If table A has 10 rows and table B has 20 rows:

```text
10 × 20 = 200 output rows
```

Example:

```sql
SELECT
    p.product_id,
    d.calendar_date
FROM products AS p
CROSS JOIN calendar AS d;
```

This can intentionally generate a **product × date** matrix.

Never use `CROSS JOIN` accidentally. A missing join condition in an older comma-style query can have the same Cartesian-product effect.

---

## 🔄 8. Self JOIN

A table can be joined to itself using different aliases.

Example: employees and their managers stored in the same table.

```sql
SELECT
    e.employee_id,
    e.employee_name,
    m.employee_name AS manager_name
FROM employees AS e
LEFT JOIN employees AS m
    ON e.manager_id = m.employee_id;
```

Common uses:

- Employee-manager relationships.
- Parent-child hierarchies.
- Comparing rows within the same table.
- Finding related records.

---

## 📐 9. Non-Equi JOIN

A join does not always require `=`.

Example: assign employees to salary bands.

```sql
SELECT
    e.employee_id,
    e.salary,
    b.band_name
FROM employees AS e
JOIN salary_bands AS b
    ON e.salary >= b.min_salary
   AND e.salary < b.max_salary;
```

This is useful for:

- Ranges.
- Effective dates.
- Pricing rules.
- Salary bands.
- Threshold-based classifications.

Range joins require careful attention to overlapping ranges because one source row may match multiple range rows.

---

## 🗓️ 10. Date-Range JOINs

A common Data Engineering pattern is joining an event to the dimension record that was valid when the event occurred.

```sql
SELECT
    o.order_id,
    o.order_date,
    c.customer_segment
FROM orders AS o
JOIN customer_history AS c
    ON o.customer_id = c.customer_id
   AND o.order_date >= c.valid_from
   AND o.order_date <  c.valid_to;
```

Using a half-open interval:

```text
[valid_from, valid_to)
```

helps avoid overlapping boundary conditions.

The historical table must be designed so that a single event does not match multiple active records.

---

## ⚠️ 11. ON vs WHERE with LEFT JOIN

This is one of the most important JOIN interview concepts.

Consider:

```sql
SELECT c.customer_id, o.order_id
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE o.amount > 1000;
```

The `WHERE` condition removes rows where `o.amount` is `NULL`, so customers without matching orders disappear.

If the requirement is **keep all customers but only match orders above 1000**, put the condition in `ON`:

```sql
SELECT c.customer_id, o.order_id
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
   AND o.amount > 1000;
```

### Mental model

```text
ON     → decides which right-side rows match
WHERE  → filters the resulting rows
```

Moving predicates between them can change the semantics of an outer join.

---

## 💥 12. Join Multiplication

Suppose one customer has:

```text
3 orders
4 payments
```

If you directly join both child tables:

```text
customer
   ├── orders   → 3 rows
   └── payments → 4 rows
```

The customer can produce:

```text
3 × 4 = 12 rows
```

This can cause incorrect totals.

### Problematic pattern

```sql
SELECT
    c.customer_id,
    SUM(o.amount) AS order_total,
    SUM(p.amount) AS payment_total
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
LEFT JOIN payments AS p
    ON c.customer_id = p.customer_id
GROUP BY c.customer_id;
```

Both child tables multiply each other.

### Better approach: pre-aggregate

```sql
WITH order_totals AS (
    SELECT
        customer_id,
        SUM(amount) AS order_total
    FROM orders
    GROUP BY customer_id
),
payment_totals AS (
    SELECT
        customer_id,
        SUM(amount) AS payment_total
    FROM payments
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    COALESCE(o.order_total, 0) AS order_total,
    COALESCE(p.payment_total, 0) AS payment_total
FROM customers AS c
LEFT JOIN order_totals AS o
    ON c.customer_id = o.customer_id
LEFT JOIN payment_totals AS p
    ON c.customer_id = p.customer_id;
```

Now each aggregate has one row per customer before the final join.

---

## 🔍 13. Finding Unmatched Records

### Records in A with no match in B

```sql
SELECT a.*
FROM source_table AS a
LEFT JOIN target_table AS b
    ON a.business_key = b.business_key
WHERE b.business_key IS NULL;
```

This is useful for identifying records that failed to reach the target.

### Records in B with no match in A

Reverse the preserved table:

```sql
SELECT b.*
FROM target_table AS b
LEFT JOIN source_table AS a
    ON a.business_key = b.business_key
WHERE a.business_key IS NULL;
```

These patterns are fundamental for reconciliation jobs.

---

## 🔁 14. MySQL and FULL OUTER JOIN

MySQL does **not** provide a native `FULL OUTER JOIN` syntax.

A common pattern is to combine a `LEFT JOIN` and a reversed `LEFT JOIN` using `UNION`:

```sql
SELECT
    a.id,
    a.value,
    b.value AS target_value
FROM source_table AS a
LEFT JOIN target_table AS b
    ON a.id = b.id

UNION

SELECT
    b.id,
    a.value,
    b.value AS target_value
FROM target_table AS b
LEFT JOIN source_table AS a
    ON a.id = b.id
WHERE a.id IS NULL;
```

This produces rows present in either side.

For reconciliation, you can then classify records as:

```text
SOURCE_ONLY
TARGET_ONLY
MATCHED
```

---

## 🧩 15. Multi-Table JOINs

Real queries often join several tables.

```sql
SELECT
    o.order_id,
    c.customer_name,
    p.product_name,
    oi.quantity
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
JOIN order_items AS oi
    ON o.order_id = oi.order_id
JOIN products AS p
    ON oi.product_id = p.product_id;
```

Before adding another table, ask:

```text
What is the current grain?
What is the new table's grain?
What key connects them?
Will the join multiply rows?
```

This prevents many incorrect analytical queries.

---

## 🧮 16. JOIN + Aggregation

If the final requirement is one row per customer, but orders are many rows per customer, aggregate the orders first or group after the join carefully.

```sql
SELECT
    c.customer_id,
    COUNT(o.order_id) AS order_count,
    COALESCE(SUM(o.amount), 0) AS total_spend
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id;
```

Notice the use of:

```sql
COUNT(o.order_id)
```

rather than:

```sql
COUNT(*)
```

With a `LEFT JOIN`, `COUNT(*)` counts the preserved customer row even when there is no order.

---

## 🧠 17. EXISTS vs JOIN for Existence Checks

If the requirement is only to determine whether a related row exists, `EXISTS` can express the intent directly.

```sql
SELECT c.customer_id
FROM customers AS c
WHERE EXISTS (
    SELECT 1
    FROM orders AS o
    WHERE o.customer_id = c.customer_id
);
```

This is different from joining when you need columns from the matching table.

### Rule of thumb

```text
Need columns from another table → JOIN
Need only existence/non-existence → EXISTS / NOT EXISTS
```

Do not use `DISTINCT` blindly to hide duplicate rows created by an incorrect join.

---

## 🔗 18. Composite-Key JOINs

Some relationships require more than one column.

```sql
SELECT
    s.order_id,
    s.line_number,
    t.status
FROM source_order_lines AS s
JOIN target_order_lines AS t
    ON s.order_id = t.order_id
   AND s.line_number = t.line_number;
```

Joining only on `order_id` would incorrectly match every line belonging to that order.

This is especially important for transaction line-item data.

---

## 🧱 19. Joining Different Grains

Consider:

```text
orders       → one row per order
order_items  → one row per order item
customers    → one row per customer
```

Joining orders to order_items changes the grain from:

```text
one row per order
```

to:

```text
one row per order item
```

If you then calculate order-level metrics without accounting for the changed grain, values can be duplicated.

### Best practice

Document the grain before and after every major join.

---

## ⚡ 20. JOIN Performance

For large tables, join performance depends on data volume, indexes, join conditions, statistics, and the execution plan.

Useful checks:

- Index frequently used join keys where appropriate.
- Keep join-column data types compatible.
- Avoid unnecessary functions or implicit conversions on join keys.
- Reduce rows early when the filter is logically safe.
- Pre-aggregate large child tables when the required output grain is higher.
- Select only required columns.
- Check the execution plan with `EXPLAIN`.

Example:

```sql
EXPLAIN
SELECT ...
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id;
```

Do not add indexes blindly. Index design should consider the workload and existing access patterns.

---

## ⚠️ 21. Common JOIN Mistakes

### Mistake 1 — Wrong join key

Joining on a descriptive field such as `customer_name` instead of a stable key can create incorrect matches.

### Mistake 2 — Missing join condition

This can create a Cartesian product and explode row counts.

### Mistake 3 — Ignoring cardinality

A one-to-many join naturally increases rows. That is not automatically an error, but it must be expected.

### Mistake 4 — Using DISTINCT to hide duplicates

`DISTINCT` may hide the symptom without fixing the incorrect relationship.

### Mistake 5 — Filtering a LEFT JOIN in WHERE

A right-table condition in `WHERE` can remove unmatched left rows.

### Mistake 6 — Joining multiple many-side tables directly

This can create multiplicative duplication and incorrect aggregates.

### Mistake 7 — Ignoring NULL join keys

`NULL = NULL` is not TRUE, so rows with NULL join keys do not match through normal equality.

### Mistake 8 — Incomplete composite key

Joining on only part of a composite business key can produce false matches.

### Mistake 9 — Using incompatible data types

Implicit conversion can cause incorrect behavior and poor performance.

### Mistake 10 — Not checking output grain

A query can be syntactically correct and still produce the wrong business result because the grain changed.

---

## 🎤 Interview-Focused Questions

### Q1. What is the difference between INNER JOIN and LEFT JOIN?

<details>
<summary><strong>Answer</strong></summary>

`INNER JOIN` returns only matching rows from both tables. `LEFT JOIN` preserves every row from the left table and returns NULLs for unmatched right-side rows.

</details>

### Q2. Why can a JOIN increase the number of rows?

<details>
<summary><strong>Answer</strong></summary>

If one row on one side matches multiple rows on the other side, the row is repeated for each match. In a many-to-many relationship, combinations can multiply even further.

</details>

### Q3. How do you find customers who have never placed an order?

<details>
<summary><strong>Answer</strong></summary>

Use a `LEFT JOIN` and check for a NULL right-side key:

```sql
SELECT c.customer_id
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;
```

</details>

### Q4. What is the difference between putting a condition in ON and WHERE?

<details>
<summary><strong>Answer</strong></summary>

`ON` controls which rows match during the join. `WHERE` filters the rows after the join result is formed. With an outer join, moving a right-side condition from `ON` to `WHERE` can remove unmatched rows.

</details>

### Q5. Why is `COUNT(*)` dangerous with a LEFT JOIN?

<details>
<summary><strong>Answer</strong></summary>

`COUNT(*)` counts the preserved left row even when there is no matching right row. To count actual matches, count a nullable right-side key such as `COUNT(o.order_id)`.

</details>

### Q6. How would you prevent double counting when joining orders and payments?

<details>
<summary><strong>Answer</strong></summary>

Determine the required grain and pre-aggregate each many-side table to that grain before joining. Directly joining two one-to-many tables can multiply their rows.

</details>

### Q7. What is a self join? Give a practical example.

<details>
<summary><strong>Answer</strong></summary>

A self join joins a table to itself using different aliases. A common example is joining employees to the same employees table to retrieve each employee's manager.

</details>

### Q8. What is a non-equi join?

<details>
<summary><strong>Answer</strong></summary>

A non-equi join uses conditions other than simple equality, such as `<`, `>=`, or a range. It is commonly used for salary bands, pricing ranges, and effective-date joins.

</details>

### Q9. How would you perform a FULL OUTER JOIN in MySQL?

<details>
<summary><strong>Answer</strong></summary>

MySQL has no native `FULL OUTER JOIN`. A common approach is to combine a `LEFT JOIN` with the reverse `LEFT JOIN` using `UNION`, while filtering the second branch to unmatched rows to avoid duplicate matches.

</details>

### Q10. How do you reconcile source and target tables?

<details>
<summary><strong>Answer</strong></summary>

Join the datasets on their business key and classify records into matched, source-only, and target-only groups. For matched keys, compare important attributes or measures to identify differences.

</details>

### Q11. Why should you avoid using DISTINCT to fix JOIN duplicates?

<details>
<summary><strong>Answer</strong></summary>

`DISTINCT` removes duplicate output rows but does not correct an incorrect relationship. It can also hide legitimate multiple matches. First identify the join cardinality and correct the grain.

</details>

### Q12. What happens when both sides of a JOIN contain duplicate keys?

<details>
<summary><strong>Answer</strong></summary>

Matching rows form combinations. If key `X` appears 3 times in one table and 4 times in the other, the join can produce 12 rows for `X`.

</details>

### Q13. When would you use EXISTS instead of JOIN?

<details>
<summary><strong>Answer</strong></summary>

Use `EXISTS` when the requirement is to determine whether at least one related row exists and you do not need columns from the related table. It expresses an existence test directly and avoids introducing duplicate output rows from multiple matches.

</details>

### Q14. Why can joining on columns with different data types be a problem?

<details>
<summary><strong>Answer</strong></summary>

MySQL may perform implicit conversions. This can produce unexpected matches or reduce efficient index usage. Join keys should have compatible data types and semantics.

</details>

### Q15. How would you join a fact table to a historical dimension?

<details>
<summary><strong>Answer</strong></summary>

Join using the business key plus the fact's event date falling within the dimension record's validity interval, typically using `>= valid_from` and `< valid_to`. The historical dimension should prevent overlapping records for the same business key.

</details>

### Q16. How do you debug an unexpected row-count increase after a JOIN?

<details>
<summary><strong>Answer</strong></summary>

Check the row counts before and after the join, test uniqueness of the join keys on both sides, identify duplicate keys, determine the join cardinality, and inspect whether multiple many-side tables are being joined together.

</details>

---

## 🔄 Quick Revision

| Concept | Key Point |
|---|---|
| `INNER JOIN` | Matching rows only |
| `LEFT JOIN` | All left rows + matching right rows |
| `RIGHT JOIN` | All right rows + matching left rows |
| `CROSS JOIN` | Every possible combination |
| Self JOIN | A table joined to itself |
| Non-equi JOIN | Join using ranges or other operators |
| `ON` | Defines matching conditions |
| `WHERE` | Filters the resulting rows |
| Cardinality | Determines how rows can multiply |
| Anti-join | Find rows with no match |
| `EXISTS` | Test whether a related row exists |
| Pre-aggregation | Prevent many-to-many multiplication |
| MySQL FULL OUTER | Emulate with `LEFT JOIN` + `UNION` |
| Key principle | Always know the input and output grain |

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — practical JOIN examples
- [`practice.sql`](./practice.sql) — hands-on JOIN exercises and interview practice
