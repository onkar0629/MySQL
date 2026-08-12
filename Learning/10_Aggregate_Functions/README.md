# 10 — Aggregate Functions

## 📌 Overview

Aggregate functions calculate a single summary value from multiple rows. They are fundamental for reporting, analytics, ETL validation, and Data Engineering SQL.

## 🎯 Learning Objectives

- Understand `COUNT`, `SUM`, `AVG`, `MIN`, and `MAX`
- Distinguish `COUNT(*)`, `COUNT(column)`, and `COUNT(DISTINCT column)`
- Understand how aggregates treat `NULL`
- Combine aggregate functions with `WHERE`
- Understand the difference between row-level and aggregate calculations
- Prepare for `GROUP BY` and `HAVING`
- Apply aggregates to Data Engineering scenarios

## 1. COUNT

Count all rows:

```sql
SELECT COUNT(*) AS employee_count
FROM employees;
```

`COUNT(column)` counts only non-NULL values:

```sql
SELECT COUNT(bonus) AS employees_with_bonus
FROM employees;
```

Distinct values:

```sql
SELECT COUNT(DISTINCT department) AS department_count
FROM employees;
```

## 2. SUM

```sql
SELECT SUM(salary) AS total_salary
FROM employees;
```

`SUM` ignores NULL values.

## 3. AVG

```sql
SELECT AVG(salary) AS average_salary
FROM employees;
```

`AVG` is calculated over non-NULL values. It is not the same as treating NULL as zero.

## 4. MIN and MAX

```sql
SELECT MIN(salary) AS minimum_salary,
       MAX(salary) AS maximum_salary
FROM employees;
```

## 5. Multiple Aggregates

```sql
SELECT COUNT(*) AS employee_count,
       SUM(salary) AS total_salary,
       AVG(salary) AS average_salary,
       MIN(salary) AS minimum_salary,
       MAX(salary) AS maximum_salary
FROM employees;
```

## 6. Aggregates with WHERE

`WHERE` filters rows before the aggregate is calculated.

```sql
SELECT SUM(salary) AS active_salary
FROM employees
WHERE status = 'active';
```

## 7. NULL Behavior

Given values `100, 200, NULL`:

- `COUNT(*)` = 3
- `COUNT(amount)` = 2
- `SUM(amount)` = 300
- `AVG(amount)` = 150
- `MIN(amount)` = 100
- `MAX(amount)` = 200

If all values are NULL, `SUM`, `AVG`, `MIN`, and `MAX` return `NULL`, while `COUNT(column)` returns `0`.

## 8. Conditional Aggregation

Use `CASE` inside an aggregate to calculate business metrics.

```sql
SELECT
    COUNT(*) AS total_employees,
    SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) AS active_employees,
    SUM(CASE WHEN salary >= 100000 THEN 1 ELSE 0 END) AS high_salary_employees
FROM employees;
```

## 9. Distinct Aggregation

```sql
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM orders;
```

This is useful when multiple rows can belong to the same business entity.

## 10. Aggregate Expressions

```sql
SELECT SUM(quantity * unit_price) AS gross_sales
FROM order_items;
```

For nullable values, make the business rule explicit:

```sql
SELECT SUM(quantity * (unit_price - COALESCE(discount, 0))) AS net_sales
FROM order_items;
```

## 11. Aggregates in Data Engineering

Common uses include:

- Row-count validation after an ETL load
- Total revenue reconciliation
- Distinct customer counts
- Minimum and maximum event timestamps
- Detecting unexpected NULLs
- Batch-level quality checks
- Comparing source and target record counts

Example:

```sql
SELECT COUNT(*) AS rows_loaded,
       MIN(loaded_at) AS first_loaded_at,
       MAX(loaded_at) AS last_loaded_at
FROM staging_events;
```

## 12. Aggregate Functions vs GROUP BY

Without `GROUP BY`, an aggregate normally returns one summary row for the filtered input.

