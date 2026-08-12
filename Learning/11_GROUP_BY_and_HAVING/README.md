# 11 — GROUP BY and HAVING

## 📌 Overview

`GROUP BY` is used to transform row-level data into **business-level summaries**. It divides the input rows into groups, after which aggregate functions such as `COUNT`, `SUM`, `AVG`, `MIN`, and `MAX` calculate metrics for each group.

`HAVING` filters those groups **after aggregation**.

This topic is fundamental for Data Engineering because many real pipelines transform event-level data into metrics such as:

- Daily revenue
- Customer-level totals
- Product-level sales
- Batch row counts
- Data-quality metrics
- Duplicate detection
- Source-to-target reconciliation
- Monthly operational statistics

The most important concept is **grain**:

> Before writing a `GROUP BY`, know exactly what one output row is supposed to represent.

---

## 🎯 Learning Objectives

By the end of this topic, you should be able to:

- Understand how `GROUP BY` works.
- Group by one or multiple columns.
- Combine grouping with aggregate functions.
- Understand `WHERE` vs `HAVING`.
- Filter groups using aggregate conditions.
- Group by expressions.
- Handle `NULL` groups correctly.
- Understand grouping grain.
- Use conditional aggregation with `CASE`.
- Detect duplicates with `GROUP BY` and `HAVING`.
- Understand how JOINs can inflate grouped metrics.
- Build Data Engineering reconciliation queries.
- Optimize grouped queries appropriately.

---

## 🧠 1. What Does GROUP BY Do?

`GROUP BY` divides rows into groups based on one or more expressions.

Example:

```sql
SELECT
    department,
    COUNT(*) AS employee_count
FROM employees
GROUP BY department;
```

If the table contains:

```text
employee | department
---------+------------
Asha     | IT
Rahul    | IT
Neha     | HR
Vikram   | HR
Arjun    | Finance
```

The groups are:

```text
IT       → Asha, Rahul
HR       → Neha, Vikram
Finance  → Arjun
```

The output becomes one row per department.

---

## 📊 2. GROUP BY with Multiple Aggregates

A group can have several metrics.

```sql
SELECT
    department,
    COUNT(*) AS employee_count,
    AVG(salary) AS average_salary,
    MIN(salary) AS minimum_salary,
    MAX(salary) AS maximum_salary,
    SUM(salary) AS total_salary
FROM employees
GROUP BY department;
```

Each aggregate is calculated independently for each department.

This is a common reporting pattern:

```text
Raw employee rows
       ↓
Group by department
       ↓
Calculate metrics
       ↓
Department summary
```

---

## 🎯 3. Understanding Grain

**Grain** describes what one row represents.

Consider:

```sql
GROUP BY customer_id
```

The result grain is:

```text
1 row = 1 customer
```

Now consider:

```sql
GROUP BY customer_id, order_year
```

The grain becomes:

```text
1 row = 1 customer + 1 year
```

And:

```sql
GROUP BY customer_id, order_year, order_month
```

means:

```text
1 row = 1 customer + 1 year + 1 month
```

### Why grain matters

If the business requirement asks for monthly customer revenue but you group only by customer, the query produces the wrong level of detail.

Always define the target grain before writing the query.

---

## 🔢 4. GROUP BY Multiple Columns

You can group by several dimensions.

```sql
SELECT
    department,
    job_title,
    COUNT(*) AS employee_count
FROM employees
GROUP BY
    department,
    job_title;
```

The group is defined by the **combination**:

```text
department + job_title
```

For example:

```text
IT + Data Engineer
IT + Developer
HR + Recruiter
```

These are separate groups.

---

## 🔎 5. GROUP BY and SELECT Columns

A grouped query should conceptually return columns that are:

1. Grouping expressions, or
2. Aggregate expressions.

Example:

```sql
SELECT
    department,
    COUNT(*) AS employee_count
FROM employees
GROUP BY department;
```

`department` identifies the group and `COUNT(*)` summarizes it.

