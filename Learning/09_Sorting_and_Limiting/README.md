# 09 — Sorting and Limiting

## 📌 Overview

Sorting and limiting control the order and number of rows returned by a query. This topic covers `ORDER BY`, `LIMIT`, `OFFSET`, deterministic ordering, top-N queries, pagination, and Data Engineering use cases.

## 🎯 Learning Objectives

By the end of this topic, you should be able to:

- Sort rows with `ORDER BY`
- Sort by multiple columns
- Use ascending and descending order
- Sort by expressions and aliases
- Handle `NULL` values intentionally
- Use `LIMIT` and `OFFSET`
- Build top-N and bottom-N queries
- Understand deterministic ordering
- Apply sorting and pagination safely in production queries

## 1. ORDER BY

`ORDER BY` sorts the final result set.

```sql
SELECT employee_name, salary
FROM employees
ORDER BY salary DESC;
```

`ASC` is the default.

```sql
ORDER BY salary ASC;
```

## 2. Multiple Sort Columns

When rows have the same value for the first sort key, MySQL uses the next expression.

```sql
ORDER BY department ASC, salary DESC, employee_id ASC;
```

A unique final key such as `employee_id` makes the order deterministic.

## 3. Sorting by an Expression

```sql
SELECT employee_name, salary * 12 AS annual_salary
FROM employees
ORDER BY annual_salary DESC;
```

Aliases can be referenced by `ORDER BY` in the same query block.

## 4. LIMIT

Return only a specified number of rows.

```sql
SELECT *
FROM orders
ORDER BY order_date DESC
LIMIT 10;
```

Without `ORDER BY`, `LIMIT` does **not** mean the ten newest or highest rows; the selected rows are not guaranteed to represent a meaningful order.

## 5. OFFSET

`OFFSET` skips rows before returning the requested number.

```sql
SELECT *
FROM orders
ORDER BY order_id
LIMIT 10 OFFSET 20;
```

This is useful for simple page-based pagination.

## 6. Top-N Queries

Find the five highest-value orders:

```sql
SELECT order_id, amount
FROM orders
ORDER BY amount DESC, order_id ASC
LIMIT 5;
```

The secondary key ensures deterministic results when amounts tie.

## 7. Bottom-N Queries

```sql
SELECT order_id, amount
FROM orders
ORDER BY amount ASC, order_id ASC
LIMIT 5;
```

## 8. NULL Ordering

`NULL` ordering should be understood rather than assumed. If a specific business order is required, make it explicit with an expression.

```sql
ORDER BY (score IS NULL), score DESC;
```

This places non-NULL scores first and NULL scores last.

## 9. Pagination

Offset pagination:

```sql
SELECT order_id, customer_id, order_date
FROM orders
ORDER BY order_date DESC, order_id DESC
LIMIT 20 OFFSET 40;
```

For large tables, keyset pagination can be more efficient:

```sql
SELECT order_id, order_date
FROM orders
WHERE (order_date, order_id) < ('2026-08-10 12:00:00', 5000)
ORDER BY order_date DESC, order_id DESC
LIMIT 20;
```

The exact predicate depends on the chosen sort keys.

## 10. Data Engineering Patterns

### Latest records

```sql
SELECT *
FROM pipeline_runs
ORDER BY started_at DESC, run_id DESC
LIMIT 1;
```

### Most recent batch records

```sql
SELECT *
FROM staging_events
ORDER BY updated_at DESC, event_id DESC
LIMIT 100;
```

### Reproducible sample

Always specify an ordering key when a query's result depends on which rows are selected.

## 11. Logical Query Processing

A simplified conceptual order is:

`FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT`

This helps explain why `ORDER BY` controls the final ordering and `LIMIT` restricts the final result set.

## 12. Performance Considerations

- Index columns frequently used for filtering and ordering when appropriate.
- Avoid large `OFFSET` values on high-volume tables when latency matters.
- Use deterministic tie-breakers for production pagination.
- Return only required columns instead of `SELECT *`.
- Test execution plans for expensive sort operations.

