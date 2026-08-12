# 20 — Views

## 📌 Overview

A **view** is a named query stored as a database object. It provides a reusable interface over base tables without normally storing a separate copy of the result rows.

For Data Engineering, the important questions are: **when should a view be used, what does it hide, what can be updated, and what happens to performance?**

## 🎯 Learning Objectives

- Create, replace, query, and drop views.
- Understand views vs tables, CTEs, and derived tables.
- Build views over filters, joins, and aggregations.
- Understand view security and column exposure.
- Understand updatable vs non-updatable views.
- Understand how MySQL handles view definitions and dependencies.
- Evaluate view performance with `EXPLAIN`.
- Use views appropriately in reporting and Data Engineering workloads.

## 1. Creating and Querying a View

```sql
CREATE VIEW active_customers AS
SELECT customer_id, customer_name, email
FROM customers
WHERE status = 'ACTIVE';
```

Query it like a table:

```sql
SELECT * FROM active_customers;
```

A view stores the query definition; it is not automatically a materialized copy of the result.

## 2. Replacing and Dropping a View

```sql
CREATE OR REPLACE VIEW active_customers AS
SELECT customer_id, customer_name, email, created_at
FROM customers
WHERE status = 'ACTIVE';
```

```sql
DROP VIEW IF EXISTS active_customers;
```

## 3. View vs Table vs CTE

| Object | Main purpose | Scope / persistence |
|---|---|---|
| Table | Stores data | Persistent |
| View | Reusable query interface | Persistent database object |
| CTE | Organizes one query | One SQL statement |

Use a **CTE** when logic belongs to one query. Use a **view** when the same logical interface should be reused by multiple consumers.

## 4. Views with Joins and Aggregation

```sql
CREATE VIEW customer_order_summary AS
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS order_count,
    COALESCE(SUM(o.amount), 0) AS total_spend
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name;
```

With a `LEFT JOIN`, `COUNT(o.order_id)` preserves customers with no orders as `0`. Always verify the grain before aggregating inside a view.

## 5. Views as a Stable Interface

Expose only the columns required by downstream users:

```sql
CREATE VIEW customer_reporting AS
SELECT customer_id, customer_name, status
FROM customers;
```

Avoid `SELECT *` in long-lived views because changes to the underlying schema can make the interface unpredictable.

## 6. Security and Views

A view can restrict exposed rows or columns:

```sql
CREATE VIEW employee_directory AS
SELECT employee_id, employee_name, department_id
FROM employees;
```

This can reduce exposure of sensitive columns, but **a view is not a complete security model**. MySQL privileges must still be configured correctly.

## 7. Updatable Views

Some simple views can support `INSERT`, `UPDATE`, or `DELETE` when MySQL's updatability rules allow it.

Views containing constructs such as aggregation, `GROUP BY`, `DISTINCT`, or other non-updatable constructs generally cannot be modified directly.

Do not assume a view is updatable; check the specific definition and MySQL rules.

## 8. WITH CHECK OPTION

For an updatable restricted view, `WITH CHECK OPTION` can enforce that changes made through the view continue to satisfy its predicate.

```sql
CREATE VIEW active_customers AS
SELECT customer_id, customer_name, status
FROM customers
WHERE status = 'ACTIVE'
WITH CHECK OPTION;
```

This is useful when the view represents a writable subset of a base table.

## 9. Inspecting Views

```sql
SHOW CREATE VIEW active_customers;
```

For metadata and documentation tooling, `INFORMATION_SCHEMA.VIEWS` can also be useful.

## 10. View Dependencies

A view depends on objects referenced by its definition:

```text
customers ──┐
            ├──> customer_order_summary
orders ─────┘
```

Changes to underlying tables can affect dependent views and downstream queries. Important views should therefore be treated as part of the database dependency graph.

## 11. Performance

A normal view is **not automatically a performance optimization**. MySQL still has to execute the underlying logic needed to produce the result.

Watch for:

- Expensive joins
- Large aggregations
- Non-sargable predicates
- Repeated scans
- Deep chains of dependent views

Investigate the consuming query with:

```sql
EXPLAIN
SELECT *
FROM customer_order_summary
WHERE total_spend >= 5000;
```

## 12. View vs Materialized Result

A normal MySQL view should not be confused with a materialized result. A normal view stores a query definition; a materialized result physically stores computed data and requires a refresh strategy.

For expensive reporting logic, a Data Engineering pipeline may instead maintain a physical summary table:

```text
Base tables
    ↓
Transformation
    ↓
Summary table
    ↓
Reporting
```

