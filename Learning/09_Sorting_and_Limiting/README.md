# 09 — Sorting and Limiting

## 📌 Overview

Sorting and limiting determine **which rows appear first and how many rows are returned**.

This topic is much more important than it may initially look. A query such as `ORDER BY ... LIMIT 10` is commonly used for dashboards, APIs, operational monitoring, Data Engineering validation, latest-record retrieval, top-N analysis, and pagination.

The key principle is:

> **`LIMIT` without a meaningful `ORDER BY` does not define which rows should be returned.**

For production systems, ordering should also be deterministic when ties are possible.

---

## 🎯 Learning Objectives

By the end of this topic, you should be able to:

- Use `ORDER BY` correctly.
- Sort ascending and descending.
- Sort using multiple columns.
- Sort by expressions and aliases.
- Understand how `NULL` values affect ordering.
- Use `LIMIT` and `OFFSET`.
- Build top-N and bottom-N queries.
- Build deterministic latest-record queries.
- Understand offset vs keyset pagination.
- Use pagination safely on changing datasets.
- Understand the performance implications of sorting.
- Apply ordering and limiting to Data Engineering scenarios.

---

## 🧠 1. What Does ORDER BY Do?

`ORDER BY` determines the order of rows in the query result.

```sql
SELECT
    employee_id,
    employee_name,
    salary
FROM employees
ORDER BY salary DESC;
```

The highest salaries appear first.

### Default direction

`ASC` is the default:

```sql
ORDER BY salary ASC;
```

You can write it explicitly for readability.

---

## 🔼 2. ASC vs DESC

### Ascending

```sql
ORDER BY salary ASC;
```

Conceptually:

```text
10000
20000
30000
40000
```

### Descending

```sql
ORDER BY salary DESC;
```

Conceptually:

```text
40000
30000
20000
10000
```

The same principle applies to dates:

```sql
ORDER BY created_at DESC
```

usually means newest values first.

---

## 🔢 3. Sorting by Multiple Columns

You can provide several sort expressions.

```sql
SELECT
    employee_id,
    department,
    salary
FROM employees
ORDER BY
    department ASC,
    salary DESC,
    employee_id ASC;
```

MySQL first sorts by `department`.

If two rows have the same department, it compares `salary`.

If salary is also tied, it compares `employee_id`.

Think of it as a hierarchy:

```text
1. department
       ↓ tie
2. salary
       ↓ tie
3. employee_id
```

---

## 🎯 4. Why a Tie-Breaker Matters

Suppose:

```text
order_id | amount
---------+-------
101      | 500
102      | 500
103      | 500
```

This query:

```sql
ORDER BY amount DESC
LIMIT 2;
```

does not define which two of the tied rows should be selected.

Make it deterministic:

```sql
ORDER BY amount DESC, order_id ASC
LIMIT 2;
```

Now the database has a complete ordering rule.

### Interview principle

> When using `LIMIT` for a business-defined top-N result, use a stable tie-breaker when the primary sort key is not unique.

---

## 🧮 5. Sorting by an Expression

You can sort using a calculated expression.

```sql
SELECT
    employee_name,
    salary * 12 AS annual_salary
FROM employees
ORDER BY annual_salary DESC;
```

You can also write:

```sql
ORDER BY salary * 12 DESC;
```

The alias form is often easier to read.

---

## 🏷️ 6. ORDER BY a SELECT Alias

Unlike `WHERE`, `ORDER BY` can generally reference a SELECT alias from the same query block.

```sql
SELECT
    salary * 12 AS annual_salary
FROM employees
ORDER BY annual_salary DESC;
```

This works because `ORDER BY` is logically evaluated after the result expressions have been established in the conceptual processing order.

---

## 📋 7. LIMIT

`LIMIT` restricts the number of rows returned.

```sql
SELECT
    order_id,
    amount
FROM orders
ORDER BY amount DESC
LIMIT 10;
```

This means:

> Return at most 10 rows from the ordered result.

### Critical point

This:

```sql
SELECT *
FROM orders
LIMIT 10;
```

does **not** mean:

> Give me the 10 newest orders.

There is no specified ordering.

For the newest 10:

```sql
SELECT *
FROM orders
ORDER BY order_date DESC, order_id DESC
LIMIT 10;
```

---

## 🔢 8. LIMIT with an Offset

MySQL supports:

```sql
LIMIT 10 OFFSET 20;
```

This means:

```text
Skip first 20 rows
        ↓
Return next 10 rows
```

An alternative MySQL syntax is:

```sql
LIMIT 20, 10;
```

