# 21 — Window Functions

> [!NOTE]
> Window functions are one of the most important SQL topics for a Data Engineer interview. This topic is designed to build understanding first, then query-writing ability, then interview confidence.

## 📌 What You Will Learn

By the end of this topic, you should be able to:

- Explain what a window function does in simple terms.
- Understand `OVER()`, `PARTITION BY`, and window `ORDER BY`.
- Choose correctly between `ROW_NUMBER()`, `RANK()`, and `DENSE_RANK()`.
- Use `LAG()` and `LEAD()` for previous/next-row analysis.
- Build running totals and moving calculations.
- Understand window frames such as `ROWS BETWEEN ...`.
- Solve Top-N-per-group problems.
- Deduplicate staging/CDC data safely.
- Compare current and previous records.
- Solve first/last-event and gaps-and-islands problems.
- Understand why window functions cannot normally be filtered directly in `WHERE`.
- Recognize grain problems caused by joins before a window calculation.
- Apply these patterns to Data Engineering scenarios.

---

# 1. The Core Idea

A window function calculates something **across multiple related rows while keeping the original rows**.

The easiest comparison is:

```text
GROUP BY
    ↓
combines rows
    ↓
one row per group
```

versus:

```text
WINDOW FUNCTION
    ↓
looks across related rows
    ↓
keeps every original row
    ↓
adds a calculated column
```

Example data:

| employee_id | department | salary |
|---:|---|---:|
| 1 | IT | 80000 |
| 2 | IT | 90000 |
| 3 | HR | 70000 |
| 4 | HR | 75000 |

With `GROUP BY department`, you might get two rows.

With a window function, all four employees remain visible.

That is the fundamental reason window functions are so powerful.

---

# 2. Window Function Syntax

The general structure is:

```sql
function_name(expression) OVER (
    [PARTITION BY ...]
    [ORDER BY ...]
    [window_frame]
)
```

Example:

```sql
AVG(salary) OVER (
    PARTITION BY department_id
)
```

Think of the three major parts as:

```text
PARTITION BY → Which rows belong together?
ORDER BY     → In what sequence should I consider them?
FRAME        → Which rows around the current row should participate?
```

Not every window function needs all three.

---

# 3. `OVER()` Without PARTITION BY

```sql
SELECT
    employee_id,
    salary,
    AVG(salary) OVER () AS company_avg_salary
FROM employees;
```

There is no `PARTITION BY`, so the entire result set is one window.

Every employee gets the same company average.

### Mental model

```text
All employees
┌──────────────────────────┐
│ 80k  90k  70k  75k       │
└──────────────────────────┘
           ↓
      AVG = 78.75k
           ↓
added to every row
```

---

# 4. `PARTITION BY`

`PARTITION BY` splits the rows into independent windows.

```sql
SELECT
    employee_id,
    department_id,
    salary,
    AVG(salary) OVER (
        PARTITION BY department_id
    ) AS department_avg
FROM employees;
```

Now the calculation restarts for every department.

```text
IT partition
80k, 90k → 85k

HR partition
70k, 75k → 72.5k
```

### Important

`PARTITION BY` is **not** the same as `GROUP BY`.

`GROUP BY` collapses rows.

`PARTITION BY` creates calculation groups but keeps the rows.

---

# 5. Window ORDER BY

The `ORDER BY` inside `OVER()` controls the order used by the window calculation.

```sql
ROW_NUMBER() OVER (
    ORDER BY salary DESC
)
```

This is different from the final query ordering:

```sql
ORDER BY salary DESC
```

A query can have both:

```sql
SELECT
    employee_id,
    salary,
    ROW_NUMBER() OVER (
        ORDER BY salary DESC
    ) AS salary_position
FROM employees
ORDER BY employee_id;
```

The window calculates salary position, while the final `ORDER BY` controls how the result is displayed.

---

# 6. ROW_NUMBER()

`ROW_NUMBER()` gives every row a unique sequence number.

```sql
SELECT
    employee_id,
    salary,
    ROW_NUMBER() OVER (
        ORDER BY salary DESC
    ) AS rn
FROM employees;
```

Example:

| salary | rn |
|---:|---:|
| 100000 | 1 |
| 90000 | 2 |
| 90000 | 3 |
| 80000 | 4 |

