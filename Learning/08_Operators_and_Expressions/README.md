# 08 — Operators and Expressions

## 📌 Overview

SQL operators are symbols or keywords used to compare values, combine conditions, perform arithmetic, test membership, and manipulate expressions.

This topic focuses on the operator patterns you need to write readable MySQL queries and solve real Data Engineering problems.

## 🎯 Learning Objectives

By the end of this topic, you should be able to:

- Use arithmetic, comparison, logical, and bitwise operators
- Understand operator precedence and parentheses
- Build expressions with columns, literals, and functions
- Use `IN`, `BETWEEN`, `LIKE`, and `IS NULL`
- Understand `=` versus `<>` and the effect of `NULL`
- Combine multiple conditions safely
- Recognize three-valued logic in SQL
- Write practical filtering and transformation expressions

---

## 1. What Is an SQL Expression?

An expression produces a value from columns, literals, operators, and functions.

```sql
SELECT salary * 12 AS annual_salary
FROM employees;
```

Here, `salary * 12` is an expression and `*` is an arithmetic operator.

---

## 2. Arithmetic Operators

| Operator | Meaning |
|---|---|
| `+` | Addition |
| `-` | Subtraction |
| `*` | Multiplication |
| `/` | Division |
| `%` | Modulo / remainder |

Example:

```sql
SELECT
    product_price,
    quantity,
    product_price * quantity AS line_total
FROM order_items;
```

### Division and Integer Results

MySQL's `/` performs division. `DIV` performs integer division.

```sql
SELECT 10 / 4 AS division_result,
       10 DIV 4 AS integer_result,
       10 % 4 AS remainder;
```

---

## 3. Comparison Operators

Comparison operators evaluate relationships between values.

| Operator | Meaning |
|---|---|
| `=` | Equal to |
| `<>` or `!=` | Not equal to |
| `>` | Greater than |
| `<` | Less than |
| `>=` | Greater than or equal to |
| `<=` | Less than or equal to |

Example:

```sql
SELECT *
FROM employees
WHERE salary >= 50000;
```

> [!IMPORTANT]
> Comparisons involving `NULL` do not return `TRUE` or `FALSE`; they evaluate to `UNKNOWN`. Use `IS NULL` or `IS NOT NULL` for null checks.

---

## 4. Logical Operators

Logical operators combine conditions.

### AND

Both conditions must be true.

```sql
WHERE department = 'Data Engineering'
  AND salary >= 60000
```

### OR

At least one condition must be true.

```sql
WHERE department = 'Data Engineering'
   OR department = 'Analytics'
```

### NOT

Negates a condition.

```sql
WHERE NOT status = 'inactive'
```

Parentheses should be used when mixing `AND` and `OR` so the intended logic is explicit.

---

## 5. Operator Precedence

When multiple operators appear in an expression, MySQL follows precedence rules.

For logical conditions, `AND` is evaluated before `OR`.

```sql
WHERE department = 'Data Engineering'
   OR department = 'Analytics'
  AND salary >= 60000
```

This is interpreted as:

```sql
WHERE department = 'Data Engineering'
   OR (department = 'Analytics' AND salary >= 60000)
```

If the business rule is different, use parentheses:

```sql
WHERE (department = 'Data Engineering'
    OR department = 'Analytics')
  AND salary >= 60000
```

**Best practice:** use parentheses whenever mixed logical operators could be misunderstood.

---

## 6. BETWEEN

`BETWEEN` checks whether a value is within an inclusive range.

```sql
WHERE salary BETWEEN 50000 AND 80000
```

This includes both boundary values.

It is equivalent to:

```sql
WHERE salary >= 50000
  AND salary <= 80000
```

### Date Warning

For timestamps, half-open ranges are usually safer:

```sql
WHERE created_at >= '2026-08-01'
  AND created_at <  '2026-09-01'
```

This avoids relying on an end-of-day timestamp.

---