### Important MySQL note

MySQL's SQL mode matters here. With `ONLY_FULL_GROUP_BY` enabled, selecting a non-aggregated column that is not properly grouped is rejected unless MySQL can establish that it is functionally dependent on the grouped columns.

Do not rely on permissive grouping behavior that returns an arbitrary non-grouped value.

---

## 🧠 6. WHERE vs GROUP BY vs HAVING

These clauses have different jobs.

```text
WHERE
  ↓
filters individual rows

GROUP BY
  ↓
creates groups

HAVING
  ↓
filters groups
```

Example:

```sql
SELECT
    department,
    COUNT(*) AS employee_count
FROM employees
WHERE salary >= 50000
GROUP BY department
HAVING COUNT(*) >= 3;
```

Interpretation:

1. Remove employees earning below 50,000.
2. Group remaining employees by department.
3. Count employees in each department.
4. Keep departments having at least 3 qualifying employees.

---

## 🔍 7. Why WHERE and HAVING Are Different

Suppose the requirement is:

> Find departments containing at least 5 employees.

Use:

```sql
HAVING COUNT(*) >= 5
```

because the condition depends on the group result.

But if the requirement is:

> Only consider employees earning at least 50,000 before calculating department counts.

Use:

```sql
WHERE salary >= 50000
```

The distinction is:

```text
WHERE → row-level condition
HAVING → group-level condition
```

---

## 🧮 8. HAVING with SUM

```sql
SELECT
    customer_id,
    SUM(amount) AS total_spend
FROM orders
GROUP BY customer_id
HAVING SUM(amount) > 100000;
```

This returns customers whose aggregated spending exceeds 100,000.

The aggregate is calculated first for each customer, then `HAVING` filters the groups.

---

## 📊 9. HAVING with AVG

```sql
SELECT
    department,
    AVG(salary) AS average_salary
FROM employees
GROUP BY department
HAVING AVG(salary) > 80000;
```

The condition cannot be expressed as a simple row-level filter because it depends on the department's aggregate average.

---

## 🔢 10. HAVING with COUNT

A very common interview pattern is:

> Find customers who placed more than 3 orders.

```sql
SELECT
    customer_id,
    COUNT(*) AS order_count
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > 3;
```

This is also the standard pattern for many duplicate-detection problems.

---

## 🔁 11. Duplicate Detection

Suppose `email` should be unique.

Find duplicates:

```sql
SELECT
    email,
    COUNT(*) AS duplicate_count
FROM customers
WHERE email IS NOT NULL
GROUP BY email
HAVING COUNT(*) > 1;
```

The result tells you which email values occur more than once.

### Why WHERE before GROUP BY?

If NULL emails should not be treated as duplicates, remove them before grouping.

If NULL itself represents a meaningful duplicate condition, the business rule should explicitly decide how to handle it.

---

## NULL 12. How NULL Behaves in GROUP BY

NULL values are grouped together.

```sql
SELECT
    department,
    COUNT(*) AS employee_count
FROM employees
GROUP BY department;
```

If several employees have:

```text
department = NULL
```

they belong to the same group.

Conceptually:

```text
IT        → group 1
HR        → group 2
NULL      → group 3
```

This is different from saying NULL values are equal in ordinary SQL comparisons. Grouping has its own semantics for forming groups.

---

## 🔢 13. COUNT(*) vs COUNT(column) Inside GROUP BY

Consider:

```sql
SELECT
    department,
    COUNT(*) AS employees,
    COUNT(manager_id) AS employees_with_manager
FROM employees
GROUP BY department;
```

`COUNT(*)` counts all rows in each department.

`COUNT(manager_id)` counts only employees whose `manager_id` is non-NULL.

This can be useful for data-quality analysis:

```text
total employees
        vs
employees with manager assigned
```

---

## 🔀 14. Conditional Aggregation with GROUP BY

You can calculate several conditional metrics for every group.

