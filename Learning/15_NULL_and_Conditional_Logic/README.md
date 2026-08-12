# 15 — NULL and Conditional Logic

## 📌 Overview

This topic covers two closely related SQL skills: handling missing/unknown values correctly and implementing business rules with conditional expressions. These are heavily used in ETL/ELT transformations, data-quality checks, warehouse loading, and metric calculations.

> `NULL` is not the same as `0`, an empty string, or `FALSE`.

## 🎯 Learning Objectives

- Understand NULL and three-valued logic.
- Use `IS NULL` / `IS NOT NULL` correctly.
- Understand NULL in comparisons, arithmetic, aggregates, and joins.
- Use `COALESCE()`, `IFNULL()`, and `NULLIF()` appropriately.
- Write searched and simple `CASE` expressions.
- Use MySQL `IF()` for simple conditions.
- Build NULL-safe transformations and data-quality flags.
- Use conditional aggregation for pipeline metrics.

---

## 🧠 1. NULL and Three-Valued Logic

NULL means missing, unknown, or not applicable.

```text
0          → numeric zero
''         → empty string
FALSE      → false
'NULL'     → text
NULL       → missing/unknown
```

SQL predicates can evaluate to `TRUE`, `FALSE`, or `UNKNOWN`.

```sql
SELECT NULL = NULL;
```

The result is UNKNOWN, not TRUE. Therefore this is incorrect:

```sql
WHERE manager_id = NULL
```

Use:

```sql
WHERE manager_id IS NULL
```

or:

```sql
WHERE manager_id IS NOT NULL
```

A `WHERE` clause retains only rows whose predicate evaluates to TRUE.

---

## 🧮 2. NULL in Arithmetic

Arithmetic involving NULL normally produces NULL.

```sql
SELECT salary + bonus AS total_compensation
FROM employees;
```

If `bonus` is NULL, the result is NULL.

If the business rule says a missing bonus means zero:

```sql
SELECT salary + COALESCE(bonus, 0) AS total_compensation
FROM employees;
```

Do not convert NULL to zero unless that is the intended business meaning.

---

## 📊 3. NULL and Aggregates

For values `100, 200, NULL`:

```text
COUNT(*)       → 3
COUNT(amount)  → 2
SUM(amount)    → 300
AVG(amount)    → 150
```

`COUNT(*)` counts rows. `COUNT(column)` counts non-NULL values. Most aggregate functions ignore NULL input values.

---

## 🛡️ 4. COALESCE()

Returns the first non-NULL expression.

```sql
SELECT
    COALESCE(phone, email, 'Not Available') AS contact_value
FROM customers;
```

Common ETL use:

```sql
SELECT
    COALESCE(country_code, 'UNKNOWN') AS country_code
FROM staging_customers;
```

`COALESCE()` changes the query result; it does not update the stored data.

### COALESCE vs IFNULL

| `COALESCE()` | `IFNULL()` |
|---|---|
| Standard SQL | MySQL-specific |
| Multiple expressions | Two expressions |
| Useful for portable SQL | Convenient for simple MySQL logic |

---

## 🔄 5. NULLIF()

`NULLIF(a, b)` returns NULL when `a = b`; otherwise it returns `a`.

### Safe division

```sql
SELECT
    revenue / NULLIF(order_count, 0) AS avg_order_value
FROM daily_metrics;
```

### Normalize empty text

```sql
SELECT
    NULLIF(TRIM(email), '') AS email
FROM staging_customers;
```

This converts empty or whitespace-only text to NULL.

---

## 🧩 6. CASE Expression

`CASE` is the main SQL construct for business rules.

```sql
SELECT
    employee_id,
    salary,
    CASE
        WHEN salary >= 100000 THEN 'HIGH'
        WHEN salary >= 60000 THEN 'MEDIUM'
        ELSE 'LOW'
    END AS salary_band
FROM employees;
```

`CASE` returns the first matching `WHEN`, so condition order matters.

This ordering is wrong for the intended bands:

```sql
CASE
    WHEN salary >= 60000 THEN 'MEDIUM'
    WHEN salary >= 100000 THEN 'HIGH'
END
```

A salary of 120000 matches the first condition.

---

## 🔀 7. Simple CASE vs Searched CASE

### Searched CASE

Use conditions, ranges, and compound rules:

```sql
CASE
    WHEN amount >= 10000 THEN 'LARGE'
    WHEN amount >= 1000 THEN 'MEDIUM'
    ELSE 'SMALL'
END
```

