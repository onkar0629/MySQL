# 15 — NULL and Conditional Logic

## 📌 Overview

NULL represents missing, unknown, or unavailable data in MySQL. This topic covers three-valued logic and the conditional expressions used to safely transform NULL and business-rule-driven values.

## 🎯 Learning Objectives

- Understand NULL and why it is different from 0, an empty string, and FALSE.
- Use `IS NULL` and `IS NOT NULL` correctly.
- Understand three-valued logic: TRUE, FALSE, and UNKNOWN.
- Use `COALESCE()`, `IFNULL()`, `NULLIF()`, `IF()`, and `CASE`.
- Build robust conditional transformations for Data Engineering workloads.

## 📚 Concepts

### 1. NULL fundamentals

NULL means a value is absent or unknown. It cannot be compared with `=` or `<>`.

```sql
SELECT *
FROM employees
WHERE manager_id IS NULL;
```

### 2. Three-valued logic

Comparisons involving NULL generally evaluate to UNKNOWN. `WHERE` keeps only rows whose predicate evaluates to TRUE.

### 3. Replacing NULL

```sql
SELECT COALESCE(phone, 'Not Available') AS phone
FROM customers;
```

`COALESCE()` returns the first non-NULL expression.

### 4. Conditional logic with CASE

```sql
SELECT
    employee_id,
    CASE
        WHEN salary >= 100000 THEN 'High'
        WHEN salary >= 60000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_band
FROM employees;
```

### 5. NULL-safe transformations

Use `NULLIF()` when a specific value should be treated as NULL, for example a zero denominator.

```sql
SELECT revenue / NULLIF(order_count, 0) AS avg_order_value
FROM daily_metrics;
```

## 🌎 Real-World / Data Engineering Use Cases

- Handling missing source-system values.
- Preventing divide-by-zero errors in pipelines.
- Standardizing missing dimensions.
- Building data-quality flags.
- Categorizing records with business rules.
- Creating NULL-safe metrics and reconciliation queries.

## ⚠️ Common Mistakes

- Writing `column = NULL` instead of `column IS NULL`.
- Treating NULL as zero or an empty string.
- Forgetting that `NOT IN` behaves unexpectedly when the list contains NULL.
- Using `COUNT(column)` when `COUNT(*)` is required.
- Dividing by a nullable or zero value without `NULLIF()`.
- Assuming `COALESCE()` changes the stored data; it only changes the query result.

## 🎤 Interview-Focused Questions

### Q1. Why does `WHERE salary = NULL` return no rows?

<details>
<summary><strong>Answer</strong></summary>

NULL represents an unknown value, so `salary = NULL` evaluates to UNKNOWN rather than TRUE. Use `salary IS NULL` to test for NULL.

</details>

### Q2. What is the difference between `COUNT(*)` and `COUNT(column)` when NULLs exist?

<details>
<summary><strong>Answer</strong></summary>

`COUNT(*)` counts rows, while `COUNT(column)` counts only non-NULL values in that column.

</details>

### Q3. How would you prevent division by zero?

<details>
<summary><strong>Answer</strong></summary>

Use `NULLIF()` on the denominator:

```sql
SELECT revenue / NULLIF(order_count, 0)
FROM daily_metrics;
```

</details>

### Q4. What is the difference between `COALESCE()` and `IFNULL()`?

<details>
<summary><strong>Answer</strong></summary>

`IFNULL()` accepts two expressions, while `COALESCE()` can evaluate multiple expressions and returns the first non-NULL value. `COALESCE()` is also standard SQL.

</details>

### Q5. Why should you be careful with `NOT IN` and NULL?

<details>
<summary><strong>Answer</strong></summary>

If the subquery or list contains NULL, comparisons can become UNKNOWN, potentially causing expected rows to disappear. `NOT EXISTS` is often safer for anti-join logic.

</details>

### Q6. How can you classify customers based on spending?

<details>
<summary><strong>Answer</strong></summary>

Use a searched `CASE` expression with ordered business rules.

</details>

### Q7. How would you identify records with missing mandatory fields?

<details>
<summary><strong>Answer</strong></summary>

Use `IS NULL` conditions and combine them with `OR` when any mandatory field may be missing.

</details>

### Q8. How would you replace NULL values only in the query output?

<details>
<summary><strong>Answer</strong></summary>

Use `COALESCE()` or `IFNULL()` in the SELECT expression. This does not modify the underlying table.

</details>

### Q9. How would you convert an empty string to NULL?

<details>
<summary><strong>Answer</strong></summary>

Use `NULLIF(column, '')` and optionally combine it with `TRIM()` for whitespace-only values.

</details>

### Q10. How is conditional aggregation useful in Data Engineering?

<details>
<summary><strong>Answer</strong></summary>

It allows multiple data-quality or business metrics to be calculated in one grouped query, for example counting valid, invalid, late, or missing records using `SUM(CASE WHEN ... THEN 1 ELSE 0 END)`.

</details>

## 🔄 Quick Revision

```text
NULL test       → IS NULL / IS NOT NULL
Replace NULL    → COALESCE / IFNULL
Convert to NULL → NULLIF
Conditional     → CASE / IF
Safe division   → denominator with NULLIF
Missing values  → do not treat NULL as 0 automatically
```

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — worked examples for NULL and conditional logic
- [`practice.sql`](./practice.sql) — hands-on exercises and interview practice