where the first number is the offset and the second is the row count.

For readability, `LIMIT ... OFFSET ...` is often clearer.

---

## 🏆 9. Top-N Queries

### Top 5 highest-value orders

```sql
SELECT
    order_id,
    amount
FROM orders
ORDER BY amount DESC, order_id ASC
LIMIT 5;
```

### Top 10 customers by spend

```sql
SELECT
    customer_id,
    lifetime_spend
FROM customers
ORDER BY lifetime_spend DESC, customer_id ASC
LIMIT 10;
```

The tie-breaker makes the selection reproducible.

---

## 📉 10. Bottom-N Queries

To find the five smallest values:

```sql
SELECT
    product_id,
    price
FROM products
ORDER BY price ASC, product_id ASC
LIMIT 5;
```

The same deterministic-order principle applies.

---

## 🕒 11. Latest Record

A common Data Engineering requirement is:

> Find the most recent pipeline run.

```sql
SELECT
    run_id,
    status,
    started_at
FROM pipeline_runs
ORDER BY started_at DESC, run_id DESC
LIMIT 1;
```

The timestamp identifies recency, while `run_id` resolves equal timestamps.

---

## 🧠 12. Latest N Records

```sql
SELECT
    event_id,
    event_time,
    event_type
FROM events
ORDER BY event_time DESC, event_id DESC
LIMIT 100;
```

This is useful for operational monitoring and debugging recent ingestion activity.

---

## NULL 13. NULL Ordering

Do not assume NULL ordering from business meaning alone.

If you want non-NULL scores first and NULL scores last:

```sql
SELECT
    employee_id,
    score
FROM employees
ORDER BY
    (score IS NULL) ASC,
    score DESC,
    employee_id ASC;
```

The expression:

```sql
(score IS NULL)
```

produces a boolean-like result, allowing you to explicitly control NULL placement.

### Why explicit ordering is useful

Suppose `score` is optional. A business rule may say:

```text
Highest scores first
Unknown scores last
```

Encode that rule rather than relying on an implicit assumption.

---

## 📄 14. Offset Pagination

A simple API-style pagination query might be:

```sql
SELECT
    order_id,
    customer_id,
    order_date
FROM orders
ORDER BY order_date DESC, order_id DESC
LIMIT 20 OFFSET 40;
```

This represents:

```text
Page size = 20
Offset    = 40
```

So the query requests the next 20 rows after the first 40.

### Requirement for safe pagination

The ordering must be deterministic:

```sql
ORDER BY order_date DESC, order_id DESC
```

Without a stable ordering, rows can move between pages.

---

## 🚀 15. Keyset Pagination

For large tables, offset pagination can become expensive because the database may need to process and skip many earlier rows.

Keyset pagination uses the last row from the previous page as a boundary.

Suppose the previous page ended with:

```text
order_date = '2026-08-10 12:00:00'
order_id   = 5000
```

The next page can use:

```sql
SELECT
    order_id,
    order_date,
    customer_id
FROM orders
WHERE (order_date, order_id) < ('2026-08-10 12:00:00', 5000)
ORDER BY order_date DESC, order_id DESC
LIMIT 20;
```

The exact comparison depends on the direction and columns used in the ordering.

### Concept

```text
Page 1
 ↓
last_seen_key
 ↓
Page 2 starts after that key
 ↓
last_seen_key
 ↓
Page 3
```

This is often more scalable for large, ordered datasets.

---

## ⚖️ 16. Offset vs Keyset Pagination

| Feature | Offset | Keyset |
|---|---|---|
| Easy to implement | Yes | Moderate |
| Supports arbitrary page number | Yes | Not naturally |
| Deep-page performance | Can degrade | Usually better |
| Requires stable sort key | Yes | Yes |
| Good for huge datasets | Often less suitable | Often better |
| Good for simple UI pagination | Yes | Yes |

Choose based on the application's access pattern rather than using one technique everywhere.

---

## 🔄 17. Pagination on Changing Data

Suppose a new order arrives between page 1 and page 2.

With offset pagination, rows can shift positions:

```text
Page 1 before insert
A B C D E

New row X arrives

Page 2 may now contain different rows
```

This can cause:

- Duplicates across pages
- Missing records
- Inconsistent results

A stable ordering plus keyset pagination can reduce these problems for appropriate workloads.

For highly consistent snapshots, additional transaction/isolation or application-level strategies may be required.

---

## 🧠 18. ORDER BY and NULLs with Multiple Keys

You can combine explicit NULL handling with normal sorting.

```sql
ORDER BY
    (last_login IS NULL) ASC,
    last_login DESC,
    user_id ASC;
```

