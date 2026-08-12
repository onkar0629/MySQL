# 21 — Window Functions

## 📌 Overview

Window functions calculate a value across a related set of rows **without collapsing those rows into one row per group**.

This is one of the most important advanced SQL topics for Data Engineering interviews. The key idea is:

```text
GROUP BY        → reduces rows
WINDOW FUNCTION → keeps rows and adds calculations
```

Common uses include ranking, deduplication, previous/next-row comparisons, running totals, top-N per group, and time-series analysis.

## 🎯 Learning Objectives

- Understand `OVER()`.
- Use `PARTITION BY` and `ORDER BY` correctly.
- Use `ROW_NUMBER()`, `RANK()`, and `DENSE_RANK()`.
- Use `LAG()` and `LEAD()`.
- Understand window frames and running calculations.
- Build top-N-per-group and deduplication queries.
- Compare window functions with `GROUP BY` and self-joins.
- Avoid common ranking and frame mistakes.
- Apply window functions to Data Engineering scenarios.

## 1. Basic Window Function

```sql
SELECT
    employee_id,
    department_id,
    salary,
    AVG(salary) OVER () AS company_avg_salary
FROM employees;
```

Every employee remains in the result, while the company average is added to each row.

## 2. PARTITION BY

`PARTITION BY` creates independent windows.

```sql
SELECT
    employee_id,
    department_id,
    salary,
    AVG(salary) OVER (
        PARTITION BY department_id
    ) AS department_avg_salary
FROM employees;
```

This calculates one average per department without collapsing employee rows.

## 3. ORDER BY Inside a Window

```sql
SELECT
    employee_id,
    salary,
    ROW_NUMBER() OVER (
        ORDER BY salary DESC, employee_id
    ) AS salary_rank
FROM employees;
```

The `ORDER BY` inside `OVER()` controls the window calculation. It is separate from the query's final `ORDER BY`.

## 4. ROW_NUMBER vs RANK vs DENSE_RANK

Suppose salaries are:

```text
100
100
90
```

Results:

| Salary | ROW_NUMBER | RANK | DENSE_RANK |
|---:|---:|---:|---:|
| 100 | 1 | 1 | 1 |
| 100 | 2 | 1 | 1 |
| 90 | 3 | 3 | 2 |

Use:

- `ROW_NUMBER()` when every row needs a unique sequence.
- `RANK()` when ties share a rank and gaps should remain.
- `DENSE_RANK()` when ties share a rank but gaps should not remain.

## 5. Deterministic ROW_NUMBER

If the ordering column is not unique, add a stable tie-breaker:

```sql
ROW_NUMBER() OVER (
    PARTITION BY customer_id
    ORDER BY order_date DESC, order_id DESC
)
```

This is important for reproducible deduplication and latest-record logic.

## 6. Top-N Per Group

Find the two highest-paid employees in every department:

```sql
WITH ranked AS (
    SELECT
        employee_id,
        department_id,
        salary,
        ROW_NUMBER() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC, employee_id
        ) AS rn
    FROM employees
)
SELECT *
FROM ranked
WHERE rn <= 2;
```

A window function is needed because `GROUP BY` alone cannot return the complete top rows from each group.

## 7. Deduplication

Keep the latest record for each business key:

```sql
WITH ranked AS (
    SELECT
        t.*,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY updated_at DESC, record_id DESC
        ) AS rn
    FROM staging_customer t
)
SELECT *
FROM ranked
WHERE rn = 1;
```

This is a common ETL/ELT pattern.

## 8. LAG

`LAG()` accesses a previous row in the window.

```sql
SELECT
    order_date,
    sales,
    LAG(sales) OVER (
        ORDER BY order_date
    ) AS previous_day_sales
FROM daily_sales;
```

Calculate the change:

```sql
sales - LAG(sales) OVER (ORDER BY order_date)
```

## 9. LEAD

`LEAD()` accesses a following row.

```sql
SELECT
    event_time,
    event_type,
    LEAD(event_time) OVER (
        PARTITION BY user_id
        ORDER BY event_time
    ) AS next_event_time
FROM events;
```

This is useful for calculating time until the next event.

## 10. Running Total

```sql
SELECT
    order_date,
    amount,
    SUM(amount) OVER (
        ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM orders;
```

