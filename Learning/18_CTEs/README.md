# 18 — CTEs

## 📌 Overview

A **Common Table Expression (CTE)** is a named temporary result set defined with `WITH` and used by one SQL statement.

CTEs are especially useful when a query has multiple logical steps. They improve readability, make transformations easier to test, and allow recursive queries when hierarchical data requires them.

```sql
WITH active_customers AS (
    SELECT customer_id
    FROM customers
    WHERE status = 'ACTIVE'
)
SELECT *
FROM active_customers;
```

---

## 🎯 Learning Objectives

- Understand CTE syntax and scope.
- Build single and multiple CTEs.
- Chain CTEs for multi-step transformations.
- Use CTEs with joins and aggregation.
- Understand CTEs vs subqueries vs derived tables.
- Understand recursive CTEs.
- Use recursive CTEs for hierarchies and sequences.
- Understand CTE materialization/optimizer behavior at a practical level.
- Avoid common CTE mistakes.
- Apply CTEs to Data Engineering transformations.

---

## 1. Basic CTE

```sql
WITH high_value_orders AS (
    SELECT order_id, customer_id, amount
    FROM orders
    WHERE amount >= 10000
)
SELECT *
FROM high_value_orders;
```

The CTE exists only for the statement that follows it.

---

## 2. CTE with Aggregation

```sql
WITH customer_sales AS (
    SELECT
        customer_id,
        SUM(amount) AS total_sales
    FROM orders
    GROUP BY customer_id
)
SELECT
    customer_id,
    total_sales
FROM customer_sales
WHERE total_sales >= 100000;
```

This separates aggregation from filtering and makes the business logic easier to read.

---

## 3. Multiple CTEs

CTEs can be chained:

```sql
WITH customer_sales AS (
    SELECT customer_id, SUM(amount) AS total_sales
    FROM orders
    GROUP BY customer_id
),
ranked_customers AS (
    SELECT
        customer_id,
        total_sales,
        RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
    FROM customer_sales
)
SELECT *
FROM ranked_customers
WHERE sales_rank <= 10;
```

Each CTE can consume a previous CTE.

---

## 4. CTE vs Subquery

Both can express the same logic.

Subquery:

```sql
SELECT *
FROM (
    SELECT customer_id, SUM(amount) AS total_sales
    FROM orders
    GROUP BY customer_id
) s
WHERE total_sales > 100000;
```

CTE:

```sql
WITH customer_sales AS (
    SELECT customer_id, SUM(amount) AS total_sales
    FROM orders
    GROUP BY customer_id
)
SELECT *
FROM customer_sales
WHERE total_sales > 100000;
```

For multi-step SQL, CTEs are generally easier to read and maintain.

---

## 5. CTE vs Temporary Table

A CTE:

- Exists only for one statement.
- Does not create a persistent table object.
- Is convenient for query structure.

A temporary table:

- Can be referenced by multiple statements during its session.
- Can be indexed explicitly.
- Can be useful when an intermediate result must be reused across separate statements or needs materialization under your control.

Do not choose a CTE merely because it looks cleaner; choose based on execution and reuse requirements.

---

## 6. Data Engineering Pattern — Staging Transformation

A useful pattern is to separate extraction, cleansing, and business logic:

```sql
WITH cleaned_orders AS (
    SELECT
        order_id,
        customer_id,
        amount,
        TRIM(status) AS status
    FROM staging_orders
),
valid_orders AS (
    SELECT *
    FROM cleaned_orders
    WHERE order_id IS NOT NULL
      AND amount >= 0
)
SELECT
    customer_id,
    SUM(amount) AS total_amount
FROM valid_orders
GROUP BY customer_id;
```

This makes each transformation step independently understandable.

---

## 7. Recursive CTE

A recursive CTE references itself and is useful for hierarchical data.

Basic structure:

```sql
WITH RECURSIVE hierarchy AS (
    -- Anchor member
    SELECT employee_id, manager_id, employee_name, 0 AS level
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive member
    SELECT
        e.employee_id,
        e.manager_id,
        e.employee_name,
        h.level + 1
    FROM employees e
    JOIN hierarchy h
      ON e.manager_id = h.employee_id
)
SELECT *
FROM hierarchy;
```

A recursive CTE has two logical parts:

```text
Anchor query
     ↓
UNION ALL
     ↓
Recursive query
     ↓
repeat until no new rows qualify
```

---

## 8. Sequence Generation

Recursive CTEs can generate a sequence:

```sql
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM numbers
    WHERE n < 10
)
SELECT n
FROM numbers;
```

Use recursion deliberately. For large ranges, a permanent numbers/calendar table can be a better design.

---

## 9. Recursive CTE Safety

Always ensure the recursive member moves toward termination.

Bad recursion can continue until MySQL's recursion limit is reached or consume excessive resources.

Typical controls include:

- A clear termination predicate.
- `UNION ALL` with a decreasing/advancing condition.
- Appropriate recursion depth limits.
- Testing with small data first.

---

## 10. CTEs and Window Functions

CTEs are particularly useful for separating window calculations from later filtering.

```sql
WITH ranked_orders AS (
    SELECT
        order_id,
        customer_id,
        amount,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY amount DESC, order_id
        ) AS rn
    FROM orders
)
SELECT *
FROM ranked_orders
WHERE rn = 1;
```

This pattern is common for top-1-per-group problems.

---

## 11. CTEs and Deduplication