```sql
SELECT
    department,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN salary >= 100000 THEN 1 ELSE 0 END) AS high_earners,
    SUM(CASE WHEN salary < 50000 THEN 1 ELSE 0 END) AS low_earners
FROM employees
GROUP BY department;
```

This produces a department-level profile in one query.

Another example:

```sql
SELECT
    order_date,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN status = 'COMPLETED' THEN 1 ELSE 0 END) AS completed_orders,
    SUM(CASE WHEN status = 'CANCELLED' THEN 1 ELSE 0 END) AS cancelled_orders
FROM orders
GROUP BY order_date;
```

This is extremely common in ETL and reporting workloads.

---

## 📅 15. GROUP BY Date Components

Suppose `order_date` is a date or timestamp.

You can group by year:

```sql
SELECT
    YEAR(order_date) AS order_year,
    COUNT(*) AS order_count
FROM orders
GROUP BY YEAR(order_date);
```

Or by month:

```sql
SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    COUNT(*) AS order_count
FROM orders
GROUP BY
    YEAR(order_date),
    MONTH(order_date);
```

### Important

Grouping by only:

```sql
MONTH(order_date)
```

combines January from different years into the same group.

For multi-year data, include the year or use a proper month key.

---

## 🗓️ 16. Grouping by a Calendar Month

A useful reporting pattern is to group by a month boundary.

For example:

```sql
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS order_month,
    SUM(amount) AS monthly_revenue
FROM orders
GROUP BY DATE_FORMAT(order_date, '%Y-%m');
```

For high-volume production queries, consider the performance implications of applying functions to columns and the availability of suitable indexes or generated/indexed representations.

---

## 🧩 17. GROUP BY Expressions

You are not limited to physical columns.

```sql
SELECT
    CASE
        WHEN salary >= 100000 THEN 'HIGH'
        WHEN salary >= 50000 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS salary_band,
    COUNT(*) AS employee_count
FROM employees
GROUP BY
    CASE
        WHEN salary >= 100000 THEN 'HIGH'
        WHEN salary >= 50000 THEN 'MEDIUM'
        ELSE 'LOW'
    END;
```

The expression defines the grouping key.

For maintainability, a derived table or CTE can sometimes make complex grouping expressions easier to read.

---

## 🔗 18. GROUP BY After a JOIN

Grouping after joins is common:

```sql
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(o.order_id) AS order_count,
    SUM(o.amount) AS total_spend
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY
    c.customer_id,
    c.customer_name;
```

This produces one row per customer.

### Why COUNT(o.order_id) instead of COUNT(*)?

With a `LEFT JOIN`, customers without orders still produce a joined row containing NULL order columns.

Therefore:

```sql
COUNT(*)
```

would count that preserved customer row.

But:

```sql
COUNT(o.order_id)
```

counts only actual matched orders.

This is a very common interview trap.

---

## 🚨 19. Join Multiplication and Incorrect Aggregates

Suppose one customer has:

```text
3 orders
2 payments
```

If you directly join both one-to-many tables:

```text
customer
   ↓
orders × payments
```

you can create up to:

```text
3 × 2 = 6 joined rows
```

Then:

```sql
SUM(order_amount)
```

can be multiplied incorrectly.

### Safer pattern

Aggregate each one-to-many source at the required grain first, then join the summaries.

```text
orders
  ↓ aggregate by customer
customer_order_summary

payments
  ↓ aggregate by customer
customer_payment_summary

          ↓
        JOIN
          ↓
customer-level result
```

This is one of the most important practical aggregation patterns for Data Engineers.

---

## 🏗️ 20. Data Engineering — Batch Validation

Suppose events arrive with a `batch_id`.

```sql
SELECT
    batch_id,
    COUNT(*) AS row_count,
    MIN(event_time) AS first_event,
    MAX(event_time) AS last_event
FROM staging_events
GROUP BY batch_id;
```

This creates a profile for every batch.