The explicit `ROWS` frame is important when duplicate ordering values exist and you need row-by-row accumulation.

## 11. Window Frames

A window frame defines which rows around the current row participate in a window calculation.

Common forms include:

```sql
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
```

for a running total, and:

```sql
ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
```

for a seven-row moving calculation.

Do not assume that `ORDER BY` alone always gives the frame behavior you intend. Specify the frame when the distinction matters.

## 12. Moving Average

```sql
SELECT
    sales_date,
    sales,
    AVG(sales) OVER (
        ORDER BY sales_date
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS seven_row_avg
FROM daily_sales;
```

This is a **seven-row** window, not necessarily seven calendar days if dates are missing.

## 13. FIRST_VALUE and LAST_VALUE

```sql
SELECT
    employee_id,
    department_id,
    salary,
    FIRST_VALUE(salary) OVER (
        PARTITION BY department_id
        ORDER BY salary DESC
    ) AS highest_salary
FROM employees;
```

`LAST_VALUE()` requires special care because its result depends on the window frame. When you need the last row in the complete partition, define the frame explicitly rather than relying on a default.

## 14. Group-Level Comparison Without Losing Rows

```sql
SELECT
    employee_id,
    department_id,
    salary,
    salary - AVG(salary) OVER (
        PARTITION BY department_id
    ) AS difference_from_department_avg
FROM employees;
```

This is a major advantage over `GROUP BY`: both the individual row and group metric remain available.

## 15. Previous and Current Record Comparison

```sql
SELECT
    customer_id,
    order_id,
    order_date,
    LAG(order_date) OVER (
        PARTITION BY customer_id
        ORDER BY order_date, order_id
    ) AS previous_order_date
FROM orders;
```

Then calculate the interval with `DATEDIFF()` when required.

## 16. Gaps and Islands Pattern

Window functions can help identify consecutive periods or event sequences.

A common approach is:

```text
ordered rows
    ↓
LAG / ROW_NUMBER
    ↓
identify boundary
    ↓
create group key
    ↓
GROUP BY the generated key
```

This pattern is useful for consecutive login days, active periods, and uninterrupted status intervals.

## 17. Window Functions vs GROUP BY

| Requirement | Better tool |
|---|---|
| One result per department | `GROUP BY` |
| Keep employees + department average | Window function |
| Top 3 employees per department | Window function |
| Count rows per group only | `GROUP BY` |
| Previous transaction | `LAG()` |
| Next transaction | `LEAD()` |
| Running total | Window function |

The choice depends on whether detail rows must remain in the result.

## 18. Window Functions vs Self JOIN

Many previous/next-row problems can be solved with self-joins, but `LAG()` and `LEAD()` usually express the intent more directly and are easier to maintain.

Use a self-join when the relationship is not naturally positional or when the business rule requires a different matching condition.

## 19. Important SQL Processing Rule

A window function is calculated after the `WHERE` filtering of its query block. Therefore this pattern is invalid:

```sql
SELECT
    employee_id,
    ROW_NUMBER() OVER (ORDER BY salary DESC) AS rn
FROM employees
WHERE rn <= 3;
```

Use a derived table or CTE:

```sql
WITH ranked AS (
    SELECT
        employee_id,
        ROW_NUMBER() OVER (ORDER BY salary DESC) AS rn
    FROM employees
)
SELECT *
FROM ranked
WHERE rn <= 3;
```

## 20. Data Engineering Uses

Window functions are particularly useful for:

- Deduplicating CDC/staging records
- Selecting latest records
- Top-N analysis
- Change detection
- Incremental processing
- Previous/next event analysis
- Running metrics
- Session and activity analysis
- Data-quality anomaly detection

## ⚡ Performance Considerations

Window functions can require sorting or partitioning work.

Pay attention to:

- Large partitions
- High-cardinality `PARTITION BY`
- Window `ORDER BY` columns
- Filtering rows before the window calculation when logically possible
- Avoiding unnecessary windows
- Checking the execution plan with `EXPLAIN`

An index may help the overall query, but do not assume an index automatically eliminates every sort required by a window operation.

## ⚠️ Common Mistakes