```sql
WITH ranked_records AS (
    SELECT
        customer_id,
        updated_at,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY updated_at DESC
        ) AS rn
    FROM staging_customers
)
SELECT *
FROM ranked_records
WHERE rn = 1;
```

The CTE isolates the ranking step before applying the final filter.

---

## 12. CTEs and ETL Reconciliation

```sql
WITH source_metrics AS (
    SELECT
        COUNT(*) AS row_count,
        SUM(amount) AS total_amount
    FROM source_orders
    WHERE batch_id = 1001
),
target_metrics AS (
    SELECT
        COUNT(*) AS row_count,
        SUM(amount) AS total_amount
    FROM target_orders
    WHERE batch_id = 1001
)
SELECT
    source_metrics.row_count AS source_rows,
    target_metrics.row_count AS target_rows,
    source_metrics.total_amount AS source_amount,
    target_metrics.total_amount AS target_amount
FROM source_metrics
CROSS JOIN target_metrics;
```

This creates a single comparison result for pipeline validation.

---

## 13. CTE Scope

A CTE is available only to the statement immediately following the `WITH` clause.

```sql
WITH x AS (
    SELECT 1 AS value
)
SELECT * FROM x;
```

A second statement cannot automatically reference `x`.

If the result must survive across statements, consider a temporary table or persistent table.

---

## 14. Performance Reality

A CTE is primarily a **query-organization construct**. Do not assume that creating a CTE automatically makes a query faster.

Performance depends on the optimizer, data volume, joins, indexes, cardinality, and whether an intermediate result is materialized or merged into the surrounding query plan.

Use:

```sql
EXPLAIN
WITH ...
SELECT ...;
```

and measure the actual plan.

For repeated use across separate statements, a temporary table may be more appropriate.

---

## ⚠️ Common Mistakes

- Treating a CTE as a permanent table.
- Assuming a CTE automatically improves performance.
- Creating many unnecessary CTE layers.
- Ignoring the grain of each CTE.
- Forgetting that a join inside a CTE can multiply rows.
- Writing recursive CTEs without a termination condition.
- Using recursion for problems better solved with a calendar/numbers table.
- Filtering a window-function result in the same query block instead of using an outer query/CTE.

---

## 🎤 Interview-Focused Questions

### Q1. What is a CTE?

<details>
<summary><strong>Answer</strong></summary>

A CTE is a named temporary result set defined with `WITH` and available to the single SQL statement that follows it. It is mainly used to structure complex queries and can also support recursive processing.
</details>

### Q2. CTE vs subquery?

<details>
<summary><strong>Answer</strong></summary>

Both can represent intermediate results. CTEs are usually easier to read and reuse within a single statement, especially when there are multiple logical stages. Performance should be verified rather than assumed from syntax.
</details>

### Q3. Can a CTE be referenced more than once?

<details>
<summary><strong>Answer</strong></summary>

Yes, within the statement in which it is defined. Whether MySQL materializes or merges the CTE is an optimizer concern and should not be assumed without checking the execution plan.
</details>

### Q4. What is a recursive CTE?

<details>
<summary><strong>Answer</strong></summary>

A recursive CTE contains an anchor query and a recursive query that references the CTE itself. It is useful for hierarchical structures such as employee-manager relationships.
</details>

### Q5. Why use UNION ALL in recursive CTEs?

<details>
<summary><strong>Answer</strong></summary>

Recursive CTEs normally use `UNION ALL` to combine the anchor and recursive members without unnecessary duplicate elimination at every iteration. The recursive logic must still prevent unwanted duplicate paths or cycles where relevant.
</details>

### Q6. How do you filter a ROW_NUMBER() result using a CTE?

<details>
<summary><strong>Answer</strong></summary>

Calculate `ROW_NUMBER()` inside the CTE, then filter it in the outer query. This is useful for top-N-per-group and deduplication problems.
</details>

### Q7. Does a CTE always improve performance?

<details>
<summary><strong>Answer</strong></summary>

No. A CTE primarily improves query organization. The optimizer determines the physical execution strategy. Use `EXPLAIN` and actual workload measurements to evaluate performance.
</details>

### Q8. CTE vs temporary table?

<details>
<summary><strong>Answer</strong></summary>

A CTE exists for one statement. A temporary table can be reused across multiple statements in a session and can be explicitly indexed. Temporary tables are useful when controlled materialization or repeated reuse is required.
</details>

### Q9. What is the most important safety rule for recursive CTEs?

<details>
<summary><strong>Answer</strong></summary>

Ensure the recursive member has a reliable termination condition and cannot endlessly revisit the same hierarchy. Test recursion on representative data and control recursion depth where appropriate.
</details>

### Q10. How can CTEs help Data Engineers?

<details>
<summary><strong>Answer</strong></summary>

They allow complex ETL transformations to be expressed as readable stages such as cleansing, validation, deduplication, aggregation, ranking, and reconciliation within one SQL statement.
</details>

## 🔄 Quick Revision

| Concept | Key Point |
|---|---|
| CTE | Named result set for one statement |
| `WITH` | Defines a CTE |
| Multiple CTEs | Allows staged transformations |
| Recursive CTE | Handles hierarchical/iterative logic |
| Anchor | Starting rows of recursion |
| Recursive member | Generates subsequent rows |
| CTE vs subquery | Mainly readability/structure difference |
| CTE vs temp table | Temp table survives across statements |
| Window + CTE | Useful for filtering ranked results |
| `EXPLAIN` | Verify actual execution plan |

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — practical CTE and recursive CTE examples
- [`practice.sql`](./practice.sql) — exercises without answers