Even tied salaries receive different row numbers.

### When to use it

Use `ROW_NUMBER()` when you need exactly one row from each group, such as:

- Latest record per customer
- First order per customer
- Top 1 employee per department
- Deduplication
- Selecting the second order

---

# 7. RANK()

`RANK()` gives tied values the same rank and leaves gaps.

For:

```text
100
100
90
80
```

we get:

| salary | rank |
|---:|---:|
| 100 | 1 |
| 100 | 1 |
| 90 | 3 |
| 80 | 4 |

Why does 90 get rank 3?

Because two rows already occupy rank 1.

---

# 8. DENSE_RANK()

`DENSE_RANK()` also gives ties the same rank, but does not leave gaps.

```text
100 → 1
100 → 1
90  → 2
80  → 3
```

### Quick comparison

| Salary | ROW_NUMBER | RANK | DENSE_RANK |
|---:|---:|---:|---:|
| 100 | 1 | 1 | 1 |
| 100 | 2 | 1 | 1 |
| 90 | 3 | 3 | 2 |
| 80 | 4 | 4 | 3 |

### Interview rule

```text
Need unique row number       → ROW_NUMBER
Need ranking with gaps       → RANK
Need ranking without gaps    → DENSE_RANK
```

---

# 9. The Most Important Ranking Question

Suppose an interviewer asks:

> Find the second-highest salary.

Do not immediately write SQL.

First ask:

> Do you mean the second row, or the second distinct salary?

### Second row

Use `ROW_NUMBER()`.

### Second distinct salary

Use `DENSE_RANK()`.

This distinction is extremely common in interviews.

---

# 10. Deterministic ROW_NUMBER

This is an important production-quality concept.

Suppose two orders have the same `order_date`:

```sql
ROW_NUMBER() OVER (
    PARTITION BY customer_id
    ORDER BY order_date DESC
)
```

The database has no complete instruction for deciding which tied row should receive `1`.

Add a stable tie-breaker:

```sql
ROW_NUMBER() OVER (
    PARTITION BY customer_id
    ORDER BY order_date DESC,
             order_id DESC
)
```

Now the result is deterministic.

> [!TIP]
> For production ETL and interview answers, prefer a deterministic ordering whenever `ROW_NUMBER()` is used to select a specific row.

---

# 11. Top-N Per Group

### Business problem

Find the top 3 highest-paid employees in every department.

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
SELECT
    employee_id,
    department_id,
    salary
FROM ranked
WHERE rn <= 3;
```

### Why the CTE?

The window function creates `rn` first.

The outer query filters it.

```text
employees
   ↓
PARTITION BY department
   ↓
rank rows
   ↓
CTE
   ↓
WHERE rn <= 3
```

---

# 12. Top-N With Ties

The business requirement may instead be:

> Return everyone whose salary is within the top 3 salary levels.

Now `DENSE_RANK()` may be more appropriate:

```sql
WITH ranked AS (
    SELECT
        employee_id,
        department_id,
        salary,
        DENSE_RANK() OVER (
            PARTITION BY department_id
            ORDER BY salary DESC
        ) AS salary_rank
    FROM employees
)
SELECT *
FROM ranked
WHERE salary_rank <= 3;
```

This can return more than three employees in a department because ties are preserved.

---

# 13. Deduplication Pattern

A common Data Engineering problem:

> A staging table contains multiple records for the same customer. Keep the latest record.

```sql
WITH ranked AS (
    SELECT
        t.*,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY updated_at DESC,
                     record_id DESC
        ) AS rn
    FROM staging_customer t
)
SELECT *
FROM ranked
WHERE rn = 1;
```

This pattern appears frequently in:

- ETL pipelines
- ELT pipelines
- CDC processing
- Data warehouses
- Staging tables
- Slowly changing data workflows

---

# 14. LAG()

`LAG()` lets the current row look backward.

```sql
SELECT
    order_date,
    amount,
    LAG(amount) OVER (
        ORDER BY order_date
    ) AS previous_amount