This means:

1. Users with a login timestamp first.
2. Most recent login first.
3. `user_id` resolves remaining ties.

This is a good example of converting a business ordering rule into explicit SQL.

---

## 🏗️ 19. Data Engineering Use Cases

### Latest successful pipeline run

```sql
SELECT
    run_id,
    completed_at
FROM pipeline_runs
WHERE status = 'SUCCESS'
ORDER BY completed_at DESC, run_id DESC
LIMIT 1;
```

### Most recent ingestion events

```sql
SELECT *
FROM ingestion_events
ORDER BY ingestion_time DESC, event_id DESC
LIMIT 100;
```

### Highest-volume customers

```sql
SELECT
    customer_id,
    total_orders
FROM customer_metrics
ORDER BY total_orders DESC, customer_id ASC
LIMIT 20;
```

### Operational monitoring

```sql
SELECT
    job_name,
    status,
    started_at
FROM pipeline_runs
ORDER BY started_at DESC, run_id DESC
LIMIT 50;
```

Sorting and limiting are therefore useful for both analytics and operational Data Engineering.

---

## 🧪 20. Deterministic Sampling

If you need a reproducible subset of rows, define an ordering rule.

For example:

```sql
SELECT
    customer_id,
    customer_name
FROM customers
ORDER BY customer_id
LIMIT 100;
```

This is preferable to relying on an unspecified row order.

If you intentionally want random sampling, that is a different requirement and should use an explicit randomization strategy rather than assuming natural row order.

---

## 🧠 21. Logical Query Processing

A simplified conceptual order is:

```text
FROM
  ↓
WHERE
  ↓
GROUP BY
  ↓
HAVING
  ↓
SELECT
  ↓
ORDER BY
  ↓
LIMIT
```

This helps explain why:

- `WHERE` filters rows before final ordering.
- `ORDER BY` controls the final result order.
- `LIMIT` restricts the ordered result.

This is a **logical model**, not a literal description of every physical operation performed by the MySQL optimizer.

---

## ⚡ 22. Performance Considerations

Sorting can become expensive on large datasets.

### Index-aware ordering

If a query frequently uses:

```sql
WHERE customer_id = 1001
ORDER BY order_date DESC
LIMIT 20;
```

an appropriate composite index may help MySQL locate and retrieve the required rows efficiently.

### Large OFFSET

A query such as:

```sql
LIMIT 20 OFFSET 1000000
```

may require substantial work to reach the requested page.

Keyset pagination can often avoid scanning past a huge number of earlier rows.

### Return only required columns

Prefer:

```sql
SELECT order_id, order_date, amount
```

over:

```sql
SELECT *
```

when only a few columns are required.

### Check the execution plan

Use:

```sql
EXPLAIN
SELECT ...;
```

Do not assume an index will automatically make every sort efficient. Verify the actual plan.

---

## ⚠️ 23. Common Mistakes

### Mistake 1 — LIMIT without ORDER BY

You cannot interpret the result as a top, latest, or bottom set without a defined order.

### Mistake 2 — Ignoring ties

A top-N query may return different tied rows unless a stable tie-breaker is included.

### Mistake 3 — Assuming physical row order

Relational tables do not guarantee result ordering without `ORDER BY`.

### Mistake 4 — Unstable pagination

Pagination needs a deterministic ordering key.

### Mistake 5 — Huge OFFSET values

Deep offset pagination can become inefficient on large datasets.

### Mistake 6 — Ignoring NULL ordering

If NULL placement matters to the business, make it explicit.

### Mistake 7 — Selecting unnecessary columns

Large rows increase I/O and network transfer.

### Mistake 8 — Using a non-unique timestamp as the only pagination key

Equal timestamps can cause ambiguous boundaries. Add a unique tie-breaker.

---

## 🎤 24. Interview-Focused Questions

### Q1. Why should LIMIT normally be paired with ORDER BY?

<details>
<summary><strong>Answer</strong></summary>

`LIMIT` only restricts the number of rows. It does not define which rows should be selected. Without `ORDER BY`, the result is not guaranteed to represent the newest, highest, lowest, or otherwise business-defined records.

</details>

---

### Q2. What happens when two rows have the same value in an ORDER BY column?

<details>
<summary><strong>Answer</strong></summary>

Those rows are tied on that sort key. Their relative order is not fully defined unless additional sort keys are supplied. Add a stable unique tie-breaker such as a primary key when deterministic results matter.

</details>

---

### Q3. How would you find the top 10 customers by revenue?

