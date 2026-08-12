# 10 — Aggregate Functions

## 📌 Overview

Aggregate functions summarize multiple rows into a single value, or into one value per group when combined with `GROUP BY`.

They are essential for SQL analytics and Data Engineering workloads such as ETL validation, reconciliation, batch profiling, KPI calculation, monitoring, and business reporting.

Core functions:

```text
COUNT()   SUM()   AVG()   MIN()   MAX()
```

---

## 🎯 Learning Objectives

By the end of this topic, you should be able to:

- Understand aggregate functions and their purpose.
- Use `COUNT`, `SUM`, `AVG`, `MIN`, and `MAX`.
- Distinguish `COUNT(*)`, `COUNT(column)`, and `COUNT(DISTINCT column)`.
- Understand `NULL` behavior in aggregates.
- Use aggregates with `WHERE`.
- Build conditional aggregates with `CASE`.
- Aggregate calculated expressions.
- Understand table grain before aggregating.
- Recognize aggregate inflation caused by joins.
- Apply aggregates to ETL validation and reconciliation.
- Understand the difference between row-level and aggregate calculations.
- Prepare for `GROUP BY` and `HAVING`.

---

## 🧠 1. What Is an Aggregate Function?

An aggregate function processes values from multiple rows and returns a summary value.

```sql
SELECT SUM(salary) AS total_salary
FROM employees;
```

Conceptually:

```text
10000
20000
30000
  ↓
 SUM()
  ↓
60000
```

Compare this with a row-level expression:

```sql
SELECT salary * 12 AS annual_salary
FROM employees;
```

The first query produces one summary value; the second produces one result per employee.

---

## 🔢 2. COUNT(*)

`COUNT(*)` counts rows in the input result.

```sql
SELECT COUNT(*) AS employee_count
FROM employees;
```

It counts the row even when nullable columns contain `NULL`.

With filtering:

```sql
SELECT COUNT(*) AS active_employees
FROM employees
WHERE status = 'ACTIVE';
```

`WHERE` filters the rows before the aggregation.

---

## 🔍 3. COUNT(column)

`COUNT(column)` counts only non-NULL values of that expression.

```sql
SELECT COUNT(bonus) AS employees_with_bonus
FROM employees;
```

For:

```text
bonus
-----
5000
NULL
3000
```

```text
COUNT(*)     = 3
COUNT(bonus) = 2
```

This distinction is one of the most common SQL interview questions.

---

## 🧮 4. COUNT(DISTINCT column)

`COUNT(DISTINCT column)` counts unique non-NULL values.

```sql
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM orders;
```

For:

```text
101
101
102
103
103
NULL
```

```text
COUNT(*)                    = 6
COUNT(customer_id)          = 5
COUNT(DISTINCT customer_id) = 3
```

Use it when the business requirement is about unique entities rather than rows or events.

---

## 💰 5. SUM

`SUM()` adds numeric values and ignores NULL inputs.

```sql
SELECT SUM(amount) AS total_revenue
FROM orders;
```

You can aggregate an expression too:

```sql
SELECT SUM(quantity * unit_price) AS gross_sales
FROM order_items;
```

---

## 📊 6. AVG

`AVG()` calculates the average of non-NULL values.

```sql
SELECT AVG(salary) AS average_salary
FROM employees;
```

For:

```text
100
200
NULL
```

The average is `150`, not `100`, because NULL is not treated as zero.

---

## 📉 7. MIN and MAX

`MIN()` returns the smallest non-NULL value and `MAX()` returns the largest non-NULL value.

```sql
SELECT
    MIN(salary) AS minimum_salary,
    MAX(salary) AS maximum_salary
FROM employees;
```

They are also useful for timestamps:

```sql
SELECT
    MIN(event_time) AS first_event,
    MAX(event_time) AS latest_event
FROM events;
```

This is useful for checking the time range of an ingested batch.

---

## 🧩 8. Multiple Aggregates

Multiple metrics can be calculated in one query.

```sql
SELECT
    COUNT(*) AS employee_count,
    SUM(salary) AS total_salary,
    AVG(salary) AS average_salary,
    MIN(salary) AS minimum_salary,
    MAX(salary) AS maximum_salary
FROM employees;
```

