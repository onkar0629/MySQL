# 14 — NULL and NULL Handling

## 📌 Overview

`NULL` is one of the most important concepts in SQL because it represents **missing, unknown, or not-applicable information**. It is not the same as `0`, an empty string, or the text `'NULL'`.

Incorrect NULL handling is a common source of bugs in filtering, joins, aggregates, calculations, and Data Engineering pipelines.

This topic focuses on the practical NULL behavior you need for MySQL, SQL interviews, and production data work.

---

## 🎯 Learning Objectives

- Understand what `NULL` represents.
- Understand SQL three-valued logic.
- Use `IS NULL` and `IS NOT NULL` correctly.
- Understand how `NULL` behaves with comparisons and arithmetic.
- Use `COALESCE()` and `IFNULL()` appropriately.
- Use `NULLIF()` for safe calculations.
- Understand NULL behavior in aggregates.
- Understand NULL in joins and filtering.
- Handle NULL safely with `NOT IN` and `NOT EXISTS`.
- Distinguish missing, unknown, zero, and empty values.
- Apply NULL handling to ETL and data-quality problems.

---

## 🧠 1. What Is NULL?

`NULL` means that a value is absent, unknown, or not applicable according to the data model.

These are different values:

```text
NULL       → no value / unknown
0          → numeric zero
''         → empty string
'NULL'     → text containing NULL
FALSE      → boolean false
```

Example:

```sql
SELECT *
FROM employees
WHERE manager_id IS NULL;
```

This finds employees for whom no manager value is stored.

---

## ⚠️ 2. NULL Is Not Equal to NULL

This does **not** work as a NULL test:

```sql
WHERE manager_id = NULL
```

Use:

```sql
WHERE manager_id IS NULL
```

And for non-NULL values:

```sql
WHERE manager_id IS NOT NULL
```

Why? Because NULL represents an unknown value, so ordinary equality cannot establish that two NULLs are equal.

---

## 🧠 3. Three-Valued Logic

SQL conditions can evaluate to:

```text
TRUE
FALSE
UNKNOWN
```

For example:

```sql
SELECT 10 = NULL;
```

The result is UNKNOWN.

A `WHERE` clause keeps rows only when its predicate evaluates to TRUE. UNKNOWN therefore behaves differently from FALSE during filtering.

### Practical example

If `bonus` is NULL:

```sql
WHERE bonus > 1000
```

cannot determine that the condition is true, so that row is not returned.

---

## 🔍 4. IS NULL and IS NOT NULL

Use `IS NULL`:

```sql
SELECT *
FROM customers
WHERE email IS NULL;
```

Use `IS NOT NULL`:

```sql
SELECT *
FROM customers
WHERE email IS NOT NULL;
```

These are the standard predicates for testing NULL.

---

## 🧮 5. NULL in Arithmetic

Arithmetic involving NULL normally produces NULL.

```sql
SELECT salary + bonus AS total_salary
FROM employees;
```

If:

```text
salary = 80000
bonus  = NULL
```

then `salary + bonus` is NULL.

If the business rule says missing bonus means zero:

```sql
SELECT
    salary + COALESCE(bonus, 0) AS total_salary
FROM employees;
```

Do not convert NULL to zero automatically. The correct treatment depends on the meaning of the field.

---

## 🔄 6. COALESCE()

`COALESCE()` returns the first non-NULL expression.

```sql
SELECT
    COALESCE(phone, email, 'NO CONTACT') AS contact_value
FROM customers;
```

Evaluation:

```text
phone available → use phone
phone NULL      → try email
both NULL       → use NO CONTACT
```

### Common use

```sql
SELECT COALESCE(discount, 0)
FROM order_items;
```

This is appropriate when the business definition says a missing discount should be treated as zero.

---

## 🔁 7. IFNULL()

MySQL also provides `IFNULL()`:

```sql
SELECT IFNULL(phone, 'UNKNOWN')
FROM customers;
```

It accepts two arguments:

```text
IFNULL(value, fallback)
```

`COALESCE()` is more general because it can evaluate multiple alternatives:

```sql
COALESCE(phone, email, address, 'UNKNOWN')
```

For portable SQL, `COALESCE()` is generally preferable.

---

## 🛡️ 8. NULLIF()

`NULLIF(a, b)` returns NULL when `a = b`; otherwise it returns `a`.

The most useful pattern is preventing division by zero:

```sql
SELECT
    revenue / NULLIF(order_count, 0) AS average_order_value
FROM metrics;
```

If `order_count = 0`:

```text
NULLIF(0, 0) → NULL
revenue / NULL → NULL
```

This is safer than allowing an invalid zero denominator.

---

## 📊 9. NULL and COUNT

Consider:

```text
bonus
-----
5000
NULL
3000
```

Then:

```sql
SELECT
    COUNT(*) AS row_count,
    COUNT(bonus) AS non_null_bonus_count
FROM employees;
```

returns conceptually:

```text
row_count              = 3
non_null_bonus_count   = 2
```

`COUNT(*)` counts rows.

`COUNT(column)` counts non-NULL values of that expression.

---

## 💰 10. NULL and SUM / AVG / MIN / MAX

Most aggregate functions ignore NULL input values.

For:

```text
amount
------
100
200
NULL
```

results are:

```text
SUM(amount) = 300
AVG(amount) = 150
MIN(amount) = 100
MAX(amount) = 200
```

If every input value is NULL, these aggregates generally return NULL rather than zero.

To return zero where the business definition requires it:

```sql
COALESCE(SUM(amount), 0)
```

---

## 🔢 11. COUNT(DISTINCT) and NULL

`COUNT(DISTINCT column)` counts unique non-NULL values.

For:

```text
customer_id
-----------
101
101
102
NULL
```

```sql
SELECT COUNT(DISTINCT customer_id)
FROM orders;
```

returns:

```text
2
```

The NULL value does not contribute to the count.

---

## 🔗 12. NULL in JOIN Conditions

A normal equality join does not match NULL to NULL:

```sql
SELECT *
FROM a
JOIN b
    ON a.code = b.code;
```

If both `a.code` and `b.code` are NULL, the equality condition is UNKNOWN, not TRUE.

This matters when NULL is a valid business state and you expect NULL-valued records to match.

### NULL-safe equality in MySQL

MySQL provides the NULL-safe equality operator:

```sql
ON a.code <=> b.code
```

Unlike `=`, `<=>` returns TRUE when both operands are NULL.

Use it deliberately when NULL-to-NULL matching is actually part of the business rule.

---

## ⚠️ 13. NOT IN and NULL

This is a classic interview problem.

Suppose a subquery returns:

```text
10
20
NULL
```

Then:

```sql
WHERE department_id NOT IN (
    SELECT department_id
    FROM excluded_departments
)
```

can produce unexpected results because the NULL introduces UNKNOWN comparisons.

A safer anti-join pattern is often:

```sql
WHERE NOT EXISTS (
    SELECT 1
    FROM excluded_departments e
    WHERE e.department_id = employees.department_id
)
```

Always consider NULLability when writing `NOT IN` against a subquery.

---

## 🔎 14. NULL in CASE

`CASE` can explicitly classify NULL values.

```sql
SELECT
    CASE
        WHEN email IS NULL THEN 'MISSING'
        WHEN email = '' THEN 'EMPTY'
        ELSE 'PRESENT'
    END AS email_status
FROM customers;
```

This is useful for data-quality reporting.

---

## 🧹 15. NULL vs Empty String

Do not assume these mean the same thing:

```text
NULL
''
```

For example:

```sql
WHERE phone IS NULL
```

finds missing phone values, while:

```sql
WHERE phone = ''
```

finds stored empty strings.

If the source system inconsistently uses both representations, normalize them deliberately.

Example:

```sql
NULLIF(TRIM(phone), '')
```

This converts an empty or whitespace-only string to NULL.

---

## 🧪 16. Data-Quality Profiling

NULL handling is central to profiling source data.

### Count NULL values

```sql
SELECT
    SUM(CASE WHEN email IS NULL THEN 1 ELSE 0 END) AS null_email_count,
    SUM(CASE WHEN phone IS NULL THEN 1 ELSE 0 END) AS null_phone_count
FROM customers;
```

### Calculate NULL percentage

```sql
SELECT
    100.0 * SUM(CASE WHEN email IS NULL THEN 1 ELSE 0 END)
    / NULLIF(COUNT(*), 0) AS null_email_pct
FROM customers;
```

The `NULLIF()` protects the denominator if the input table contains zero rows.

---

## 🏗️ 17. NULL in ETL / ELT Pipelines

NULL can enter a pipeline through:

- Missing source fields
- Optional attributes
- Failed lookups
- Partial records
- Schema evolution
- Source-system inconsistencies
- Late-arriving dimension data

A pipeline should distinguish between:

```text
Expected NULL
      vs
Unexpected NULL
```

For example, a customer's middle name may legitimately be NULL, while a primary business key should normally not be NULL.

---

## 🔄 18. NULL During Dimension Lookups

Suppose a fact record references a customer that has not yet arrived in the dimension.

A lookup may produce NULL for the dimension key.

A production pipeline might instead use an explicit unknown-member key such as:

```text
customer_key = 0
```

The important point is that this is a **data-modeling decision**, not a universal rule.

Do not blindly replace every NULL with `0`.

---

## 🧠 19. NULL in Filtering Logic

Consider:

```sql
SELECT *
FROM employees
WHERE salary <> 50000;
```

Employees with `salary = NULL` are not returned because:

```text
NULL <> 50000 → UNKNOWN
```

If you want both non-50000 salaries and missing salaries, write the rule explicitly:

```sql
WHERE salary <> 50000
   OR salary IS NULL;
```

This is a common source of incorrect row counts.

---

## 🧮 20. NULL in Boolean Logic

Important examples:

```text
TRUE  AND UNKNOWN → UNKNOWN
FALSE AND UNKNOWN → FALSE
TRUE  OR  UNKNOWN → TRUE
FALSE OR  UNKNOWN → UNKNOWN
NOT UNKNOWN       → UNKNOWN
```

You do not need to memorize every truth-table combination, but you must understand that UNKNOWN is not simply FALSE.

This becomes especially important when combining nullable predicates.

---

## 🏭 21. Practical Data Engineering Example

Business rule:

> Reject orders where customer ID is missing or amount is negative, but allow NULL shipping instructions.

```sql
SELECT *
FROM staging_orders
WHERE customer_id IS NULL
   OR amount < 0;
```

Notice that `shipping_instructions` does not appear in the rejection condition because NULL is acceptable for that attribute.

This demonstrates why NULL handling must follow the **data contract**, not a blanket rule that all NULLs are bad.

---

## ⚡ 22. Performance Considerations

NULL handling itself is usually not the main performance concern. The important issues are predicate design, indexes, joins, and data volume.

Consider:

- Keep filtering predicates index-friendly.
- Avoid wrapping indexed columns in unnecessary functions.
- Use appropriate indexes for frequent `IS NULL` / `IS NOT NULL` access patterns when the workload benefits from them.
- Avoid unnecessary `DISTINCT` after joins used to compensate for incorrect join logic.
- Check execution plans with `EXPLAIN` for large tables.

Correctness comes first; optimize after measuring the workload.

---

## ⚠️ 23. Common Mistakes

- Using `= NULL` instead of `IS NULL`.
- Assuming NULL means zero.
- Assuming NULL means empty string.
- Treating all NULLs as data-quality errors.
- Forgetting that `COUNT(column)` ignores NULL.
- Assuming `SUM()` of no non-NULL values is zero.
- Using `NOT IN` against nullable subquery results.
- Expecting NULL values to match with `=` in a JOIN.
- Replacing every NULL with a default without understanding the business meaning.
- Forgetting NULL rows when calculating percentages or rejection counts.

---

## 🎤 24. Interview-Focused Questions

### Q1. What is NULL in SQL?

<details>
<summary><strong>Answer</strong></summary>

NULL represents missing, unknown, or not-applicable information. It is not zero, an empty string, FALSE, or the text `'NULL'`.

</details>

---

### Q2. Why does `column = NULL` not work?

<details>
<summary><strong>Answer</strong></summary>

A comparison involving NULL produces UNKNOWN rather than TRUE or FALSE. SQL therefore provides `IS NULL` and `IS NOT NULL` for NULL testing.

</details>

---

### Q3. What is three-valued logic?

<details>
<summary><strong>Answer</strong></summary>

SQL predicates can evaluate to TRUE, FALSE, or UNKNOWN. UNKNOWN commonly occurs when NULL participates in a comparison. A WHERE clause returns only rows for which the predicate is TRUE.

</details>

---

### Q4. What is the difference between COUNT(*) and COUNT(column) when NULL exists?

<details>
<summary><strong>Answer</strong></summary>

`COUNT(*)` counts rows, including rows whose columns contain NULL. `COUNT(column)` counts only rows where that expression is non-NULL.

</details>