<details>
<summary><strong>Answer</strong></summary>

Aggregate revenue first if necessary, then sort descending and limit the result:

```sql
SELECT customer_id, revenue
FROM customer_revenue
ORDER BY revenue DESC, customer_id ASC
LIMIT 10;
```

The secondary key makes ties deterministic.

</details>

---

### Q4. What is the difference between LIMIT 10 and LIMIT 10 OFFSET 20?

<details>
<summary><strong>Answer</strong></summary>

`LIMIT 10` returns up to ten rows from the beginning of the ordered result. `LIMIT 10 OFFSET 20` skips twenty rows and then returns up to ten rows.

</details>

---

### Q5. Can you rely on the physical order of rows in MySQL?

<details>
<summary><strong>Answer</strong></summary>

No. A SQL result has no guaranteed ordering unless the query specifies `ORDER BY`. Physical storage order should never be treated as a business ordering rule.

</details>

---

### Q6. How do you get the latest record from a table?

<details>
<summary><strong>Answer</strong></summary>

Use a descending timestamp order and a deterministic tie-breaker:

```sql
SELECT *
FROM pipeline_runs
ORDER BY started_at DESC, run_id DESC
LIMIT 1;
```

</details>

---

### Q7. Why is a unique tie-breaker important in pagination?

<details>
<summary><strong>Answer</strong></summary>

If the primary sort value is duplicated, the database cannot establish a complete order. Rows can move between pages or produce inconsistent boundaries. A unique key completes the ordering.

</details>

---

### Q8. What is the difference between offset and keyset pagination?

<details>
<summary><strong>Answer</strong></summary>

Offset pagination skips a specified number of rows. Keyset pagination uses the last-seen sort key as the boundary for the next page. Keyset pagination generally scales better for deep pages because it does not need to repeatedly skip all preceding rows.

</details>

---

### Q9. How can you place NULL values last when sorting descending?

<details>
<summary><strong>Answer</strong></summary>

Make the desired NULL ordering explicit:

```sql
ORDER BY (score IS NULL) ASC,
         score DESC,
         employee_id ASC;
```

The boolean expression separates NULL and non-NULL rows before applying the score order.

</details>

---

### Q10. Why can large OFFSET values hurt performance?

<details>
<summary><strong>Answer</strong></summary>

The database may need to locate, process, and discard a large number of preceding rows before returning the requested page. As the offset grows, this can become increasingly expensive. Keyset pagination can be a better fit for large datasets.

</details>

---

### Q11. Can ORDER BY use a SELECT alias?

<details>
<summary><strong>Answer</strong></summary>

Yes. For example:

```sql
SELECT salary * 12 AS annual_salary
FROM employees
ORDER BY annual_salary DESC;
```

An alias from the same SELECT query block can generally be referenced by `ORDER BY`.

</details>

---

### Q12. How would you design pagination for a large Data Engineering API?

<details>
<summary><strong>Answer</strong></summary>

Use a deterministic ordering such as `event_time DESC, event_id DESC`, and prefer keyset pagination when deep pages and large datasets are expected. The client can send the last-seen key as the cursor for the next request.

</details>

---

### Q13. Why is a timestamp alone sometimes a bad pagination key?

<details>
<summary><strong>Answer</strong></summary>

Multiple records can share the same timestamp. If the timestamp is not unique, the boundary between pages is ambiguous. Pair the timestamp with a unique identifier to create a deterministic ordering.

</details>

---

### Q14. How would you get the latest 100 events for monitoring?

<details>
<summary><strong>Answer</strong></summary>

Use descending event time plus a stable tie-breaker:

```sql
SELECT event_id, event_time, event_type
FROM ingestion_events
ORDER BY event_time DESC, event_id DESC
LIMIT 100;
```

</details>

---

## 🔄 25. Quick Revision

| Concept | Key Point |
|---|---|
| `ORDER BY` | Sorts the result |
| `ASC` | Ascending; default |
| `DESC` | Descending |
| Multiple keys | Resolve ties progressively |
| Tie-breaker | Makes ordering deterministic |
| `LIMIT` | Restricts row count |
| `OFFSET` | Skips rows |
| Top-N | Descending order + LIMIT |
| Bottom-N | Ascending order + LIMIT |
| Offset pagination | Page number based |
| Keyset pagination | Cursor/key based |
| NULL ordering | Make business behavior explicit |
| `EXPLAIN` | Inspect execution plan |

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — worked examples for sorting, LIMIT, OFFSET, top-N, and pagination
- [`practice.sql`](./practice.sql) — hands-on exercises, pagination scenarios, and interview practice