FROM orders;
```

Example:

| date | amount | previous_amount |
|---|---:|---:|
| Jan 1 | 100 | NULL |
| Jan 2 | 150 | 100 |
| Jan 3 | 120 | 150 |

The first row has no previous row, so the result is `NULL` unless a default is supplied.

---

# 15. LAG() Offset

The second argument specifies how far backward to look.

```sql
LAG(amount, 1) OVER (...)
```

Previous row.

```sql
LAG(amount, 2) OVER (...)
```

Two rows earlier.

You can also provide a default:

```sql
LAG(amount, 1, 0) OVER (
    ORDER BY order_date
)
```

If there is no previous row, return `0` instead of `NULL`.

---

# 16. Change Detection With LAG

A very common interview pattern:

> Find the change from the previous transaction.

```sql
SELECT
    order_date,
    amount,
    amount - LAG(amount) OVER (
        ORDER BY order_date
    ) AS amount_change
FROM orders;
```

You can also calculate percentage change:

```sql
SELECT
    order_date,
    amount,
    LAG(amount) OVER (
        ORDER BY order_date
    ) AS previous_amount
FROM orders;
```

Then calculate the percentage in an outer query to avoid repeating the window expression.

---

# 17. LAG With PARTITION BY

For customer-specific history:

```sql
SELECT
    customer_id,
    order_id,
    order_date,
    amount,
    LAG(amount) OVER (
        PARTITION BY customer_id
        ORDER BY order_date, order_id
    ) AS previous_amount
FROM orders;
```

The previous row is now the previous order **for that customer**, not the previous order in the entire table.

This is one of the most important uses of `PARTITION BY`.

---

# 18. LEAD()

`LEAD()` looks forward.

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

Think:

```text
LAG  → look backward
LEAD → look forward
```

---

# 19. Time Until Next Event

```sql
SELECT
    user_id,
    event_time,
    LEAD(event_time) OVER (
        PARTITION BY user_id
        ORDER BY event_time
    ) AS next_event_time
FROM events;
```

Then calculate:

```sql
TIMESTAMPDIFF(
    MINUTE,
    event_time,
    next_event_time
)
```

This is useful for:

- User activity analysis
- Sessionization
- Clickstream analysis
- Event pipelines
- Application logs

---

# 20. Running Total

A running total accumulates values from the beginning up to the current row.

```sql
SELECT
    order_date,
    amount,
    SUM(amount) OVER (
        ORDER BY order_date
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS running_total
FROM orders;
```

Example:

| amount | running_total |
|---:|---:|
| 100 | 100 |
| 50 | 150 |
| 25 | 175 |
| 75 | 250 |

---

# 21. Window Frames

A frame determines which rows participate in the calculation around the current row.

Example:

```sql
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
```

means:

```text
current row
+ previous row
+ two rows before it
```

The frame moves with the current row.

---

# 22. The `ROWS` Frame

For a seven-row calculation:

```sql
ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
```

This means seven rows maximum:

```text
6 previous rows + current row = 7 rows
```

Important: **seven rows does not necessarily mean seven calendar days.**

If dates are missing, seven rows can cover a longer period.

---

# 23. Moving Average

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

This is a seven-row moving average.

For an exact calendar-day requirement, the problem needs different date-based logic; do not automatically call this a seven-day average.

---

# 24. Why Duplicate ORDER BY Values Matter

Suppose:

```text
order_date   amount
2026-01-01   100
2026-01-01    50
2026-01-02    25
```

If the ordering value is not unique, frame behavior can surprise you depending on whether the calculation uses row-based or peer-based semantics.

For row-by-row accumulation, explicitly specify a `ROWS` frame and, when appropriate, a deterministic ordering such as:

```sql
ORDER BY order_date, order_id
```

> [!WARNING]
> Never choose a window frame blindly. Understand whether the business requirement is row-based, value/peer-based, or date-based.

---

# 25. FIRST_VALUE()

`FIRST_VALUE()` returns the first value according to the window ordering.

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

Every employee can therefore see the highest salary in their department.

---

# 26. LAST_VALUE() — Important Interview Trap

`LAST_VALUE()` is frequently misunderstood because its result depends on the window frame.

A safer complete-partition pattern is:

```sql
LAST_VALUE(salary) OVER (
    PARTITION BY department_id
    ORDER BY salary
    ROWS BETWEEN UNBOUNDED PRECEDING
             AND UNBOUNDED FOLLOWING
)
```

The explicit frame tells SQL to consider the complete partition.

### Interview takeaway

If an interviewer asks why `LAST_VALUE()` appears to return the current row, the answer is usually related to the default window frame.

---

# 27. Group Metric Without Losing Detail

Suppose you need each employee's salary and the department average:

```sql
SELECT
    employee_id,
    department_id,
    salary,
    AVG(salary) OVER (
        PARTITION BY department_id
    ) AS department_avg
FROM employees;
```

You can then calculate the difference:

```sql
salary - AVG(salary) OVER (
    PARTITION BY department_id
) AS difference_from_avg
```

This is difficult to express with `GROUP BY` without joining the aggregate result back to the detail table.

---

# 28. Previous Order Per Customer

Business question:

> Show every order and the date of that customer's previous order.

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

Then:

```sql
DATEDIFF(order_date, previous_order_date)
```

can measure the number of days between orders.

---

# 29. First Order Per Customer

```sql
WITH ranked AS (
    SELECT
        customer_id,
        order_id,
        order_date,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
        ) AS rn
    FROM orders
)
SELECT *
FROM ranked
WHERE rn = 1;
```

This is preferable to assuming that `MIN(order_date)` is enough when you also need the complete order record.

---

# 30. Second Order Per Customer

```sql
WITH ranked AS (
    SELECT
        customer_id,
        order_id,
        order_date,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
        ) AS rn
    FROM orders
)
SELECT *
FROM ranked
WHERE rn = 2;
```

This pattern is particularly useful in interview questions involving first, second, or nth events.

---

# 31. Gaps and Islands

Gaps-and-islands problems ask you to identify consecutive groups.

Examples:

- Consecutive login days
- Consecutive active dates
- Continuous employment periods
- Consecutive machine states
- Consecutive successful transactions

Typical workflow:

```text
1. Order the records
        ↓
