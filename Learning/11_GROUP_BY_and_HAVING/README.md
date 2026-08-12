# 11 — GROUP BY and HAVING

## 📌 Overview

`GROUP BY` combines rows into groups so aggregate functions can calculate metrics per group. `HAVING` filters those grouped results after aggregation.

## 🎯 Learning Objectives

- Group rows by one or more columns
- Use aggregate functions with `GROUP BY`
- Understand `WHERE` vs `HAVING`
- Filter groups with aggregate conditions
- Group by expressions
- Handle `NULL` values in grouped data
- Use multiple grouping columns
- Understand grouping grain
- Apply grouping to Data Engineering scenarios
- Avoid incorrect aggregates caused by joins

## 1. Basic GROUP BY

```sql
SELECT department, COUNT(*) AS employee_count
FROM employees
GROUP BY department;
```

Each distinct department becomes one result group.

## 2. GROUP BY with Multiple Aggregates

```sql
SELECT
    department,
    COUNT(*) AS employee_count,
    AVG(salary) AS avg_salary,
    MIN(salary) AS min_salary,
    MAX(salary) AS max_salary
FROM employees
GROUP BY department;
```

## 3. GROUP BY Multiple Columns

```sql
SELECT department, job_title, COUNT(*) AS employee_count
FROM employees
GROUP BY department, job_title;
```

The grouping grain is `(department, job_title)`.

## 4. WHERE vs HAVING

`WHERE` filters individual rows before grouping.

`HAVING` filters groups after aggregation.

```sql
SELECT department, COUNT(*) AS employee_count
FROM employees
WHERE salary >= 50000
GROUP BY department
HAVING COUNT(*) >= 3;
```

Conceptually:

`FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY → LIMIT`

## 5. HAVING with SUM and AVG

```sql
SELECT customer_id, SUM(amount) AS total_spend
FROM orders
GROUP BY customer_id
HAVING SUM(amount) > 10000;
```

## 6. Grouping by an Expression

```sql
SELECT
    YEAR(order_date) AS order_year,
    COUNT(*) AS order_count
FROM orders
GROUP BY YEAR(order_date);
```

## 7. NULL Groups

`NULL` values are grouped together.

```sql
SELECT department, COUNT(*) AS employee_count
FROM employees
GROUP BY department;
```

If several rows have `department = NULL`, they belong to the same group.

## 8. COUNT(*) vs COUNT(column)

```sql
SELECT
    department,
    COUNT(*) AS rows_in_group,
    COUNT(manager_id) AS rows_with_manager
FROM employees
GROUP BY department;
```

`COUNT(*)` counts rows. `COUNT(column)` ignores NULL values in that column.

## 9. Conditional Aggregation

```sql
SELECT
    department,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN salary >= 100000 THEN 1 ELSE 0 END) AS high_earners
FROM employees
GROUP BY department;
```

## 10. Data Engineering Pattern — Batch Validation

```sql
SELECT batch_id, COUNT(*) AS row_count
FROM staging_events
GROUP BY batch_id
HAVING COUNT(*) = 0;
```

For a real table, a missing batch normally produces no group, so expected batch IDs should be compared against the grouped result when checking for completely missing batches.

## 11. Data Engineering Pattern — Duplicate Detection

```sql
SELECT customer_email, COUNT(*) AS duplicate_count
FROM customers
GROUP BY customer_email
HAVING COUNT(*) > 1;
```

## 12. Data Engineering Pattern — Reconciliation

```sql
SELECT order_date, SUM(amount) AS source_total
FROM source_orders
GROUP BY order_date;
```

The result can be compared with a target aggregation by the same business grain.

## 13. Common Mistakes

- Using `WHERE COUNT(*) > 1` instead of `HAVING COUNT(*) > 1`
- Forgetting a non-aggregated selected column in the grouping logic
- Grouping at the wrong business grain
- Assuming `COUNT(column)` counts NULLs
- Joining tables before aggregation without checking row multiplication
- Using `HAVING` for simple row-level filters that belong in `WHERE`
- Comparing aggregate results built at different grains

## 14. Interview-Focused Questions

### Q1. What is the difference between WHERE and HAVING?

<details>
<summary><strong>Answer</strong></summary>

`WHERE` filters rows before grouping and aggregation. `HAVING` filters groups after aggregation. Use `WHERE` for row-level conditions and `HAVING` for aggregate/group-level conditions.

</details>

---

### Q2. Can HAVING be used without GROUP BY?

<details>
<summary><strong>Answer</strong></summary>

Yes. The result can be treated as a single group when aggregate expressions are used. For example, `SELECT COUNT(*) FROM orders HAVING COUNT(*) > 100` can filter the single aggregate result.

</details>

---

### Q3. Why does COUNT(column) sometimes return a smaller value than COUNT(*)?

<details>
<summary><strong>Answer</strong></summary>

`COUNT(*)` counts every row, while `COUNT(column)` counts only rows where that column is not NULL.

</details>

---

### Q4. How would you find customers with more than three orders?

<details>
<summary><strong>Answer</strong></summary>

Group by `customer_id` and filter the aggregate with `HAVING COUNT(*) > 3`.

</details>

---

### Q5. What is the grain of a GROUP BY query?

<details>
<summary><strong>Answer</strong></summary>

The grain is what one output row represents. For `GROUP BY customer_id, order_month`, one row represents one customer in one month.

</details>

---

### Q6. Why can a JOIN produce an incorrect SUM before GROUP BY?

<details>
<summary><strong>Answer</strong></summary>

If the join creates multiple rows for the same business entity, measures can be duplicated before aggregation. Always understand join cardinality and aggregate at the correct grain.

</details>

---

### Q7. Can you use an aggregate function in WHERE?

<details>
<summary><strong>Answer</strong></summary>

Normally no. Aggregates are evaluated after row filtering, so aggregate conditions belong in `HAVING` or an outer query.

</details>

---

### Q8. How do you find duplicate values using GROUP BY?

<details>
<summary><strong>Answer</strong></summary>

Group by the column that should be unique and use `HAVING COUNT(*) > 1`.

</details>

---

### Q9. Why is GROUP BY important in Data Engineering?

<details>
<summary><strong>Answer</strong></summary>

It is fundamental for aggregating events into business metrics such as daily sales, customer totals, batch counts, reconciliation totals, and data-quality checks.

</details>

---

### Q10. How would you find departments whose average salary is above 80000?

<details>
<summary><strong>Answer</strong></summary>

Group by department and use `HAVING AVG(salary) > 80000`.

</details>

## 15. Quick Revision

| Concept | Key Point |
|---|---|
| `GROUP BY` | Creates groups for aggregation |
| `HAVING` | Filters groups |
| `WHERE` | Filters rows before grouping |
| `COUNT(*)` | Counts all rows |
| `COUNT(column)` | Ignores NULL values |
| Multiple columns | Defines a more specific grouping grain |
| `HAVING COUNT(*)` | Common pattern for duplicate/group filtering |
| Conditional aggregation | Uses `CASE` inside aggregates |
| Group grain | Defines what one result row represents |

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — worked examples for GROUP BY and HAVING in MySQL
- [`practice.sql`](./practice.sql) — hands-on exercises and interview practice