## 7. IN and NOT IN

`IN` tests membership in a list of values.

```sql
WHERE department IN ('Data Engineering', 'Analytics', 'Finance')
```

`NOT IN` excludes values from the list.

```sql
WHERE status NOT IN ('cancelled', 'deleted')
```

> [!WARNING]
> `NOT IN` can produce surprising results when its list or subquery contains `NULL`. For nullable data, understand SQL's three-valued logic before using it.

---

## 8. LIKE

`LIKE` performs pattern matching.

| Pattern | Meaning |
|---|---|
| `%` | Zero or more characters |
| `_` | Exactly one character |

Examples:

```sql
WHERE customer_name LIKE 'A%'
```

Names beginning with `A`.

```sql
WHERE customer_name LIKE '%son'
```

Names ending with `son`.

```sql
WHERE customer_name LIKE '%data%'
```

Names containing `data`.

```sql
WHERE code LIKE 'A_1'
```

A three-character value beginning with `A` and ending with `1`.

---

## 9. NULL and Three-Valued Logic

SQL uses three logical states:

- `TRUE`
- `FALSE`
- `UNKNOWN`

`NULL` means a value is missing, unknown, or not applicable. It is not equal to zero or an empty string.

Incorrect:

```sql
WHERE manager_id = NULL
```

Correct:

```sql
WHERE manager_id IS NULL
```

Likewise:

```sql
WHERE manager_id IS NOT NULL
```

---

## 10. Bitwise Operators

MySQL also supports bitwise operations such as `&`, `|`, `^`, `~`, `<<`, and `>>`.

These are less common in everyday analytics SQL but can appear in flags, packed values, and specialized systems.

```sql
SELECT 5 & 3 AS bitwise_and,
       5 | 3 AS bitwise_or,
       5 ^ 3 AS bitwise_xor;
```

---

## 11. Conditional Expressions

Operators are often combined with `CASE` to implement business rules.

```sql
SELECT
    employee_name,
    salary,
    CASE
        WHEN salary >= 100000 THEN 'High'
        WHEN salary >= 60000 THEN 'Medium'
        ELSE 'Low'
    END AS salary_band
FROM employees;
```

This is especially useful in reporting and ETL transformations.

---

## 12. Expressions with NULL

Arithmetic involving `NULL` normally produces `NULL`.

```sql
SELECT salary + bonus
FROM employees;
```

If `bonus` is `NULL`, the expression is `NULL`.

Use `COALESCE` when a missing value should be treated as a defined fallback:

```sql
SELECT salary + COALESCE(bonus, 0) AS total_compensation
FROM employees;
```

---

## 13. Practical Data Engineering Patterns

### Filter a Load Window

```sql
WHERE updated_at >= '2026-08-01'
  AND updated_at <  '2026-08-02'
```

### Exclude Invalid Records

```sql
WHERE customer_id IS NOT NULL
  AND status NOT IN ('deleted', 'invalid')
```

### Detect Suspicious Values

```sql
WHERE amount < 0
   OR amount IS NULL
```

### Categorize Records

```sql
CASE
    WHEN amount >= 10000 THEN 'large'
    WHEN amount >= 1000 THEN 'medium'
    ELSE 'small'
END
```

These patterns commonly appear in ETL/ELT staging, validation, incremental extraction, and reporting queries.

---

## 14. Common Mistakes

- Using `= NULL` instead of `IS NULL`
- Forgetting that `BETWEEN` is inclusive
- Misreading `AND`/`OR` precedence
- Using `NOT IN` without considering `NULL`
- Treating `NULL` as zero or an empty string
- Building timestamp filters with an incorrect end boundary
- Relying on implicit type conversion without understanding the data types
- Writing complex boolean logic without parentheses
- Assuming `LIKE` is always case-sensitive; behavior depends on collation
- Using functions on indexed columns unnecessarily in filtering predicates

---

## 15. Interview-Focused Questions