Without `GROUP BY`, this normally produces one summary row.

---

## 🔎 9. Aggregates with WHERE

`WHERE` filters rows before aggregation in the logical query-processing model.

```sql
SELECT
    COUNT(*) AS active_count,
    SUM(salary) AS active_salary
FROM employees
WHERE status = 'ACTIVE';
```

Conceptually:

```text
All rows
   ↓
WHERE
   ↓
Filtered rows
   ↓
Aggregate
   ↓
Summary
```

This is different from `HAVING`, which filters aggregate/group results and is covered with `GROUP BY`.

---

## NULL 10. NULL Behavior

Given:

```text
amount
------
100
200
NULL
```

The results are:

| Expression | Result |
|---|---:|
| `COUNT(*)` | 3 |
| `COUNT(amount)` | 2 |
| `COUNT(DISTINCT amount)` | 2 |
| `SUM(amount)` | 300 |
| `AVG(amount)` | 150 |
| `MIN(amount)` | 100 |
| `MAX(amount)` | 200 |

### If every value is NULL

```text
COUNT(*)       = number of rows
COUNT(amount)  = 0
SUM(amount)    = NULL
AVG(amount)    = NULL
MIN(amount)    = NULL
MAX(amount)    = NULL
```

Do not automatically interpret NULL as zero. The correct treatment depends on the business meaning of the column.

---

## 🛡️ 11. COALESCE with Aggregates

Sometimes the business output should be zero instead of NULL.

```sql
SELECT COALESCE(SUM(amount), 0) AS total_amount
FROM orders
WHERE status = 'REFUNDED';
```

Important distinction:

```sql
SUM(amount)
```

already ignores NULL input values.

`COALESCE` here handles the **final aggregate result** when no non-NULL value exists.

---

## 🔀 12. Conditional Aggregation

Conditional aggregation combines business conditions with aggregate functions.

```sql
SELECT
    COUNT(*) AS total_employees,
    SUM(CASE WHEN status = 'ACTIVE' THEN 1 ELSE 0 END) AS active_employees,
    SUM(CASE WHEN status = 'INACTIVE' THEN 1 ELSE 0 END) AS inactive_employees
FROM employees;
```

This is one of the most useful SQL patterns for Data Engineering and analytics.

### Data-quality example

```sql
SELECT
    SUM(CASE WHEN email IS NULL THEN 1 ELSE 0 END) AS null_email_count,
    SUM(CASE WHEN amount < 0 THEN 1 ELSE 0 END) AS invalid_amount_count
FROM orders;
```

---

## 🧮 13. Aggregate Expressions

An aggregate can operate on a calculated expression.

```sql
SELECT
    SUM(quantity * unit_price) AS gross_sales
FROM order_items;
```

For nullable discounts:

```sql
SELECT
    SUM(quantity * (unit_price - COALESCE(discount, 0))) AS net_sales
FROM order_items;
```

The exact formula must match the business definition of the stored discount field.

---

## 🧠 14. Row-Level vs Aggregate Calculation

### Row-level calculation

```sql
SELECT
    quantity * unit_price AS line_total
FROM order_items;
```

One result is produced for each row.

### Aggregate calculation

```sql
SELECT
    SUM(quantity * unit_price) AS total_sales
FROM order_items;
```

The row-level values are summarized into one result.

Remember:

```text
Expression → one result per row
Aggregate  → summary across rows
```

---

## 🏗️ 15. Table Grain

Before calculating an aggregate, ask:

> **What does one row represent?**

Examples:

```text
customers     → one row per customer
orders        → one row per order
order_items   → one row per order item
payments      → one row per payment
```

If the grain changes because of a join, your aggregate may change too.

Understanding grain is essential for preventing incorrect metrics.

---

## 🔗 16. Why JOINs Can Inflate Aggregates

Suppose an order-level amount is joined to multiple order-item rows.

The order amount can appear multiple times in the joined result.

Then:

```sql
SUM(order_amount)
```

may overstate the actual total.

### Interview rule

> Always understand the grain before and after a JOIN before applying `SUM`, `COUNT`, or another aggregate.

If necessary, aggregate one side to the required grain before joining.

---

## 🏭 17. Data Engineering — ETL Row Validation

A basic target validation is:

```sql
SELECT COUNT(*) AS rows_loaded
FROM staging_orders
WHERE batch_id = 20260813;
```

Compare the equivalent source and target metrics using the same batch boundary.

Do not compare counts blindly if the source and target have different grains or filtering rules.

---

## 🔍 18. Data Quality Metrics

Aggregates are useful for automated data-quality checks.

### NULL percentage

```sql
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN email IS NULL THEN 1 ELSE 0 END) AS null_emails
FROM customers;
```

### Unique entities

```sql
SELECT COUNT(DISTINCT customer_id) AS customer_count
FROM orders;
```

### Invalid records

```sql
SELECT SUM(CASE WHEN amount < 0 THEN 1 ELSE 0 END) AS invalid_rows
FROM orders;
```

---

## 📦 19. Batch Profiling

A batch can be profiled using several aggregates:

```sql
SELECT
    COUNT(*) AS row_count,
    COUNT(DISTINCT customer_id) AS customer_count,
    MIN(event_time) AS earliest_event,
    MAX(event_time) AS latest_event,
    SUM(amount) AS total_amount
FROM staging_events
WHERE batch_id = 20260813;
```

This helps answer:

- How many records arrived?
- How many unique entities were affected?
- What time range does the batch cover?
- What is the total value?

---

## 🔄 20. Source-to-Target Reconciliation

A common ETL validation compares metrics on both sides:

```text
Source                    Target
------                    ------
COUNT(*)       ───────→   COUNT(*)
SUM(amount)    ───────→   SUM(amount)
MIN(event_time)────────→  MIN(event_time)
MAX(event_time)────────→  MAX(event_time)
```

Example:

```sql
SELECT
    COUNT(*) AS row_count,
    SUM(amount) AS total_amount
FROM source_orders
WHERE batch_id = 1001;
```

Run the equivalent query against the target.

Matching aggregate metrics are useful evidence, but they do not prove record-level correctness by themselves.

---

## ⚠️ 21. Common Mistakes

### Mistake 1 — Confusing COUNT(*) and COUNT(column)

`COUNT(column)` ignores NULL.

### Mistake 2 — Treating NULL as zero

NULL and zero have different meanings.

### Mistake 3 — Forgetting DISTINCT

Counting transactions is not the same as counting unique customers.

### Mistake 4 — Aggregating after a row-multiplying JOIN

This can inflate totals and counts.

### Mistake 5 — Ignoring table grain

Always determine what one row represents.

### Mistake 6 — Assuming SUM of no qualifying values is zero

`SUM()` can return NULL. Use `COALESCE` when the business result should be zero.

### Mistake 7 — Using WHERE to filter aggregate results

Use `HAVING` for grouped/aggregate filtering.

---

## ⚡ 22. Performance Considerations

For large tables, aggregation cost depends on row count, cardinality, joins, filtering, grouping strategy, and physical design.

Consider:

- Filter unnecessary rows before aggregation when possible.
- Use suitable indexes for selective predicates.
- Avoid accidental row multiplication from joins.
- Aggregate at the correct grain.
- Use `COUNT(DISTINCT ...)` only when uniqueness is actually required.
- Process very large validation workloads by partition or batch where appropriate.
- Inspect the execution plan with `EXPLAIN`.

Do not assume that a syntactically simple aggregate is automatically cheap on a large dataset.

---

## 🎤 23. Interview-Focused Questions

### Q1. What is the difference between `COUNT(*)` and `COUNT(column)`?

<details>
<summary><strong>Answer</strong></summary>

`COUNT(*)` counts rows in the input result. `COUNT(column)` counts only rows where that expression is non-NULL.

</details>

---

### Q2. What is the difference between `COUNT(column)` and `COUNT(DISTINCT column)`?

<details>
<summary><strong>Answer</strong></summary>

`COUNT(column)` counts every non-NULL occurrence. `COUNT(DISTINCT column)` counts unique non-NULL values.

</details>

---

### Q3. How does AVG handle NULL values?

<details>
<summary><strong>Answer</strong></summary>

`AVG` ignores NULL values and calculates the average using only non-NULL inputs. It does not automatically convert NULL to zero.

</details>

---

### Q4. What happens if SUM receives only NULL values?

<details>
<summary><strong>Answer</strong></summary>