You can then identify suspicious batches:

```sql
SELECT
    batch_id,
    COUNT(*) AS row_count
FROM staging_events
GROUP BY batch_id
HAVING COUNT(*) < 100;
```

This finds batches below the expected minimum row count.

---

## 🔍 21. Data Engineering — Reconciliation by Business Grain

Suppose source and target data must be reconciled daily.

Source:

```sql
SELECT
    order_date,
    COUNT(*) AS source_count,
    SUM(amount) AS source_amount
FROM source_orders
GROUP BY order_date;
```

Target:

```sql
SELECT
    order_date,
    COUNT(*) AS target_count,
    SUM(amount) AS target_amount
FROM warehouse_orders
GROUP BY order_date;
```

Both datasets must use the same:

- Date definition
- Filters
- Business grain
- Currency treatment
- Null handling

Otherwise, matching the query syntax does not guarantee meaningful reconciliation.

---

## 📈 22. Grouping by Business Dimensions

A warehouse often contains dimensions such as:

```text
country
city
product_category
customer_segment
channel
```

Example:

```sql
SELECT
    country,
    channel,
    SUM(revenue) AS revenue
FROM sales
GROUP BY
    country,
    channel;
```

The output grain is:

```text
1 row = 1 country + 1 channel
```

This is the foundation of many dimensional reporting queries.

---

## 🧮 23. HAVING vs WHERE — Performance Perspective

If a condition can be applied before grouping, `WHERE` is often preferable.

For example:

```sql
SELECT
    department,
    COUNT(*) AS employee_count
FROM employees
WHERE status = 'ACTIVE'
GROUP BY department;
```

This allows the query to eliminate irrelevant rows before grouping.

Compare with:

```sql
SELECT
    department,
    COUNT(*) AS employee_count
FROM employees
GROUP BY department
HAVING SUM(status = 'ACTIVE') > 0;
```

The second query expresses a different operation and may process more rows before deciding which groups survive.

The optimizer can transform queries, but writing predicates at the correct logical stage is clearer and often helps reduce unnecessary work.

---

## 🔄 24. Can HAVING Be Used Without GROUP BY?

Yes.

When an aggregate query has no `GROUP BY`, the input is treated as one overall group for aggregation purposes.

Example:

```sql
SELECT
    COUNT(*) AS order_count
FROM orders
HAVING COUNT(*) > 1000;
```

The query either returns one row or no rows depending on whether the aggregate condition is satisfied.

This is less common than grouped `HAVING`, but it is valid and useful in validation queries.

---

## 🧠 25. Logical Query Processing Order

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

This explains why:

- `WHERE` cannot normally reference aggregate results.
- `HAVING` can filter aggregate results.
- `ORDER BY` operates on the resulting grouped query.

This is a **logical model**. The MySQL optimizer may physically execute operations in a different order when it can preserve the same result.

---

## 🧪 26. Data Quality — Duplicate Detection by Composite Key

Suppose an event should be unique by:

```text
customer_id + event_date + event_type
```

Find duplicate combinations:

```sql
SELECT
    customer_id,
    event_date,
    event_type,
    COUNT(*) AS duplicate_count
FROM events
GROUP BY
    customer_id,
    event_date,
    event_type
HAVING COUNT(*) > 1;
```

This is more useful than checking each column separately because it matches the actual business uniqueness rule.

---

## ⚠️ 27. Common Mistakes

### Mistake 1 — Using WHERE for aggregate conditions

Wrong:

```sql
WHERE COUNT(*) > 3
```

Use:

```sql
HAVING COUNT(*) > 3
```

### Mistake 2 — Wrong grouping grain

Grouping only by customer when the requirement is customer + month produces incorrect aggregation detail.

### Mistake 3 — Counting `COUNT(*)` after LEFT JOIN

This can count preserved parent rows even when there is no matching child record. Use a nullable child key when counting matches.

### Mistake 4 — Double-counting after multiple one-to-many JOINs