### Simple CASE

Compare one expression with discrete values:

```sql
CASE status
    WHEN 'A' THEN 'ACTIVE'
    WHEN 'I' THEN 'INACTIVE'
    ELSE 'UNKNOWN'
END
```

For NULL, use a searched condition:

```sql
CASE
    WHEN status IS NULL THEN 'MISSING'
    ELSE status
END
```

Do not use `WHEN NULL` as a NULL test.

---

## 🔀 8. IF()

MySQL provides:

```sql
SELECT
    IF(amount >= 10000, 'LARGE', 'SMALL') AS order_size
FROM orders;
```

Use `IF()` for simple two-way MySQL-specific logic. Prefer `CASE` for multiple conditions, complex business rules, and portable SQL.

---

## 🏗️ 9. Data-Quality Flags

```sql
SELECT
    customer_id,
    CASE
        WHEN customer_id IS NULL THEN 'MISSING_ID'
        WHEN email IS NULL OR TRIM(email) = '' THEN 'MISSING_EMAIL'
        ELSE 'VALID'
    END AS quality_status
FROM staging_customers;
```

This classifies records without silently deleting bad source data.

---

## 📊 10. Conditional Aggregation

Use `CASE` inside aggregates to calculate multiple metrics in one query.

```sql
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN status = 'ACTIVE' THEN 1 ELSE 0 END) AS active_rows,
    SUM(CASE WHEN status IS NULL THEN 1 ELSE 0 END) AS missing_status
FROM customers;
```

This pattern is useful for ETL validation, data-quality dashboards, and reconciliation.

---

## 🔄 11. NULL Normalization in ETL

```sql
SELECT
    customer_id,
    NULLIF(TRIM(email), '') AS email,
    COALESCE(country_code, 'UNKNOWN') AS country_code
FROM staging_customers;
```

These are separate business decisions:

```text
empty text             → NULL
missing country        → business-defined fallback
```

Do not use `'UNKNOWN'` merely to hide source-data problems.

---

## 🧮 12. NULL-Safe Metrics

For a ratio:

```sql
SELECT
    successful_orders / NULLIF(total_orders, 0) AS conversion_rate
FROM daily_metrics;
```

If the business explicitly defines zero orders as a displayed zero:

```sql
SELECT
    COALESCE(
        successful_orders / NULLIF(total_orders, 0),
        0
    ) AS conversion_rate
FROM daily_metrics;
```

The second query changes NULL to zero, so it should only be used when that meaning is correct.

---

## 🧠 13. Source-System Normalization

A common warehouse transformation is mapping inconsistent source values into one standard representation:

```sql
SELECT
    order_id,
    CASE
        WHEN status IN ('A', 'ACTIVE', '1') THEN 'ACTIVE'
        WHEN status IN ('I', 'INACTIVE', '0') THEN 'INACTIVE'
        WHEN status IS NULL OR TRIM(status) = '' THEN 'UNKNOWN'
        ELSE 'INVALID'
    END AS normalized_status
FROM staging_orders;
```

This is a practical use of `CASE`, NULL handling, and data-quality rules together.

---

## ⚠️ 14. Common Mistakes

- `column = NULL` instead of `column IS NULL`.
- Treating NULL as zero without a business rule.
- Putting broad `CASE` conditions before specific conditions.
- Using `WHEN NULL` instead of `WHEN column IS NULL`.
- Confusing `IFNULL()` with `NULLIF()`.
- Hiding bad source data with unconditional `'UNKNOWN'` replacements.
- Dividing by a denominator that can be zero.
- Using deeply nested `IF()` expressions when `CASE` is clearer.
- Forgetting that some source systems represent missing text as `''`.

---

## ⚡ 15. Performance Considerations

- Avoid unnecessary functions on indexed columns in filters and joins.
- Normalize source values once in staging instead of repeatedly downstream.
- Prefer clear, maintainable `CASE` logic over deeply nested expressions.
- Use conditional aggregation when several related metrics can be calculated in one scan.
- Use `EXPLAIN` for large production queries rather than assuming an expression is efficient.

Correctness and data semantics come before micro-optimization.

---

## 🎤 16. Interview-Focused Questions

### Q1. Why does `column = NULL` not work?

<details>
<summary><strong>Answer</strong></summary>

NULL represents an unknown value. Equality with NULL produces UNKNOWN rather than TRUE. Use `IS NULL` or `IS NOT NULL`.

