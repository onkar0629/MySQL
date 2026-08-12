# 07 — SELECT and Filtering

## 📌 Overview

`SELECT` and filtering are the core of SQL data retrieval. This topic develops the ability to read data precisely, filter rows using business conditions, handle `NULL`, remove duplicates, and build clear, predictable queries.

## 🎯 Learning Objectives

By the end of this topic, you should be able to:

- Retrieve specific columns with `SELECT`
- Use `SELECT *` appropriately
- Filter rows with `WHERE`
- Use comparison and logical operators
- Work correctly with `NULL`
- Use `DISTINCT`
- Filter with `IN`, `BETWEEN`, and `LIKE`
- Use `IS NULL` and `IS NOT NULL`
- Build readable conditional expressions
- Understand operator precedence
- Use aliases and expressions in result sets
- Apply filtering to realistic Data Engineering scenarios

---

## 1. Basic SELECT

```sql
SELECT customer_id, customer_name
FROM customers;
```

`SELECT` determines which expressions or columns appear in the result set.

### SELECT all columns

```sql
SELECT *
FROM customers;
```

`SELECT *` is useful for exploration, but explicitly naming required columns is usually better in production queries.

---

## 2. Column Aliases

```sql
SELECT
    customer_name AS name,
    email AS customer_email
FROM customers;
```

Aliases improve readability and can rename output columns without changing the underlying schema.

---

## 3. Calculated Columns

```sql
SELECT
    product_name,
    price,
    price * 1.18 AS price_with_tax
FROM products;
```

SQL can calculate values directly in the `SELECT` list.

---

## 4. WHERE Clause

`WHERE` filters rows before the final result is returned.

```sql
SELECT *
FROM employees
WHERE department_id = 10;
```

Only rows satisfying the condition are returned.

---

## 5. Comparison Operators

| Operator | Meaning |
|---|---|
| `=` | Equal to |
| `<>` / `!=` | Not equal to |
| `>` | Greater than |
| `<` | Less than |
| `>=` | Greater than or equal to |
| `<=` | Less than or equal to |

Example:

```sql
SELECT *
FROM products
WHERE price >= 1000;
```

---

## 6. AND, OR and NOT

### AND

All conditions must be true.

```sql
SELECT *
FROM employees
WHERE department_id = 10
  AND salary >= 80000;
```

### OR

At least one condition must be true.

```sql
SELECT *
FROM employees
WHERE department_id = 10
   OR department_id = 20;
```

### NOT

Negates a condition.

```sql
SELECT *
FROM products
WHERE NOT price < 500;
```

### Use parentheses for clarity

```sql
WHERE department_id = 10
  AND (salary >= 80000 OR job_title = 'Senior Engineer')
```

Do not rely on memory when a condition becomes complex; use parentheses to make business logic explicit.

---

## 7. IN Operator

`IN` checks whether a value belongs to a list.

```sql
SELECT *
FROM employees
WHERE department_id IN (10, 20, 30);
```

This is usually cleaner than repeating multiple `OR` conditions.

### NOT IN

```sql
SELECT *
FROM employees
WHERE department_id NOT IN (10, 20, 30);
```

Be careful with `NULL` values and `NOT IN`; SQL's three-valued logic can produce unexpected results.

---

## 8. BETWEEN

`BETWEEN` checks an inclusive range.

```sql
SELECT *
FROM products
WHERE price BETWEEN 500 AND 2000;
```

The boundaries are included.

For dates, remember that `BETWEEN` is also inclusive, which can matter when a datetime column contains time components.

---

## 9. LIKE

`LIKE` performs pattern matching.

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

This returns names beginning with `A`.

```sql
SELECT *
FROM customers
WHERE email LIKE '%@gmail.com';
```

This returns values ending with `@gmail.com`.

---

## 10. NULL

`NULL` means the value is missing, unknown, or not applicable. It is not the same as zero or an empty string.

Incorrect:

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

`NULL` requires special operators because normal comparison with `NULL` produces an unknown result.

---

## 11. DISTINCT

`DISTINCT` removes duplicate result rows.

```sql
SELECT DISTINCT department_id
FROM employees;
```

For multiple columns, uniqueness is evaluated on the combination:

```sql
SELECT DISTINCT department_id, job_title
FROM employees;
```

`DISTINCT` does not mean “find duplicates”; it returns unique combinations from the selected expressions.

---

## 12. Filtering Dates

Use date literals carefully and prefer half-open ranges for datetime columns.

For a `DATE` column:

```sql
SELECT *
FROM orders
WHERE order_date BETWEEN '2026-08-01' AND '2026-08-31';
```

For a `DATETIME` column, this pattern is safer:

```sql
WHERE created_at >= '2026-08-01'
  AND created_at <  '2026-09-01'
```

The second pattern includes the entire month without depending on a particular end-of-day time.

---

## 13. Filtering with Expressions

Conditions can use calculations and functions.

```sql
SELECT *
FROM products
WHERE price * 1.18 > 1000;
```

However, applying functions or calculations to an indexed column can sometimes prevent efficient index usage. When performance matters, inspect the execution plan and consider a sargable predicate.

---

## 14. SELECT and WHERE Logical Processing

A simplified logical order is:

```text
FROM
  ↓
WHERE
  ↓
SELECT
```