Pre-aggregate each many-side table when necessary.

### Mistake 5 — Ignoring NULL groups

NULL values form a group in `GROUP BY`.

### Mistake 6 — Grouping by month without year

January 2025 and January 2026 can be combined unintentionally.

### Mistake 7 — Using HAVING for simple row filters

Filter rows with `WHERE` when possible.

### Mistake 8 — Reconciliation at different grains

Source and target metrics must represent the same business grain.

### Mistake 9 — Relying on non-standard permissive grouping

Write queries that remain correct with `ONLY_FULL_GROUP_BY` enabled.

---

## ⚡ 28. Performance Considerations

Grouping can be expensive because MySQL may need to process many rows and build intermediate grouping structures.

Consider:

- Filter unnecessary rows before grouping when the business logic permits.
- Index columns used for selective filtering.
- Consider indexes that support common grouping/access patterns, while verifying the actual plan.
- Avoid unnecessary expressions on very large datasets when an indexed/generated representation can help.
- Pre-aggregate large one-to-many datasets before joining when required to prevent multiplication.
- Avoid unnecessary `COUNT(DISTINCT ...)` when uniqueness is not required.
- Keep grouping dimensions at the correct cardinality.
- Use `EXPLAIN` to inspect the actual execution plan.
- Validate performance using realistic data volumes.

A query that is fast on 10,000 rows may behave very differently on hundreds of millions of rows.

---

## 🎤 29. Interview-Focused Questions

### Q1. What is the difference between WHERE and HAVING?

<details>
<summary><strong>Answer</strong></summary>

`WHERE` filters individual rows before grouping and aggregation. `HAVING` filters groups after aggregate calculations. Use `WHERE` for row-level conditions and `HAVING` for group-level or aggregate conditions.

</details>

---

### Q2. Can HAVING be used without GROUP BY?

<details>
<summary><strong>Answer</strong></summary>

Yes. Without `GROUP BY`, the aggregate query can operate on one overall group. For example, `HAVING COUNT(*) > 100` can determine whether the single aggregate result should be returned.

</details>

---

### Q3. What is the grain of a GROUP BY query?

<details>
<summary><strong>Answer</strong></summary>

The grain defines what one output row represents. For `GROUP BY customer_id, order_month`, one result row represents one customer for one month. Defining grain before writing the query helps prevent incorrect aggregation.

</details>

---

### Q4. How would you find customers with more than three orders?

<details>
<summary><strong>Answer</strong></summary>

Group orders by customer and filter the grouped result:

```sql
SELECT customer_id, COUNT(*) AS order_count
FROM orders
GROUP BY customer_id
HAVING COUNT(*) > 3;
```

</details>

---

### Q5. How would you find duplicate emails?

<details>
<summary><strong>Answer</strong></summary>

Group by email and keep groups with more than one row:

```sql
SELECT email, COUNT(*) AS duplicate_count
FROM customers
WHERE email IS NOT NULL
GROUP BY email
HAVING COUNT(*) > 1;
```

</details>

---

### Q6. Why can a JOIN produce an incorrect SUM before GROUP BY?

<details>
<summary><strong>Answer</strong></summary>

A one-to-many join can duplicate rows. If a parent-level measure appears multiple times after the join, summing it can inflate the result. Understand join cardinality and aggregate at the required grain.

</details>

---

### Q7. What is the difference between COUNT(*) and COUNT(child_id) after a LEFT JOIN?

<details>
<summary><strong>Answer</strong></summary>

`COUNT(*)` counts the preserved joined row even when the child is missing. `COUNT(child_id)` ignores NULL child IDs and therefore counts only matched child records.

</details>

---

### Q8. How would you calculate monthly revenue?

<details>
<summary><strong>Answer</strong></summary>

Group by a year-month representation and sum revenue:

```sql
SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    SUM(amount) AS monthly_revenue
FROM orders
GROUP BY YEAR(order_date), MONTH(order_date);
```

