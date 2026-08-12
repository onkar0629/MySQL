# 07 — SELECT and Filtering

## 📌 Overview

`SELECT` and filtering are the foundation of SQL data retrieval. They teach you how to decide **what data to return**, **which rows qualify**, and **how SQL evaluates conditions**.

For a Data Engineer, this is one of the most frequently used parts of SQL. ETL and ELT jobs constantly filter source data, select required columns, identify incremental changes, validate records, and prepare datasets for downstream transformations.

---

## 🎯 Learning Objectives

By the end of this topic, you should be able to:

- Retrieve specific columns with `SELECT`.
- Understand when `SELECT *` is useful and when to avoid it.
- Create aliases and calculated columns.
- Filter rows using `WHERE`.
- Use comparison and logical operators.
- Use `IN`, `NOT IN`, `BETWEEN`, and `LIKE`.
- Handle `NULL` correctly.
- Remove duplicate result rows with `DISTINCT`.
- Understand operator precedence.
- Filter dates and timestamps safely.
- Understand logical query processing.
- Write filters that can make effective use of indexes.
- Apply filtering to Data Engineering scenarios.

---

## 🧠 1. What Does SELECT Do?

`SELECT` defines the expressions that appear in the result set.

```sql
SELECT customer_id, customer_name
FROM customers;
```

The query returns only the requested columns.

You can also select expressions:

```sql
SELECT
    customer_id,
    customer_name,
    salary * 12 AS annual_salary
FROM employees;
```

The expression is calculated when the query executes; it does not automatically create a new stored column.

---

## 🔎 2. SELECT *

`SELECT *` returns all columns from the selected table or result source.

```sql
SELECT *
FROM customers;
```

It is useful when:

- Exploring a table.
- Inspecting data during development.
- Quickly understanding a small dataset.

For production ETL, reporting, and APIs, explicit columns are generally safer:

```sql
SELECT
    customer_id,
    customer_name,
    city
FROM customers;
```

### Why avoid SELECT * in production?

If a source table gains a new column, a query using `*` can unexpectedly return additional data. It can also increase I/O, network transfer, and downstream schema instability.

---

## 🏷️ 3. Column Aliases

Aliases rename result columns without changing the table schema.

```sql
SELECT
    customer_name AS name,
    email AS customer_email
FROM customers;
```

Aliases are useful when:

- Building reports.
- Producing cleaner API output.
- Naming calculated expressions.
- Preparing a dataset for another transformation.

Example:

```sql
SELECT
    price * quantity AS line_total
FROM order_items;
```

---

## 🧮 4. Calculated Columns

SQL expressions can calculate values directly in the `SELECT` list.

```sql
SELECT
    product_name,
    price,
    price * 1.18 AS price_with_tax
FROM products;
```

Another example:

```sql
SELECT
    revenue,
    cost,
    revenue - cost AS profit
FROM daily_metrics;
```

These are **derived result columns**. They do not modify the stored table.

---

## 🔍 5. WHERE Clause

`WHERE` filters rows according to a condition.

```sql
SELECT *
FROM employees
WHERE department_id = 10;
```

Only rows for department `10` qualify.

A useful mental model is:

```text
Table rows
   ↓
WHERE condition
   ↓
Rows that qualify
   ↓
SELECT expressions
```

`WHERE` operates before grouping and aggregation in the logical query-processing model.

---

## ⚖️ 6. Comparison Operators

| Operator | Meaning |
|---|---|
| `=` | Equal |
| `<>` | Not equal |
| `!=` | Not equal |
| `>` | Greater than |
| `<` | Less than |
| `>=` | Greater than or equal |
| `<=` | Less than or equal |

Example:

```sql
SELECT *
FROM products
WHERE price >= 1000;
```

Multiple comparisons can be combined with logical operators.

---

## 🔗 7. AND

`AND` requires all conditions to evaluate to TRUE.

```sql
SELECT *
FROM employees
WHERE department_id = 10
  AND salary >= 80000;
```

The employee must satisfy both conditions.

Use `AND` when the business requirement says **all conditions must hold**.

---

## 🔀 8. OR

`OR` requires at least one condition to evaluate to TRUE.

```sql
SELECT *
FROM employees
WHERE department_id = 10
   OR department_id = 20;
```

The employee can belong to either department.

---

## 🚫 9. NOT

`NOT` negates a condition.

```sql
SELECT *
FROM products
WHERE NOT price < 500;
```

For complicated business rules, prefer explicit expressions and parentheses rather than making a condition difficult to read.

---

## 🧠 10. Operator Precedence

Consider:

```sql
WHERE department_id = 10
   OR department_id = 20
  AND salary > 80000;
```

`AND` has higher precedence than `OR`, so the condition is interpreted approximately as:

```sql
WHERE department_id = 10
   OR (department_id = 20 AND salary > 80000);
```

If the intended business rule is different, use parentheses:

```sql
WHERE (department_id = 10 OR department_id = 20)
  AND salary > 80000;
```

### Best practice

When business logic combines `AND` and `OR`, use parentheses to make the intended logic explicit.

---

## 📋 11. IN Operator

`IN` checks whether an expression matches one of several values.

```sql
SELECT *
FROM employees
WHERE department_id IN (10, 20, 30);
```

This is usually clearer than:

```sql
WHERE department_id = 10
   OR department_id = 20
   OR department_id = 30;
```

---

## 🚫 12. NOT IN

`NOT IN` excludes values from a list.

```sql
SELECT *
FROM employees
WHERE department_id NOT IN (10, 20, 30);
```

### Important NULL warning

If the comparison expression or the `NOT IN` list contains `NULL`, SQL's three-valued logic can cause unexpected results.

For anti-join logic involving nullable data, `NOT EXISTS` is often safer.

---

## 📏 13. BETWEEN

`BETWEEN` tests an inclusive range.

```sql
SELECT *
FROM products
WHERE price BETWEEN 500 AND 2000;
```

This includes:

```text
500
2000
```

### Equivalent logic

```sql
WHERE price >= 500
  AND price <= 2000
```

The inclusive behavior matters when defining business ranges.

---

## 📅 14. BETWEEN with Dates

For a `DATE` column, an inclusive range can be appropriate:

```sql
WHERE order_date BETWEEN '2026-08-01' AND '2026-08-31'
```

For a `DATETIME` column, prefer a half-open interval:

```sql
WHERE created_at >= '2026-08-01'
  AND created_at <  '2026-09-01'
```

This captures the entire month without depending on a final timestamp such as `23:59:59`.

---

## 🔤 15. LIKE

`LIKE` performs pattern matching.

Two important wildcard characters are:

| Pattern | Meaning |
|---|---|
| `%` | Zero or more characters |
| `_` | Exactly one character |

Example:

```sql
SELECT *
FROM customers
WHERE customer_name LIKE 'A%';
```

This matches values beginning with `A`.

Another example:

```sql
SELECT *
FROM customers
WHERE email LIKE '%@gmail.com';
```

This matches values ending with `@gmail.com`.

---

## 🔎 16. LIKE Patterns

### Starts with

```sql
WHERE name LIKE 'A%'
```

### Ends with

```sql
WHERE name LIKE '%son'
```

### Contains

```sql
WHERE name LIKE '%ar%'
```

### Exactly one unknown character

```sql
WHERE code LIKE 'A_1'
```

The exact case-sensitivity behavior of `LIKE` depends on the expression's character set/collation, so do not assume every MySQL environment behaves identically.

---

## NULL 17. Understanding NULL

`NULL` means a value is missing, unknown, or not applicable.

It is not:

```text
0
''
FALSE
'NULL'
```

This is incorrect:

```sql
WHERE manager_id = NULL
```

Correct:

```sql
WHERE manager_id IS NULL
```

And:

```sql
WHERE manager_id IS NOT NULL
```

### Why?

SQL uses three-valued logic:

```text
TRUE
FALSE
UNKNOWN
```

Comparing an unknown value with ordinary equality does not produce TRUE.

---

## 🧮 18. DISTINCT

`DISTINCT` removes duplicate result rows.

```sql
SELECT DISTINCT department_id
FROM employees;
```

With multiple expressions, uniqueness applies to the **combination**:

```sql
SELECT DISTINCT department_id, job_title
FROM employees;
```

It is not equivalent to saying “make only the first column unique.”

---

## 🔬 19. DISTINCT Does Not Find Duplicate Records

This query:

```sql
SELECT DISTINCT email
FROM customers;
```

returns unique email values.

To find duplicate emails, use aggregation instead:

```sql
SELECT
    email,
    COUNT(*) AS occurrence_count
FROM customers
WHERE email IS NOT NULL
GROUP BY email
HAVING COUNT(*) > 1;
```

This distinction is important in Data Quality work.

---

## 🧠 20. Logical Query Processing

A simplified logical order for the concepts covered so far is:

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

This is a **logical processing model**, not a literal description of every physical operation performed by the MySQL optimizer.

Understanding the logical order helps explain why a `SELECT` alias generally cannot be referenced in the same query's `WHERE` clause.

---

## 🏷️ 21. Why SELECT Aliases Usually Cannot Be Used in WHERE

This is generally invalid:

```sql
SELECT
    price * 1.18 AS final_price
FROM products
WHERE final_price > 1000;
```

A common solution is to use a derived table:

```sql
SELECT *
FROM (
    SELECT
        product_name,
        price * 1.18 AS final_price
    FROM products
) AS p
WHERE final_price > 1000;
```

