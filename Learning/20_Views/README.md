# 20 — Views

## 📌 Overview

A **view** is a named SQL query that can be queried like a table. Views are useful for reusable business logic, abstraction, security, and consistent access to derived data.

For Data Engineering, understand views as a logical layer—not automatically as stored data.

## 🎯 Learning Objectives

- Create, query, replace, and drop views.
- Understand how a view differs from a table and CTE.
- Use views for reusable transformations.
- Understand view security and column exposure.
- Understand updatable vs non-updatable views.
- Recognize limitations of views.
- Avoid hiding expensive logic behind frequently queried views.

## 1. Create a View

```sql
CREATE VIEW active_customers AS
SELECT customer_id, customer_name, email
FROM customers
WHERE status = 'ACTIVE';
```

Query it like a table:

```sql
SELECT *
FROM active_customers;
```

## 2. Replace a View

```sql
CREATE OR REPLACE VIEW active_customers AS
SELECT customer_id, customer_name, email, created_at
FROM customers
WHERE status = 'ACTIVE';
```

## 3. Drop a View

```sql
DROP VIEW IF EXISTS active_customers;
```

## 4. View vs Table

| View | Table |
|---|---|
| Stores a query definition | Stores table data |
| Usually does not store result rows | Stores rows physically |
| Reflects underlying data when queried | Data changes through DML |
| Useful for abstraction | Used for persistent storage |

A normal view should not be assumed to materialize its result.

## 5. View vs CTE

A CTE normally exists only for one statement:

```sql
WITH active_customers AS (
    SELECT * FROM customers WHERE status = 'ACTIVE'
)
SELECT * FROM active_customers;
```

A view is a persistent database object that can be reused by multiple statements.

Use a **CTE** for query-local organization. Use a **view** when a reusable database-level interface is appropriate.

## 6. Views with Joins and Aggregation

```sql
CREATE VIEW customer_order_summary AS
SELECT
    customer_id,
    COUNT(*) AS order_count,
    SUM(amount) AS total_spend
FROM orders
GROUP BY customer_id;
```

This can provide a stable reporting interface while keeping the underlying transformation hidden from consumers.

## 7. Security and Column Exposure

A view can expose only the columns consumers need:

```sql
CREATE VIEW employee_directory AS
SELECT
    employee_id,
    employee_name,
    department_id
FROM employees;
```

This can reduce direct exposure of sensitive columns, but a view is **not a complete security model by itself**. Privileges must be configured correctly.

## 8. Updatable Views

Some simple views can be updatable, depending on their definition and MySQL's rules.

Views involving constructs such as aggregation, `DISTINCT`, grouping, and certain joins generally have restrictions and may not be directly updatable.

Always verify the specific view definition rather than assuming every view supports `INSERT`, `UPDATE`, or `DELETE`.

## 9. Views and Data Engineering

Useful cases include:

- Standardized reporting layers
- Reusable business definitions
- Source-system abstraction
- Simplifying downstream queries
- Restricting exposed columns
- Creating stable interfaces for analysts

Example:

```sql
CREATE VIEW daily_sales AS
SELECT
    order_date,
    COUNT(*) AS order_count,
    SUM(amount) AS total_sales
FROM orders
GROUP BY order_date;
```

## 10. Performance Considerations

A view does not automatically make a complex query faster. When a consumer queries a normal view, MySQL still has to execute the underlying logic as part of producing the result.

Watch for:

- Expensive joins
- Large aggregations
- Non-sargable filters
- Repeated scans
- Deeply nested views

Use `EXPLAIN` on the consuming query when performance matters.

## 11. Common Mistakes

- Assuming a normal view stores query results.
- Treating a view as automatically faster than the underlying query.
- Hiding overly complex transformations inside layers of views.
- Exposing sensitive columns unnecessarily.
- Assuming every view is updatable.
- Forgetting that changing underlying tables can affect a view.
- Using `SELECT *` in long-lived interfaces when schema stability matters.

## 🎤 Interview-Focused Questions

### Q1. What is a view?

<details>
<summary><strong>Answer</strong></summary>

A view is a named database object containing a query definition that can be queried like a table. A normal view does not automatically store a separate copy of its result data.
</details>

### Q2. What is the difference between a view and a CTE?

<details>
<summary><strong>Answer</strong></summary>

A CTE is normally scoped to one SQL statement, while a view is a persistent database object reusable across statements.
</details>

### Q3. Does a normal view store data?

<details>
<summary><strong>Answer</strong></summary>

Normally no. It stores the query definition. The underlying query is used when the view is queried.
</details>

### Q4. Why use a view in a Data Engineering environment?

<details>
<summary><strong>Answer</strong></summary>

Views can provide reusable business logic, standardized reporting interfaces, source abstraction, and controlled column exposure.
</details>

### Q5. Are all views updatable?

<details>
<summary><strong>Answer</strong></summary>

No. Updatability depends on the view definition. Aggregation, grouping, `DISTINCT`, and other constructs can prevent direct updates.
</details>

### Q6. Does creating a view improve query performance?

<details>
<summary><strong>Answer</strong></summary>

Not inherently. A normal view is primarily an abstraction and reuse mechanism. Its underlying query still needs to be executed when producing results.
</details>

### Q7. How can a view improve security?

<details>
<summary><strong>Answer</strong></summary>

A view can expose only approved columns or rows, allowing consumers to query a controlled interface instead of the base table. Database privileges must still be configured correctly.
</details>

### Q8. How do you replace an existing view?

<details>
<summary><strong>Answer</strong></summary>

Use `CREATE OR REPLACE VIEW` with the new query definition.
</details>

## 🔄 Quick Revision

| Concept | Key Point |
|---|---|
| View | Named reusable query |
| Normal view | Does not normally materialize result data |
| CTE | Query-local temporary named result |
| Security | Can restrict exposed rows/columns |
| Updatable | Depends on view definition |
| Performance | Not automatically faster |
| `EXPLAIN` | Check underlying query performance |

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — practical MySQL view examples
- [`practice.sql`](./practice.sql) — exercises without answers