Including the year prevents January values from different years being combined.

</details>

---

### Q9. How would you find departments whose average salary exceeds 80,000?

<details>
<summary><strong>Answer</strong></summary>

Use `GROUP BY department` and filter the aggregate with `HAVING`:

```sql
SELECT department, AVG(salary) AS avg_salary
FROM employees
GROUP BY department
HAVING AVG(salary) > 80000;
```

</details>

---

### Q10. Why should you use WHERE instead of HAVING when a filter is row-level?

<details>
<summary><strong>Answer</strong></summary>

A row-level condition can eliminate irrelevant rows before grouping. This is clearer logically and can reduce the amount of data that must be grouped. The optimizer may also transform equivalent predicates, but expressing the rule at the correct stage improves readability.

</details>

---

### Q11. How would you detect duplicate records based on a composite business key?

<details>
<summary><strong>Answer</strong></summary>

Group by all columns that define uniqueness and use `HAVING COUNT(*) > 1`:

```sql
SELECT customer_id, event_date, event_type, COUNT(*) AS cnt
FROM events
GROUP BY customer_id, event_date, event_type
HAVING COUNT(*) > 1;
```

</details>

---

### Q12. How can you prevent double-counting when joining two one-to-many tables?

<details>
<summary><strong>Answer</strong></summary>

Aggregate each many-side table to the required grain first, then join the summaries. This prevents the Cartesian multiplication that can occur when two independent one-to-many relationships are joined together before aggregation.

</details>

---

### Q13. How would you validate batch-level row counts in a Data Engineering pipeline?

<details>
<summary><strong>Answer</strong></summary>

Group the staging or target data by `batch_id` and calculate `COUNT(*)`. Then compare the result with the expected batch metrics. Also account for completely missing batches, because a missing batch produces no grouped row at all.

</details>

---

### Q14. What does ONLY_FULL_GROUP_BY protect against?

<details>
<summary><strong>Answer</strong></summary>

It prevents ambiguous grouped queries that select non-aggregated columns not properly included in the grouping logic, unless MySQL can establish functional dependence. It encourages deterministic and logically correct aggregation queries.

</details>

---

### Q15. What is a common mistake when grouping by month?

<details>
<summary><strong>Answer</strong></summary>

Grouping only by `MONTH(order_date)` combines the same month across different years. Use year plus month, a proper month key, or another calendar representation that preserves the intended grain.

</details>

---

### Q16. How would you reconcile source and target data by day?

<details>
<summary><strong>Answer</strong></summary>

Calculate comparable metrics at the same daily grain on both sides, such as row count and total amount:

```sql
SELECT order_date,
       COUNT(*) AS row_count,
       SUM(amount) AS total_amount
FROM source_orders
GROUP BY order_date;
```

Then compare the equivalent target aggregation. Both sides must use the same business definitions and filters.

</details>

---

## 🔄 30. Quick Revision

| Concept | Key Point |
|---|---|
| `GROUP BY` | Creates groups for aggregation |
| `HAVING` | Filters groups after aggregation |
| `WHERE` | Filters rows before grouping |
| Grain | Defines what one output row represents |
| Multiple columns | Define a composite grouping key |
| `COUNT(*)` | Counts every row in a group |
| `COUNT(column)` | Counts non-NULL values in a group |
| Conditional aggregation | Uses `CASE` inside aggregate functions |
| Duplicate detection | `GROUP BY ... HAVING COUNT(*) > 1` |
| LEFT JOIN count | `COUNT(child_id)` counts matched children |
| Join multiplication | Can inflate aggregates |
| `ONLY_FULL_GROUP_BY` | Helps prevent ambiguous grouping |
| Reconciliation | Compare metrics at the same grain |

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — worked examples for GROUP BY, HAVING, conditional aggregation, joins, and Data Engineering scenarios
- [`practice.sql`](./practice.sql) — hands-on exercises, grouping scenarios, reconciliation problems, and interview practice