This works because the outer query can filter the derived result.

---

## ⚡ 22. Sargable Filtering

A predicate is often called **sargable** when it can make effective use of an index.

Suppose `created_at` is indexed.

Prefer:

```sql
WHERE created_at >= '2026-08-01'
  AND created_at <  '2026-09-01'
```

over patterns that apply a function directly to the indexed column, such as:

```sql
WHERE DATE(created_at) = '2026-08-01'
```

The second form may prevent efficient use of a normal index on `created_at`.

Always verify actual behavior with `EXPLAIN` rather than assuming.

---

## 🏗️ 23. Filtering in Data Engineering

Filtering is everywhere in ETL and ELT pipelines.

### Incremental extraction

```sql
SELECT
    order_id,
    customer_id,
    updated_at
FROM source_orders
WHERE updated_at >= '2026-08-12 00:00:00'
  AND updated_at <  '2026-08-13 00:00:00';
```

### Data-quality filtering

```sql
SELECT *
FROM staging_customers
WHERE email IS NULL
   OR customer_id IS NULL;
```

### Active records

```sql
SELECT *
FROM customers
WHERE status = 'ACTIVE';
```

### Quarantine invalid records

```sql
INSERT INTO rejected_orders
SELECT *
FROM staging_orders
WHERE order_amount < 0;
```

Filtering therefore controls which records move through the pipeline.

---

## 🕒 24. Incremental Data and Watermarks

A common pipeline pattern is to store the last successfully processed timestamp.

```text
Previous watermark
       ↓
Extract rows after watermark
       ↓
Process data
       ↓
Validate success
       ↓
Advance watermark
```

A half-open range is useful:

```sql
WHERE updated_at >= :start_watermark
  AND updated_at <  :end_watermark
```

The correct design must account for late-arriving records, duplicate events, clock differences, and retry behavior.

---

## 🌎 25. Real-World Example

Suppose the business asks:

> Find active premium customers in Mumbai whose lifetime spend is at least ₹100,000.

```sql
SELECT
    customer_id,
    customer_name,
    lifetime_spend
FROM customers
WHERE status = 'ACTIVE'
  AND segment = 'PREMIUM'
  AND city = 'Mumbai'
  AND lifetime_spend >= 100000;
```

The important part is translating each business rule into an explicit predicate.

---

## ⚠️ 26. Common Mistakes

### Mistake 1 — `= NULL`

Use `IS NULL`.

### Mistake 2 — Forgetting `BETWEEN` is inclusive

Use explicit half-open ranges when the business requirement needs them.

### Mistake 3 — Mixing AND and OR without parentheses

Make business logic explicit.

### Mistake 4 — Misusing `NOT IN` with NULL

Consider `NOT EXISTS` for nullable anti-join scenarios.

### Mistake 5 — Using `SELECT *` everywhere

Select only the required columns in production pipelines.

### Mistake 6 — Treating DISTINCT as duplicate detection

Use `GROUP BY ... HAVING COUNT(*) > 1` to identify duplicates.

### Mistake 7 — Applying functions to indexed columns without checking the plan

This can reduce index effectiveness.

### Mistake 8 — Using an unsafe datetime upper bound

Prefer:

```sql
>= start
AND < next_boundary
```

---

## ⚡ 27. Performance Considerations

Filtering can have a major effect on query performance.

Consider:

- Index columns frequently used for selective filters.
- Use appropriate data types.
- Avoid unnecessary `SELECT *` retrieval.
- Prefer sargable predicates when possible.
- Check execution plans with `EXPLAIN`.
- Be careful with leading `%` in `LIKE` patterns because normal B-tree indexes generally cannot efficiently seek to an unknown starting position.
- Avoid unnecessary functions on indexed columns.
- Filter early in logical query design when appropriate, while remembering that the optimizer can transform the physical execution plan.

Performance is workload-dependent; always validate with actual data and an execution plan.

---

## 🎤 28. Interview-Focused Questions

### Q1. What is the difference between SELECT and WHERE?

<details>
<summary><strong>Answer</strong></summary>

`SELECT` determines which expressions appear in the result. `WHERE` determines which rows qualify for the query. In the logical processing model, filtering occurs before the final SELECT projection.

</details>

---

### Q2. Why can't we use `= NULL` in SQL?

<details>
<summary><strong>Answer</strong></summary>

`NULL` represents an unknown or missing value. A comparison such as `column = NULL` evaluates to UNKNOWN rather than TRUE. SQL therefore uses `IS NULL` and `IS NOT NULL` for NULL checks.

</details>

---

### Q3. What is the difference between IN and OR?

<details>
<summary><strong>Answer</strong></summary>