### Q1. What is the difference between `=` and `IS NULL` in SQL?

<details>
<summary><strong>Answer</strong></summary>

`=` compares two values, while `IS NULL` checks whether a value is the SQL `NULL` marker. `NULL` represents an unknown or missing value and cannot be tested with `= NULL`.

</details>

---

### Q2. What is three-valued logic in SQL?

<details>
<summary><strong>Answer</strong></summary>

SQL conditions can evaluate to `TRUE`, `FALSE`, or `UNKNOWN`. Comparisons involving `NULL` commonly produce `UNKNOWN`, which is why null checks require `IS NULL` or `IS NOT NULL`.

</details>

---

### Q3. Is `BETWEEN` inclusive in MySQL?

<details>
<summary><strong>Answer</strong></summary>

Yes. `BETWEEN a AND b` includes both `a` and `b`. For timestamp filtering, half-open ranges such as `>= start AND < end` are often safer.

</details>

---

### Q4. What is the difference between `IN` and `OR`?

<details>
<summary><strong>Answer</strong></summary>

`IN` is a concise membership test and can represent multiple equality comparisons. For example, `department IN ('HR', 'IT')` is logically similar to `department = 'HR' OR department = 'IT'`.

</details>

---

### Q5. Why can `NOT IN` behave unexpectedly when NULL is present?

<details>
<summary><strong>Answer</strong></summary>

Because SQL uses three-valued logic. If the `NOT IN` comparison encounters `NULL`, the result can become `UNKNOWN`, preventing rows from satisfying the `WHERE` condition. A `NOT EXISTS` pattern is often safer for nullable subquery data.

</details>

---

### Q6. What is the difference between `AND` and `OR` precedence?

<details>
<summary><strong>Answer</strong></summary>

`AND` has higher logical precedence than `OR`. Therefore, `A OR B AND C` is interpreted as `A OR (B AND C)`. Parentheses should be used when a different grouping is required.

</details>

---

### Q7. How would you filter records for one full day when a column is DATETIME?

<details>
<summary><strong>Answer</strong></summary>

Use a half-open interval: `created_at >= '2026-08-01' AND created_at < '2026-08-02'`. This captures every timestamp on the day without depending on a final timestamp such as `23:59:59`.

</details>

---

### Q8. What is the difference between `%` and `_` in LIKE?

<details>
<summary><strong>Answer</strong></summary>

`%` matches zero or more characters, while `_` matches exactly one character. For example, `A%` matches any string beginning with A, while `A_1` requires exactly one character between A and 1.

</details>

---

### Q9. Why should complex WHERE conditions use parentheses?

<details>
<summary><strong>Answer</strong></summary>

Parentheses make the intended boolean logic explicit and prevent mistakes caused by operator precedence. They also make production SQL easier to review and maintain.

</details>

---

### Q10. Why can `salary + bonus` return NULL even when salary has a value?

<details>
<summary><strong>Answer</strong></summary>

If `bonus` is `NULL`, the arithmetic expression normally evaluates to `NULL`. If a missing bonus should be treated as zero, use `salary + COALESCE(bonus, 0)`.

</details>

---

## 16. Quick Revision

| Concept | Key Point |
|---|---|
| Arithmetic | Calculates numeric expressions |
| Comparison | Compares values |
| `AND` | All conditions must be true |
| `OR` | At least one condition must be true |
| `NOT` | Negates a condition |
| `BETWEEN` | Inclusive range test |
| `IN` | Membership test |
| `LIKE` | Pattern matching |
| `IS NULL` | Tests for NULL |
| `CASE` | Conditional business logic |
| `COALESCE` | Replaces NULL with a fallback |
| Precedence | Determines evaluation order |
| Three-valued logic | `TRUE`, `FALSE`, `UNKNOWN` |

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — worked examples for MySQL operators and expressions
- [`practice.sql`](./practice.sql) — hands-on exercises and interview practice