</details>

### Q2. What is the difference between COALESCE and IFNULL?

<details>
<summary><strong>Answer</strong></summary>

`IFNULL()` accepts two expressions and is MySQL-specific. `COALESCE()` can evaluate multiple expressions and is standard SQL.

</details>

### Q3. What is the difference between IFNULL and NULLIF?

<details>
<summary><strong>Answer</strong></summary>

`IFNULL(a,b)` returns `b` when `a` is NULL. `NULLIF(a,b)` returns NULL when `a` equals `b`; otherwise it returns `a`.

</details>

### Q4. How do you prevent division by zero?

<details>
<summary><strong>Answer</strong></summary>

Wrap the denominator with `NULLIF()`:

```sql
revenue / NULLIF(order_count, 0)
```

</details>

### Q5. Why does CASE condition order matter?

<details>
<summary><strong>Answer</strong></summary>

The first matching `WHEN` wins. Overlapping rules therefore need to be ordered from highest priority or most specific to broader rules.

</details>

### Q6. When should you use CASE instead of IF()?

<details>
<summary><strong>Answer</strong></summary>

Use `IF()` for simple two-way MySQL-specific logic. Use `CASE` for multiple conditions, ranges, complex business rules, and portable SQL.

</details>

### Q7. How do you convert an empty string to NULL?

<details>
<summary><strong>Answer</strong></summary>

Use:

```sql
NULLIF(TRIM(email), '')
```

</details>

### Q8. How would you classify records with missing mandatory fields?

<details>
<summary><strong>Answer</strong></summary>

Use `CASE` with explicit NULL and empty-value checks, for example `WHEN customer_id IS NULL THEN 'MISSING_ID'`.

</details>

### Q9. How would you calculate multiple data-quality metrics in one query?

<details>
<summary><strong>Answer</strong></summary>

Use conditional aggregation:

```sql
SUM(CASE WHEN email IS NULL THEN 1 ELSE 0 END)
```

Multiple such expressions can be calculated in one query.

</details>

### Q10. Why is replacing every NULL with zero dangerous?

<details>
<summary><strong>Answer</strong></summary>

NULL may mean unknown or not applicable, while zero is a known value. Replacing NULL with zero can change the meaning of a metric.

</details>

### Q11. How would you normalize inconsistent source statuses?

<details>
<summary><strong>Answer</strong></summary>

Use a searched `CASE` expression to map all accepted source representations to a standardized warehouse value and explicitly handle NULL/empty/invalid values.

</details>

### Q12. How would you safely calculate a percentage when the denominator can be zero?

<details>
<summary><strong>Answer</strong></summary>

Use `numerator / NULLIF(denominator, 0)`. Decide separately whether a NULL result should remain NULL or be converted to zero.

</details>

### Q13. What is three-valued logic?

<details>
<summary><strong>Answer</strong></summary>

SQL predicates can be TRUE, FALSE, or UNKNOWN. NULL is the main reason UNKNOWN occurs, and WHERE retains only TRUE rows.

</details>

### Q14. How should NULL and empty strings be handled in a staging table?

<details>
<summary><strong>Answer</strong></summary>

First determine source semantics. If empty strings mean missing data, normalize with `NULLIF(TRIM(column), '')`. Preserve legitimate empty strings when they have a distinct meaning.

</details>

### Q15. Can conditional logic affect performance?

<details>
<summary><strong>Answer</strong></summary>

Yes. Expressions on indexed columns in filters or joins can reduce efficient index access. For large pipelines, normalize values earlier where practical and verify the execution plan with `EXPLAIN`.

</details>

---

## 🔄 Quick Revision

| Concept | Key Point |
|---|---|
| `NULL` | Missing/unknown/not-applicable value |
| `IS NULL` | Tests for NULL |
| `IS NOT NULL` | Tests for non-NULL |
| `COALESCE()` | First non-NULL value |
| `IFNULL()` | Replace NULL with a fallback |
| `NULLIF()` | Return NULL when values match |
| `CASE` | Multi-condition business logic |
| `IF()` | Simple MySQL two-way condition |
| Three-valued logic | TRUE / FALSE / UNKNOWN |
| Conditional aggregation | Aggregate with `CASE` |
| Safe division | `NULLIF()` on denominator |

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — practical NULL and conditional-logic examples
- [`practice.sql`](./practice.sql) — hands-on exercises and interview practice