Both can express membership in a set of values. `IN` is usually clearer when one expression is compared with several constants. Separate `OR` predicates are useful when each branch contains different logic.

</details>

---

### Q4. Is BETWEEN inclusive in MySQL?

<details>
<summary><strong>Answer</strong></summary>

Yes. `BETWEEN a AND b` includes both boundary values. For datetime ranges, a half-open interval is often safer because it avoids ambiguity around the final timestamp of a period.

</details>

---

### Q5. What is the difference between DISTINCT and GROUP BY?

<details>
<summary><strong>Answer</strong></summary>

`DISTINCT` removes duplicate result rows. `GROUP BY` creates groups and is commonly paired with aggregate functions. A grouped query can sometimes reproduce a distinct result, but the concepts serve different purposes.

</details>

---

### Q6. Why can NOT IN produce unexpected results with NULL?

<details>
<summary><strong>Answer</strong></summary>

SQL uses three-valued logic. A NULL in the comparison set can make the overall predicate UNKNOWN, causing rows to be excluded. `NOT EXISTS` is often a safer anti-join pattern when nullable data is involved.

</details>

---

### Q7. How would you filter an entire month from a DATETIME column?

<details>
<summary><strong>Answer</strong></summary>

Use a half-open range:

```sql
WHERE created_at >= '2026-08-01'
  AND created_at <  '2026-09-01'
```

This includes every timestamp in August without depending on a final time such as `23:59:59`.

</details>

---

### Q8. What is the difference between `%` and `_` in LIKE?

<details>
<summary><strong>Answer</strong></summary>

`%` matches zero or more characters, while `_` matches exactly one character. For example, `A%` can match `A`, `Asha`, or `Arjun`, while `A_` matches a two-character value beginning with `A`.

</details>

---

### Q9. Why is SELECT * usually discouraged in production pipelines?

<details>
<summary><strong>Answer</strong></summary>

It can retrieve unnecessary columns, increase I/O and network transfer, and make downstream behavior change when the source schema changes. Explicit columns make dependencies clear and stable.

</details>

---

### Q10. What is a sargable predicate?

<details>
<summary><strong>Answer</strong></summary>

A sargable predicate is a condition that can be evaluated in a way that allows an appropriate index to be used effectively. For example, a range condition directly on an indexed datetime column is often more index-friendly than applying `DATE()` to that column.

</details>

---

### Q11. How would you identify duplicate emails?

<details>
<summary><strong>Answer</strong></summary>

Use grouping and filter groups with more than one row:

```sql
SELECT email, COUNT(*) AS cnt
FROM customers
WHERE email IS NOT NULL
GROUP BY email
HAVING COUNT(*) > 1;
```

`DISTINCT` would only return unique values; it would not tell you how many times each value occurs.

</details>

---

### Q12. How would you build an incremental extraction query?

<details>
<summary><strong>Answer</strong></summary>

Use a reliable watermark such as `updated_at` and a clearly defined boundary:

```sql
WHERE updated_at >= :start_watermark
  AND updated_at <  :end_watermark
```

The pipeline should also account for late-arriving data, retries, duplicate events, and how the watermark advances after successful processing.

</details>

---

### Q13. What is the difference between filtering in WHERE and filtering after aggregation?

<details>
<summary><strong>Answer</strong></summary>

`WHERE` filters individual rows before grouping. Conditions on aggregate results such as `COUNT(*) > 5` require `HAVING` after `GROUP BY`. Choosing the correct stage avoids incorrect results and unnecessary processing.

</details>

---

### Q14. How would you filter rows where a value is either NULL or empty?

<details>
<summary><strong>Answer</strong></summary>

Use an explicit condition such as:

```sql
WHERE phone IS NULL
   OR phone = ''
```

For whitespace-only values, consider normalization such as `TRIM()` while being mindful of index and performance implications.

</details>

---

## 🔄 29. Quick Revision

| Concept | Key Point |
|---|---|
| `SELECT` | Chooses result expressions |
| `WHERE` | Filters rows |
| `DISTINCT` | Removes duplicate result rows |
| `IN` | Checks membership |
| `NOT IN` | Excludes listed values; watch NULL |
| `BETWEEN` | Inclusive range |
| `LIKE` | Pattern matching |
| `%` | Zero or more characters |
| `_` | Exactly one character |
| `IS NULL` | Tests for NULL |
| `AND` | All conditions must hold |
| `OR` | At least one condition holds |
| `NOT` | Negates a condition |
| Sargable filter | More index-friendly predicate form |
| Half-open range | `>= start AND < next_boundary` |

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — worked examples for SELECT, expressions, filtering, NULL, DISTINCT, and dates
- [`practice.sql`](./practice.sql) — hands-on exercises, Data Engineering scenarios, and interview practice