`SUM()` returns NULL because there is no non-NULL value to aggregate. If the business output should be zero, use `COALESCE(SUM(amount), 0)`.

</details>

---

### Q5. How would you count active and inactive employees in one query?

<details>
<summary><strong>Answer</strong></summary>

Use conditional aggregation:

```sql
SELECT
    SUM(CASE WHEN status = 'ACTIVE' THEN 1 ELSE 0 END) AS active_count,
    SUM(CASE WHEN status = 'INACTIVE' THEN 1 ELSE 0 END) AS inactive_count
FROM employees;
```

</details>

---

### Q6. How would you calculate total revenue from order items?

<details>
<summary><strong>Answer</strong></summary>

If each row represents an order item, calculate the line value and aggregate it:

```sql
SELECT SUM(quantity * unit_price) AS total_revenue
FROM order_items;
```

</details>

---

### Q7. Why can SUM become incorrect after a JOIN?

<details>
<summary><strong>Answer</strong></summary>

A one-to-many join can duplicate rows from one side. If a value is repeated in the joined result and then summed, the total can be inflated. Always check table grain before and after the join.

</details>

---

### Q8. How would you count unique customers who placed orders?

<details>
<summary><strong>Answer</strong></summary>

Use:

```sql
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM orders;
```

This counts customers rather than order rows.

</details>

---

### Q9. How would you find the number of records containing NULL emails?

<details>
<summary><strong>Answer</strong></summary>

Use conditional aggregation:

```sql
SELECT
    SUM(CASE WHEN email IS NULL THEN 1 ELSE 0 END) AS null_email_count
FROM customers;
```

</details>

---

### Q10. Can aggregate functions normally be used in WHERE?

<details>
<summary><strong>Answer</strong></summary>

No. `WHERE` filters input rows before aggregation. Aggregate results are filtered with `HAVING`, which is covered with `GROUP BY`.

</details>

---

### Q11. Why is table grain important before using SUM?

<details>
<summary><strong>Answer</strong></summary>

Grain defines what one row represents. If a customer-level metric becomes duplicated after a join to multiple child rows, summing it afterward can double-count the metric. Correct aggregation requires knowing the grain.

</details>

---

### Q12. How would you validate source and target row counts after an ETL load?

<details>
<summary><strong>Answer</strong></summary>

Run `COUNT(*)` against both source and target using the same batch or partition boundary, then compare the results. Ensure the two queries use equivalent filtering rules and the same logical grain.

</details>

---

### Q13. How would you calculate the total and average order value for a batch?

<details>
<summary><strong>Answer</strong></summary>

Use multiple aggregates in one query:

```sql
SELECT
    SUM(amount) AS total_amount,
    AVG(amount) AS average_amount
FROM orders
WHERE batch_id = 1001;
```

</details>

---

### Q14. How would you build a simple data-quality summary for an ingestion batch?

<details>
<summary><strong>Answer</strong></summary>

Combine row counts, distinct counts, NULL counts, invalid-value counts, and time boundaries:

```sql
SELECT
    COUNT(*) AS row_count,
    COUNT(DISTINCT customer_id) AS customer_count,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_count,
    SUM(CASE WHEN amount < 0 THEN 1 ELSE 0 END) AS invalid_amount_count,
    MIN(event_time) AS min_event_time,
    MAX(event_time) AS max_event_time
FROM staging_events
WHERE batch_id = 1001;
```

</details>

---

## 🔄 24. Quick Revision

| Function / Concept | Key Point |
|---|---|
| `COUNT(*)` | Counts rows |
| `COUNT(column)` | Counts non-NULL values |
| `COUNT(DISTINCT column)` | Counts unique non-NULL values |
| `SUM()` | Adds numeric values |
| `AVG()` | Average of non-NULL values |
| `MIN()` | Minimum value |
| `MAX()` | Maximum value |
| `CASE` + aggregate | Conditional aggregation |
| Grain | Defines what one row represents |
| `WHERE` | Filters rows before aggregation |
| `HAVING` | Filters aggregate/group results |
| Reconciliation | Compares source and target metrics |

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — worked examples for MySQL aggregate functions
- [`practice.sql`](./practice.sql) — hands-on exercises, validation scenarios, and interview practice