2. Use LAG / ROW_NUMBER
        ↓
3. Detect a boundary
        ↓
4. Generate a group identifier
        ↓
5. GROUP BY the generated identifier
```

Window functions are often the key step that makes these problems manageable.

---

# 32. Example: Detect a New Streak

Suppose login records contain:

```text
user_id | login_date
--------|-----------
1       | 2026-01-01
1       | 2026-01-02
1       | 2026-01-05
```

Use `LAG()` to compare the current date with the previous date:

```sql
LAG(login_date) OVER (
    PARTITION BY user_id
    ORDER BY login_date
)
```

Then identify whether the difference is greater than one day.

This creates a boundary between streaks.

---

# 33. Window Functions and Query Processing Order

A simplified logical processing order is:

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
WINDOW FUNCTIONS
 ↓
ORDER BY
 ↓
LIMIT
```

The exact SQL engine implementation can differ internally, but this mental model explains an important rule:

You normally cannot do this:

```sql
SELECT
    employee_id,
    ROW_NUMBER() OVER (ORDER BY salary DESC) AS rn
FROM employees
WHERE rn <= 3;
```

Instead:

```sql
WITH ranked AS (
    SELECT
        employee_id,
        ROW_NUMBER() OVER (
            ORDER BY salary DESC
        ) AS rn
    FROM employees
)
SELECT *
FROM ranked
WHERE rn <= 3;
```

---

# 34. CTE vs Derived Table

Both can solve the filtering problem.

### CTE

```sql
WITH ranked AS (
    SELECT ...
)
SELECT *
FROM ranked
WHERE rn <= 3;
```

### Derived table

```sql
SELECT *
FROM (
    SELECT ...
) AS ranked
WHERE rn <= 3;
```

For interview readability, a CTE is often easier to explain when the intermediate result has a meaningful purpose.

---

# 35. Window Functions After JOINs

This is a major Data Engineering trap.

Suppose you join a customer table to a one-to-many transaction table. The join may multiply rows.

If you then apply a window function, the window operates on the **post-join grain**.

Always ask:

> What does one row represent at this point in the query?

This is the concept of **data grain**.

### Safe mental model

```text
source grain
   ↓
JOIN
   ↓
new grain
   ↓
window function
```