This explains why a `SELECT` alias generally cannot be referenced in the `WHERE` clause of the same query.

```sql
SELECT price * 1.18 AS final_price
FROM products
WHERE final_price > 1000; -- generally invalid
```

Instead, repeat the expression or use a derived table/CTE when appropriate.

---

## 15. Data Engineering Perspective

Filtering is fundamental to ETL and ELT pipelines.

Common examples include:

- Extracting only records modified since the previous load
- Filtering invalid records into a quarantine dataset
- Selecting active customers
- Restricting source data to a business date range
- Identifying rows with missing mandatory attributes
- Selecting a subset of events for downstream processing

Example incremental filter:

```sql
SELECT *
FROM source_orders
WHERE updated_at >= '2026-08-12 00:00:00'
  AND updated_at <  '2026-08-13 00:00:00';
```

The exact incremental strategy depends on the source system, watermark design, late-arriving data, and pipeline requirements.

---

## 16. Common Mistakes

- Using `= NULL` instead of `IS NULL`
- Forgetting that `BETWEEN` is inclusive
- Misunderstanding `%` and `_` in `LIKE`
- Using `SELECT *` in production when only a few columns are needed
- Forgetting parentheses in complex `AND`/`OR` conditions
- Assuming `DISTINCT` operates on one column when multiple expressions are selected
- Ignoring `NULL` behavior with `NOT IN`
- Using an unsafe datetime upper bound
- Filtering after aggregation when `WHERE` should be used before aggregation
- Applying functions to indexed columns without considering performance

---

## 17. Interview-Focused Questions

### Q1. What is the difference between WHERE and HAVING?

<details>
<summary><strong>Answer</strong></summary>

`WHERE` filters rows before grouping and aggregation. `HAVING` filters groups after `GROUP BY` and is commonly used with aggregate conditions.

</details>

---

### Q2. Why can't we use = NULL in SQL?

<details>
<summary><strong>Answer</strong></summary>

`NULL` represents an unknown or missing value. Comparisons such as `= NULL` evaluate to `UNKNOWN`, not `TRUE`. SQL therefore provides `IS NULL` and `IS NOT NULL` for null checks.

</details>

---

### Q3. What is the difference between IN and OR?

<details>
<summary><strong>Answer</strong></summary>

Both can express membership in a set of values. `IN` is generally shorter and clearer when comparing one expression against a list of constants. Multiple `OR` conditions can be more appropriate when each condition is different.

</details>

---

### Q4. Is BETWEEN inclusive in MySQL?

<details>
<summary><strong>Answer</strong></summary>

Yes. `BETWEEN a AND b` includes both boundary values. This is important for numeric ranges and especially for datetime filtering.

</details>

---

### Q5. What is the difference between DISTINCT and GROUP BY?

<details>
<summary><strong>Answer</strong></summary>

`DISTINCT` removes duplicate result rows. `GROUP BY` forms groups and is commonly used with aggregate functions such as `COUNT`, `SUM`, and `AVG`. Some queries can produce similar results with either approach, but their purposes are different.

</details>

---

### Q6. Why can NOT IN produce unexpected results when NULL is present?

<details>
<summary><strong>Answer</strong></summary>

SQL uses three-valued logic. If the `NOT IN` list contains `NULL`, comparisons can become `UNKNOWN`, causing rows that appear to qualify to be excluded. `NOT EXISTS` is often safer for anti-join logic when nullable values are involved.

</details>

---

### Q7. How would you filter an entire month from a DATETIME column?

<details>
<summary><strong>Answer</strong></summary>

Prefer a half-open interval: `created_at >= '2026-08-01' AND created_at < '2026-09-01'`. This includes every timestamp in August and avoids problems caused by assuming a final timestamp such as `23:59:59`.

</details>

---

### Q8. What is the difference between % and _ in LIKE?

<details>
<summary><strong>Answer</strong></summary>

`%` matches zero or more characters, while `_` matches exactly one character. For example, `A%` matches any value beginning with A, while `A_` matches a two-character value beginning with A.

</details>

---

### Q9. Why might SELECT * be discouraged in production queries?

<details>
<summary><strong>Answer</strong></summary>

It can retrieve unnecessary data, increase network and processing costs, make downstream schemas less stable when columns change, and reduce clarity about which fields a pipeline actually depends on. Explicit columns are usually preferable.

</details>

---

### Q10. How would you identify rows with a missing value in a column?

<details>
<summary><strong>Answer</strong></summary>

Use `IS NULL`, for example `WHERE email IS NULL`. Do not use `email = NULL` because ordinary equality comparison does not return `TRUE` for `NULL`.

</details>

---

## 18. Quick Revision

| Concept | Key Point |
|---|---|
| `SELECT` | Chooses expressions/columns for the result |
| `WHERE` | Filters rows |
| `DISTINCT` | Removes duplicate result rows |
| `IN` | Checks membership in a list |
| `BETWEEN` | Inclusive range filter |
| `LIKE` | Pattern matching |
| `%` | Zero or more characters |
| `_` | One character |
| `IS NULL` | Checks for `NULL` |
| `AND` | All conditions must be true |
| `OR` | At least one condition must be true |
| `NOT` | Negates a condition |

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — worked examples for SELECT and filtering
- [`practice.sql`](./practice.sql) — hands-on exercises and interview practice