---

### Q5. How do you replace NULL with a default value?

<details>
<summary><strong>Answer</strong></summary>

Use `COALESCE()` or MySQL's `IFNULL()`:

```sql
COALESCE(phone, 'UNKNOWN')
```

Use a default only when it has the correct business meaning.

</details>

---

### Q6. What is the difference between COALESCE and IFNULL?

<details>
<summary><strong>Answer</strong></summary>

`IFNULL()` is a MySQL-specific two-argument function. `COALESCE()` can evaluate multiple expressions and is part of standard SQL. `COALESCE()` is generally more portable.

</details>

---

### Q7. Why is NULLIF useful in Data Engineering?

<details>
<summary><strong>Answer</strong></summary>

It is useful for converting a problematic value to NULL, especially zero denominators. For example, `revenue / NULLIF(order_count, 0)` prevents division by zero.

</details>

---

### Q8. Does SUM treat NULL as zero?

<details>
<summary><strong>Answer</strong></summary>

`SUM()` ignores NULL input values; it does not literally convert them to zero. If all input values are NULL or there are no qualifying non-NULL values, the aggregate result can be NULL. Use `COALESCE` if the output must be zero.

</details>

---

### Q9. Why can NOT IN fail when the subquery contains NULL?

<details>
<summary><strong>Answer</strong></summary>

NULL introduces UNKNOWN into the comparison logic. This can prevent rows from satisfying the `NOT IN` predicate. `NOT EXISTS` is often safer for anti-join logic involving nullable columns.

</details>

---

### Q10. Do NULL values match in an equality JOIN?

<details>
<summary><strong>Answer</strong></summary>

No. `NULL = NULL` is UNKNOWN, so ordinary equality does not match two NULLs. MySQL provides the NULL-safe equality operator `<=>` when NULL-to-NULL matching is required.

</details>

---

### Q11. How would you count NULL emails?

<details>
<summary><strong>Answer</strong></summary>

Use either:

```sql
SELECT COUNT(*)
FROM customers
WHERE email IS NULL;
```

or conditional aggregation when calculating several quality metrics together.

</details>

---

### Q12. How would you calculate the percentage of NULL emails?

<details>
<summary><strong>Answer</strong></summary>

For example:

```sql
SELECT
    100.0 * SUM(CASE WHEN email IS NULL THEN 1 ELSE 0 END)
    / NULLIF(COUNT(*), 0) AS null_email_pct
FROM customers;
```

`NULLIF` protects against division by zero.

</details>

---

### Q13. Should NULL always be replaced with a default value in an ETL pipeline?

<details>
<summary><strong>Answer</strong></summary>

No. NULL can be a valid business state. Replacement should follow the source contract and target data model. For example, a missing optional attribute may remain NULL, while an unknown dimension member may use a deliberately defined surrogate key.

</details>

---

### Q14. How would you distinguish NULL from an empty string?

<details>
<summary><strong>Answer</strong></summary>

Use separate predicates:

```sql
column IS NULL
```

for NULL and:

```sql
column = ''
```

for an empty string. If the source uses both inconsistently, normalize them deliberately, for example with `NULLIF(TRIM(column), '')`.

</details>

---

### Q15. What happens to a NULL row when you use `WHERE salary <> 50000`?

<details>
<summary><strong>Answer</strong></summary>

The NULL row is not returned because `NULL <> 50000` evaluates to UNKNOWN, not TRUE. If NULL rows should also qualify, explicitly add `OR salary IS NULL`.

</details>

---

## 🔄 25. Quick Revision

| Concept | Key Point |
|---|---|
| `NULL` | Missing / unknown / not applicable |
| `IS NULL` | Tests for NULL |
| `IS NOT NULL` | Tests for non-NULL |
| Three-valued logic | TRUE / FALSE / UNKNOWN |
| `COALESCE()` | First non-NULL expression |
| `IFNULL()` | MySQL two-argument NULL fallback |
| `NULLIF()` | Returns NULL when two values are equal |
| `COUNT(*)` | Counts rows |
| `COUNT(column)` | Counts non-NULL values |
| `SUM()` | Ignores NULL inputs |
| `<=>` | MySQL NULL-safe equality |
| `NOT EXISTS` | Often safer than `NOT IN` with nullable data |

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — practical NULL-handling examples
- [`practice.sql`](./practice.sql) — NULL, data-quality, join, and interview exercises