## 13. Common Mistakes

- Using `LIMIT` without `ORDER BY` when a specific top/bottom result is required
- Forgetting that `ASC` is the default
- Ignoring ties in top-N queries
- Using unstable pagination ordering
- Assuming physical row order is guaranteed
- Using huge offsets on large tables without considering keyset pagination
- Sorting by a column whose NULL behavior has not been considered

## 14. Interview-Focused Questions

### Q1. Why should `LIMIT` normally be paired with `ORDER BY`?

<details>
<summary><strong>Answer</strong></summary>

`LIMIT` only restricts how many rows are returned. Without `ORDER BY`, there is no guaranteed business ordering, so the selected rows should not be interpreted as the top, latest, or earliest records.

</details>

### Q2. What is the difference between `LIMIT 10` and `LIMIT 10 OFFSET 20`?

<details>
<summary><strong>Answer</strong></summary>

The first returns up to ten rows from the beginning of the ordered result. The second skips twenty rows and then returns up to ten rows.

</details>

### Q3. How do you make a top-N query deterministic when values tie?

<details>
<summary><strong>Answer</strong></summary>

Add a stable secondary sort key, preferably a unique column such as the primary key: `ORDER BY amount DESC, order_id ASC`.

</details>

### Q4. What is the difference between OFFSET pagination and keyset pagination?

<details>
<summary><strong>Answer</strong></summary>

Offset pagination skips a number of rows and can become expensive for deep pages. Keyset pagination uses the last seen sort key as a boundary and is generally more suitable for large, continuously changing datasets.

</details>

### Q5. Can you rely on the physical order of rows in a table?

<details>
<summary><strong>Answer</strong></summary>

No. SQL does not guarantee row order unless an `ORDER BY` clause specifies it.

</details>

### Q6. How would you get the latest record from a table?

<details>
<summary><strong>Answer</strong></summary>

Sort by the timestamp descending and add a deterministic tie-breaker, then use `LIMIT 1`.

</details>

### Q7. How can you put NULL values last when sorting descending?

<details>
<summary><strong>Answer</strong></summary>

Make the NULL ordering explicit, for example `ORDER BY (score IS NULL), score DESC`. The boolean expression places non-NULL rows first.

</details>

### Q8. Why can large OFFSET values hurt performance?

<details>
<summary><strong>Answer</strong></summary>

The database may need to process and skip many preceding rows before returning the requested page. Keyset pagination can avoid repeatedly scanning past earlier pages.

</details>

### Q9. Can ORDER BY use a SELECT alias?

<details>
<summary><strong>Answer</strong></summary>

Yes, an alias defined in the same SELECT query block can generally be referenced by `ORDER BY`, such as `SELECT salary * 12 AS annual_salary ... ORDER BY annual_salary DESC`.

</details>

### Q10. What is a good pagination ordering strategy for a Data Engineering API?

<details>
<summary><strong>Answer</strong></summary>

Use a stable, deterministic ordering, typically a timestamp plus a unique tie-breaker such as an ID. For large datasets, prefer keyset pagination when the access pattern supports it.

</details>

## 15. Quick Revision

| Concept | Key Point |
|---|---|
| `ORDER BY` | Sorts the result set |
| `ASC` | Ascending; default direction |
| `DESC` | Descending |
| Multiple keys | Resolves ties progressively |
| `LIMIT` | Restricts returned rows |
| `OFFSET` | Skips rows before returning results |
| Top-N | `ORDER BY ... DESC LIMIT N` |
| Bottom-N | `ORDER BY ... ASC LIMIT N` |
| Deterministic order | Use a stable tie-breaker |
| Keyset pagination | Efficient pagination for large datasets |

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — worked examples for sorting and limiting in MySQL
- [`practice.sql`](./practice.sql) — hands-on exercises and interview practice