The choice depends on freshness, query cost, storage, and operational requirements.

## 13. Practical Data Engineering Uses

### Standardized reporting

```sql
CREATE VIEW daily_sales AS
SELECT
    order_date,
    COUNT(*) AS order_count,
    SUM(amount) AS total_sales
FROM orders
GROUP BY order_date;
```

Other useful cases include source abstraction, controlled column exposure, and reusable business definitions.

A view is valuable when it provides a **clear and stable interface**, not merely because it saves a few lines of SQL.

## ⚠️ Common Mistakes

- Assuming a view stores result data.
- Assuming a view automatically improves performance.
- Using `SELECT *` in a long-lived interface.
- Ignoring join grain and double-counting inside an aggregated view.
- Assuming every view is updatable.
- Treating a view as a complete security solution.
- Building excessive layers of dependent views.
- Forgetting that base-table changes can affect dependent views.

## 🎤 Interview-Focused Questions

### Q1. What is a view?

<details>
<summary><strong>Answer</strong></summary>

A view is a named database object containing a query definition. It can be queried like a table, but a normal view does not store a separate copy of its result rows.
</details>

### Q2. View vs CTE — when would you use each?

<details>
<summary><strong>Answer</strong></summary>

Use a CTE for query-local organization within one statement. Use a view when a reusable database-level interface is needed by multiple queries or consumers.
</details>

### Q3. Does a view improve performance?

<details>
<summary><strong>Answer</strong></summary>

Not inherently. A normal view is primarily an abstraction and reuse mechanism. The underlying query still has to execute to produce the result. Check the actual plan.
</details>

### Q4. Are all views updatable?

<details>
<summary><strong>Answer</strong></summary>

No. Updatability depends on the view definition. Aggregation, grouping, `DISTINCT`, and other constructs can make a view non-updatable.
</details>

### Q5. Why use COUNT(child_id) instead of COUNT(*) in a LEFT JOIN view?

<details>
<summary><strong>Answer</strong></summary>

A `LEFT JOIN` preserves the parent row even when no child exists. `COUNT(*)` counts that preserved row, while `COUNT(child_id)` counts only matching child rows and therefore returns zero for a parent with no children.
</details>

### Q6. How can a view help with security?

<details>
<summary><strong>Answer</strong></summary>

A view can expose only approved rows or columns, reducing the data consumers need to access directly. Database privileges are still required.
</details>

### Q7. What is WITH CHECK OPTION used for?

<details>
<summary><strong>Answer</strong></summary>

It can enforce that inserts or updates made through an updatable view continue to satisfy the view's filtering condition.
</details>

### Q8. What is the difference between a normal view and a materialized result?

<details>
<summary><strong>Answer</strong></summary>

A normal view stores the query definition and computes results when queried. A materialized result physically stores computed rows and requires a refresh strategy.
</details>

### Q9. What problem can occur when aggregating inside a view with joins?

<details>
<summary><strong>Answer</strong></summary>

A one-to-many join can multiply rows and inflate aggregates. The view must be designed around the correct grain, and pre-aggregation may be required before joining.
</details>

### Q10. How would you investigate a slow query using a view?

<details>
<summary><strong>Answer</strong></summary>

Use `EXPLAIN` on the consuming query and inspect the underlying joins, filters, aggregations, indexes, and row counts. A view is not a performance boundary.
</details>

### Q11. Why avoid SELECT * in a long-lived view?

<details>
<summary><strong>Answer</strong></summary>

It makes the view interface depend on the current base-table schema. New or changed columns can unexpectedly alter downstream results. Explicit columns provide a more stable contract.
</details>

### Q12. When would you choose a physical summary table instead of a view?

<details>
<summary><strong>Answer</strong></summary>

When repeatedly computing expensive logic is too costly and the workload can tolerate stored results with a defined refresh or incremental-load strategy.
</details>

## 🔄 Quick Revision

| Concept | Key Point |
|---|---|
| View | Persistent named query |
| Normal view | Does not normally materialize result rows |
| CTE | Query-scoped named result |
| Updatable view | Depends on definition |
| `WITH CHECK OPTION` | Enforces view predicate for writable operations |
| Security | Requires privileges; view can restrict exposure |
| Performance | Not automatically faster |
| `EXPLAIN` | Inspect actual execution plan |
| Materialized result | Physically stored computed data |
| Grain | Critical with joins and aggregation |

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — practical MySQL view examples
- [`practice.sql`](./practice.sql) — focused exercises without answers