If the join unexpectedly duplicates records, your ranking or running total may also be wrong.

---

# 36. GROUP BY vs Window Function

| Requirement | Recommended approach |
|---|---|
| One row per department | `GROUP BY` |
| Employee + department average | Window function |
| Top 3 employees per department | Window function |
| Number of employees per department only | `GROUP BY` |
| Previous transaction | `LAG()` |
| Next transaction | `LEAD()` |
| Running total | Window function |
| Latest record per business key | `ROW_NUMBER()` |
| Ranking | Window function |

### Simple decision rule

```text
Do I need to keep the original rows?

NO  → GROUP BY may be enough
YES → consider a window function
```

---

# 37. Window Functions vs Self JOIN

Before window functions became common, previous/next-row analysis was often implemented with self-joins.

Today:

```sql
LAG()
LEAD()
```

usually communicate positional relationships more clearly.

However, a self-join can still be appropriate when the relationship is not simply “previous” or “next”.

Example:

> Find the next order for the same customer that occurred at least 30 days later.

That business rule may require more than a simple adjacent-row relationship.

---

# 38. Common Data Engineering Patterns

Window functions appear in real pipelines for:

### CDC Deduplication

```text
business key
     ↓
ROW_NUMBER()
     ↓
latest record
```

### Change Detection

```text
current value
     ↓
LAG(previous value)
     ↓
compare
```

### Event Sequencing

```text
LEAD(next event)
     ↓
time to next event
```

### Top-N Reporting

```text
PARTITION BY group
     ↓
RANK
     ↓
filter
```

### Running Metrics

```text
ORDER BY time
     ↓
SUM / AVG OVER
```

---

# 39. Performance Considerations

Window functions can be expensive on very large datasets because the engine may need to sort or organize rows according to the window specification.

Pay attention to:

- Large partitions
- High-cardinality windows
- Expensive `ORDER BY` expressions
- Multiple different window specifications
- Unnecessary rows entering the window calculation
- Joins that multiply data before the window operation

### Good practice

Filter data as early as the business logic allows:

```text
FROM
 ↓
JOIN
 ↓
WHERE
 ↓
window calculation
```

Do not blindly add indexes and assume every window query will become faster. Check the execution plan and actual workload.

---

# 40. Common Interview Mistakes

> [!WARNING]
> These mistakes are more important than memorizing syntax.

1. Confusing `RANK()` and `DENSE_RANK()`.
2. Using `ROW_NUMBER()` when ties should be preserved.
3. Using `DENSE_RANK()` when exactly N rows are required.
4. Forgetting `PARTITION BY`.
5. Ordering in the wrong direction.
6. Using a non-deterministic `ROW_NUMBER()` ordering.
7. Filtering a window alias directly in `WHERE`.
8. Assuming seven rows means seven calendar days.
9. Misunderstanding `LAST_VALUE()` and frames.
10. Applying windows after a row-multiplying join.
11. Using a window function where a simple `GROUP BY` is sufficient.
12. Returning only the rank when the business requirement actually asks for the complete records.

---

# 41. Interview Follow-Up Questions

> [!QUESTION]
>
> ## Interview Follow-Up Questions

### Q1. Find the top 3 employees in each department. What changes if ties must be included?

<details>
<summary><strong>Answer</strong></summary>

Use `ROW_NUMBER()` when exactly three rows per department are required. Use `DENSE_RANK()` when all employees sharing one of the top three salary levels should be included.
</details>

### Q2. How would you find the second-highest salary?

<details>
<summary><strong>Answer</strong></summary>

First clarify whether “second” means the second row or the second distinct salary. Use `ROW_NUMBER()` for the former and `DENSE_RANK()` for the latter.
</details>

### Q3. Why should `ROW_NUMBER()` often include a unique tie-breaker?

<details>
<summary><strong>Answer</strong></summary>

Without a unique ordering, tied rows have no defined relative order. Adding a stable key makes the selected row reproducible.
</details>

### Q4. How do you find each customer's previous order?

<details>
<summary><strong>Answer</strong></summary>

Use `LAG(order_date)` with `PARTITION BY customer_id` and an order such as `ORDER BY order_date, order_id`.
</details>