- Confusing `RANK()` with `DENSE_RANK()`.
- Using `ROW_NUMBER()` without a deterministic tie-breaker.
- Filtering a window alias directly in `WHERE`.
- Forgetting `PARTITION BY` when the calculation should restart per entity.
- Assuming a seven-row frame means seven calendar days.
- Misunderstanding `LAST_VALUE()` because of the default frame.
- Performing a window calculation after a join that has unintentionally multiplied rows.
- Using a window function when `GROUP BY` is simpler and detail rows are not needed.

## 🎤 Interview-Focused Questions

### Q1. What is a window function?
<details>
<summary><strong>Answer</strong></summary>

A window function calculates a value across related rows while keeping the individual rows in the result. `GROUP BY` normally collapses rows; a window function does not.
</details>

### Q2. What is the difference between ROW_NUMBER, RANK, and DENSE_RANK?
<details>
<summary><strong>Answer</strong></summary>

`ROW_NUMBER()` gives every row a unique sequence. `RANK()` gives ties the same rank and leaves gaps. `DENSE_RANK()` gives ties the same rank without gaps.
</details>

### Q3. How do you find the top 3 salaries in every department?
<details>
<summary><strong>Answer</strong></summary>

Partition by department, rank by salary descending, then filter the generated rank in an outer query.

```sql
WITH ranked AS (
    SELECT e.*,
           ROW_NUMBER() OVER (
               PARTITION BY department_id
               ORDER BY salary DESC, employee_id
           ) AS rn
    FROM employees e
)
SELECT *
FROM ranked
WHERE rn <= 3;
```
</details>

### Q4. How would you remove duplicate records while keeping the latest one?
<details>
<summary><strong>Answer</strong></summary>

Use `ROW_NUMBER()` partitioned by the business key and ordered by the latest timestamp descending. Keep `rn = 1`.
</details>

### Q5. What does PARTITION BY do?
<details>
<summary><strong>Answer</strong></summary>

It divides the input into independent windows. The window calculation restarts for each partition.
</details>

### Q6. What is LAG used for?
<details>
<summary><strong>Answer</strong></summary>

`LAG()` accesses a previous row in the window, making it useful for change detection, previous-order comparisons, and time-series calculations.
</details>

### Q7. What is LEAD used for?
<details>
<summary><strong>Answer</strong></summary>

`LEAD()` accesses a following row. It is useful for next-event analysis and calculating time until the next event.
</details>

### Q8. Why can ROW_NUMBER produce non-reproducible results?
<details>
<summary><strong>Answer</strong></summary>

If the window ordering contains ties and no unique tie-breaker, multiple tied rows can receive different row numbers across executions. Add a stable unique column to the ordering.
</details>

### Q9. Why can't you normally use a window-function alias in WHERE?
<details>
<summary><strong>Answer</strong></summary>

The window calculation is performed after the filtering stage of that query block. Put the window calculation in a CTE or derived table and filter it in the outer query.
</details>

### Q10. What is a window frame?
<details>
<summary><strong>Answer</strong></summary>

A frame specifies the subset of rows within the window that participates in the calculation for the current row. It is especially important for running totals and moving calculations.
</details>

### Q11. Why can a seven-row moving average differ from a seven-day moving average?
<details>
<summary><strong>Answer</strong></summary>

`ROWS BETWEEN 6 PRECEDING AND CURRENT ROW` counts rows. If dates are missing, seven rows may span more than seven calendar days. A true seven-day metric needs date-based logic.
</details>

### Q12. When would you choose GROUP BY instead of a window function?
<details>
<summary><strong>Answer</strong></summary>

Use `GROUP BY` when you only need one result per group. Use a window function when the individual rows must remain available alongside the group-level calculation.
</details>

## 🔄 Quick Revision

| Concept | Key Point |
|---|---|
| `OVER()` | Defines a window calculation |
| `PARTITION BY` | Restarts calculation per group |
| `ROW_NUMBER()` | Unique sequence |
| `RANK()` | Ties with gaps |
| `DENSE_RANK()` | Ties without gaps |
| `LAG()` | Previous row |
| `LEAD()` | Next row |
| Window frame | Defines rows participating in calculation |
| Top-N per group | Rank + outer filter |
| Deduplication | `ROW_NUMBER()` + business key |
| Running total | `SUM() OVER (...)` |

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — practical window-function patterns
- [`practice.sql`](./practice.sql) — interview and Data Engineering exercises without solutions