```sql
SELECT SUM(salary)
FROM employees;
```

With `GROUP BY`, each group receives its own aggregate result. `GROUP BY` is covered in the next topic.

## 13. Common Mistakes

- Confusing `COUNT(*)` with `COUNT(column)`
- Assuming NULL is counted by `COUNT(column)`
- Treating NULL as zero without an explicit business rule
- Using `AVG` when NULL should represent a real zero
- Forgetting that `WHERE` filters rows before aggregation
- Counting rows when the requirement is counting distinct entities
- Multiplying rows incorrectly after joins and inflating `SUM`

## 14. Interview-Focused Questions

### Q1. What is the difference between `COUNT(*)` and `COUNT(column)`?

<details>
<summary><strong>Answer</strong></summary>

`COUNT(*)` counts rows, including rows where individual columns are NULL. `COUNT(column)` counts only rows where that column is non-NULL.

</details>

---

### Q2. How does `COUNT(DISTINCT customer_id)` differ from `COUNT(customer_id)`?

<details>
<summary><strong>Answer</strong></summary>

`COUNT(customer_id)` counts every non-NULL occurrence. `COUNT(DISTINCT customer_id)` counts unique non-NULL customer IDs.

</details>

---

### Q3. Do aggregate functions ignore NULL values?

<details>
<summary><strong>Answer</strong></summary>

For `SUM`, `AVG`, `MIN`, `MAX`, and `COUNT(column)`, NULL values are ignored. `COUNT(*)` counts the row regardless of NULL values.

</details>

---

### Q4. What does AVG do when some values are NULL?

<details>
<summary><strong>Answer</strong></summary>

`AVG` ignores NULL values and divides by the number of non-NULL values. It does not automatically treat NULL as zero.

</details>

---

### Q5. What is the difference between SUM(amount) and SUM(COALESCE(amount, 0))?

<details>
<summary><strong>Answer</strong></summary>

For a normal SUM, NULL values are already ignored. `COALESCE` becomes important when the expression itself can become NULL or when the business rule explicitly defines missing values as zero.

</details>

---

### Q6. How would you count active and inactive customers in one query?

<details>
<summary><strong>Answer</strong></summary>

Use conditional aggregation, for example `SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END)` for active customers and a similar expression for inactive customers.

</details>

---

### Q7. Why can SUM become incorrect after a JOIN?

<details>
<summary><strong>Answer</strong></summary>

A one-to-many join can duplicate rows from the parent table. Aggregating after that join can multiply values. The join grain must be understood before calculating metrics.

</details>

---

### Q8. What happens when SUM, AVG, MIN, or MAX receives only NULL values?

<details>
<summary><strong>Answer</strong></summary>

They return NULL because there is no non-NULL value from which to calculate the result.

</details>

---

### Q9. How would you validate that a target table received the expected number of records?

<details>
<summary><strong>Answer</strong></summary>

Use `COUNT(*)` on the source and target at the same defined batch or partition boundary, then compare the counts. The validation should use the same filtering logic and data grain on both sides.

</details>

---

### Q10. Can an aggregate function be used in WHERE?

<details>
<summary><strong>Answer</strong></summary>

Normally no. `WHERE` operates before aggregation. Aggregate results are filtered with `HAVING`, which is covered in the next topic.

</details>

## 15. Quick Revision

| Function | Purpose |
|---|---|
| `COUNT(*)` | Counts rows |
| `COUNT(column)` | Counts non-NULL values |
| `COUNT(DISTINCT column)` | Counts unique non-NULL values |
| `SUM()` | Adds numeric values |
| `AVG()` | Calculates average of non-NULL values |
| `MIN()` | Finds minimum |
| `MAX()` | Finds maximum |
| `CASE` + aggregate | Conditional aggregation |

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — worked examples for MySQL aggregate functions
- [`practice.sql`](./practice.sql) — hands-on exercises and interview practice