### Q5. How do you find the time until a user's next event?

<details>
<summary><strong>Answer</strong></summary>

Use `LEAD(event_time)` partitioned by user and ordered by event time, then calculate the timestamp difference.
</details>

### Q6. Why can't you filter `ROW_NUMBER()` directly in `WHERE`?

<details>
<summary><strong>Answer</strong></summary>

The window calculation is not available to the `WHERE` clause of the same query block. Calculate it in a CTE or derived table and filter the result outside.
</details>

### Q7. What is the difference between a partition and a frame?

<details>
<summary><strong>Answer</strong></summary>

A partition defines the complete group of rows for the window. A frame defines the subset of rows within that partition considered for the current row's calculation.
</details>

### Q8. Why can a seven-row moving average not be called a seven-day moving average?

<details>
<summary><strong>Answer</strong></summary>

A `ROWS` frame counts rows, not calendar time. Missing dates can cause seven rows to span more than seven days.
</details>

### Q9. Why is `LAST_VALUE()` a common interview trap?

<details>
<summary><strong>Answer</strong></summary>

Its result depends on the frame. With a default frame, the last row may effectively be the current row. An explicit frame ending at `UNBOUNDED FOLLOWING` can make the intended full-partition behavior clear.
</details>

### Q10. What happens if a join duplicates rows before a window function?

<details>
<summary><strong>Answer</strong></summary>

The window function sees the multiplied rows. Rankings, counts, sums, and other calculations can therefore become incorrect. Validate the grain after each major join.
</details>

### Q11. When would you use `GROUP BY` instead of a window function?

<details>
<summary><strong>Answer</strong></summary>

When the final requirement only needs one row per group and no detail rows need to remain.
</details>

### Q12. How would you deduplicate CDC records?

<details>
<summary><strong>Answer</strong></summary>

Partition by the business key, order by the most recent update timestamp and a deterministic tie-breaker, assign `ROW_NUMBER()`, and keep `rn = 1`.
</details>

---

# 42. Quick Revision Cheat Sheet

| Function / Concept | Meaning |
|---|---|
| `OVER()` | Defines the window |
| `PARTITION BY` | Splits rows into independent windows |
| Window `ORDER BY` | Defines calculation order |
| `ROW_NUMBER()` | Unique sequence |
| `RANK()` | Ties + gaps |
| `DENSE_RANK()` | Ties + no gaps |
| `LAG()` | Previous row |
| `LEAD()` | Next row |
| `FIRST_VALUE()` | First value in window order |
| `LAST_VALUE()` | Last value according to frame/order |
| `ROWS` | Row-based frame |
| Running total | `SUM() OVER (...)` |
| Moving average | `AVG() OVER (...)` + frame |
| Top-N per group | Rank + outer filter |
| Deduplication | `ROW_NUMBER()` + business key |
| Change detection | `LAG()` + comparison |
| Next-event analysis | `LEAD()` + timestamp difference |
| Gaps & Islands | Window function + grouping logic |

---

# 43. What You Should Be Able to Explain in an Interview

Do not stop at syntax.

You should be able to explain:

> **What is a window function?**

A function that calculates across related rows while retaining the individual rows.

> **What does PARTITION BY do?**

It divides the input into independent windows and restarts the calculation for each partition.

> **What is the difference between ROW_NUMBER, RANK, and DENSE_RANK?**

`ROW_NUMBER()` gives unique numbers; `RANK()` gives ties the same rank with gaps; `DENSE_RANK()` gives ties the same rank without gaps.

> **What is LAG?**

It accesses a previous row in the window.

> **What is LEAD?**

It accesses a following row in the window.

> **Why use a CTE with ROW_NUMBER?**

To calculate the window result first and then filter it in an outer query.

> **What is the biggest practical use in Data Engineering?**

Deduplication/latest-record selection, change detection, event sequencing, ranking, and time-series calculations.

---

# 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — worked examples for the concepts above
- [`practice.sql`](./practice.sql) — interview-style exercises without solutions

> [!TIP]
> Do not memorize every query. Memorize the decision process: **What is my grain? What rows belong together? What is the ordering? Do I need ties? Do I need a frame? Do I need to filter after the window calculation?**
