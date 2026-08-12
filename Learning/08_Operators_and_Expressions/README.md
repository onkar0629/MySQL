# 08 — Operators and Expressions

## 📌 Overview

SQL operators and expressions are the building blocks used to **calculate values, compare data, combine conditions, test membership, handle NULL, and implement business rules**.

An expression can combine columns, literals, operators, and functions to produce a value. Operators determine how those values are manipulated or compared.

For a Data Engineer, this topic is important because real SQL rarely consists of simple column selection. ETL/ELT pipelines use expressions for validation, transformations, incremental extraction, data-quality checks, feature calculations, and business classifications.

---

## 🎯 Learning Objectives

By the end of this topic, you should be able to:

- Understand SQL expressions.
- Use arithmetic operators.
- Use comparison operators.
- Combine conditions with `AND`, `OR`, and `NOT`.
- Understand operator precedence.
- Use `IN`, `NOT IN`, and `BETWEEN`.
- Use `LIKE` pattern matching.
- Understand SQL's three-valued logic.
- Handle `NULL` correctly inside expressions.
- Use bitwise operators when appropriate.
- Build conditional expressions with `CASE`.
- Understand implicit type conversion risks.
- Write index-friendly predicates.
- Apply operators to real Data Engineering scenarios.

---

## 🧠 1. What Is an SQL Expression?

An expression is something that MySQL evaluates to produce a value.

```sql
SELECT salary * 12 AS annual_salary
FROM employees;
```

Here:

- `salary` is a column reference.
- `12` is a literal.
- `*` is an arithmetic operator.
- `salary * 12` is an expression.
- `annual_salary` is the result alias.

Expressions can appear in many places:

```sql
SELECT
    price * quantity AS line_total
FROM order_items
WHERE price * quantity > 1000;
```

They can be used in `SELECT`, `WHERE`, `ORDER BY`, `HAVING`, `JOIN` conditions, and other SQL clauses where an expression is permitted.

---

## ➕ 2. Arithmetic Operators

MySQL supports common arithmetic operators:

| Operator | Meaning |
|---|---|
| `+` | Addition |
| `-` | Subtraction |
| `*` | Multiplication |
| `/` | Division |
| `%` | Remainder / modulo |
| `DIV` | Integer division |

Example:

```sql
SELECT
    product_price,
    quantity,
    product_price * quantity AS line_total
FROM order_items;
```

### Division

```sql
SELECT
    10 / 4 AS division_result,
    10 DIV 4 AS integer_result,
    10 % 4 AS remainder;
```

The important distinction is:

```text
10 / 4   → division
10 DIV 4 → integer division
10 % 4   → remainder
```

The resulting type and exact numeric behavior depend on the operands and MySQL's expression rules, so use explicit types when precision matters.

---

## 💰 3. Arithmetic with Financial Data

For monetary values, prefer an exact numeric type such as `DECIMAL` rather than relying on approximate floating-point types.

Example:

```sql
SELECT
    revenue,
    cost,
    revenue - cost AS profit
FROM daily_sales;
```

A margin calculation could be:

```sql
SELECT
    revenue,
    cost,
    (revenue - cost) / NULLIF(revenue, 0) AS margin
FROM daily_sales;
```

`NULLIF(revenue, 0)` prevents division by zero by returning `NULL` when revenue is zero.

---

## ⚖️ 4. Comparison Operators

Comparison operators evaluate relationships between values.

| Operator | Meaning |
|---|---|
| `=` | Equal to |
| `<>` | Not equal to |
| `!=` | Not equal to |
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

These operators are commonly used in filtering, validation, joins, and conditional transformations.

---

## 🔗 5. AND

`AND` requires the combined condition to be TRUE.

```sql
SELECT *
FROM employees
WHERE department = 'Data Engineering'
  AND salary >= 60000;
```

Both conditions must qualify.

Use `AND` when the business requirement means **all specified rules must be satisfied**.

---

## 🔀 6. OR

`OR` is TRUE when at least one condition is TRUE.

```sql
SELECT *
FROM employees
WHERE department = 'Data Engineering'
   OR department = 'Analytics';
```

This is useful when multiple alternative conditions are acceptable.

---

## 🚫 7. NOT

`NOT` negates a condition.

```sql
SELECT *
FROM customers
WHERE NOT status = 'INACTIVE';
```

For readability, many production queries are clearer when written positively:

```sql
WHERE status <> 'INACTIVE'
```

However, these forms are not necessarily identical when `NULL` is involved. A `NULL` status remains `UNKNOWN` under ordinary comparisons.

---

## 🧠 8. Operator Precedence

When multiple operators appear in one expression, MySQL follows precedence rules.

For logical operators, `AND` has higher precedence than `OR`.

Therefore:

```sql
WHERE department = 'Data Engineering'
   OR department = 'Analytics'
  AND salary >= 60000
```

is interpreted as:

```sql
WHERE department = 'Data Engineering'
   OR (department = 'Analytics' AND salary >= 60000)
```

If the business rule means both departments must satisfy the salary requirement, write:

```sql
WHERE (department = 'Data Engineering'
    OR department = 'Analytics')
  AND salary >= 60000
```

### Best practice

When mixing `AND` and `OR`, use parentheses even when you know the precedence. It makes the intended business logic immediately visible to reviewers.

---

## 📏 9. BETWEEN

`BETWEEN` performs an inclusive range test.

```sql
SELECT *
FROM employees
WHERE salary BETWEEN 50000 AND 80000;
```

This is equivalent to:

```sql
WHERE salary >= 50000
  AND salary <= 80000
```

Both endpoints are included.

### Timestamp warning

For datetime columns, a half-open range is generally safer:

```sql
WHERE created_at >= '2026-08-01'
  AND created_at <  '2026-09-01'
```

This includes all timestamps in August without guessing the last possible timestamp of August 31.

---

## 📋 10. IN

`IN` tests whether a value belongs to a set.

```sql
SELECT *
FROM employees
WHERE department IN (
    'Data Engineering',
    'Analytics',
    'Finance'
);
```

Conceptually, this is similar to:

```sql
WHERE department = 'Data Engineering'
   OR department = 'Analytics'
   OR department = 'Finance'
```

`IN` is usually easier to read and maintain for a list of values.

---

## 🚫 11. NOT IN and NULL

`NOT IN` excludes values from a set.

```sql
SELECT *
FROM employees
WHERE department NOT IN ('HR', 'Sales');
```

The important warning is `NULL`.

Suppose a subquery produces:

```text
HR
Sales
NULL
```

Then a `NOT IN` comparison can become `UNKNOWN` for values that cannot be proven to be outside the entire set.

For anti-join logic, a `NOT EXISTS` solution is often safer when nullable values are possible.

---

## 🔤 12. LIKE

`LIKE` performs pattern matching.

| Pattern | Meaning |
|---|---|
| `%` | Zero or more characters |
| `_` | Exactly one character |

Examples:

```sql
WHERE customer_name LIKE 'A%'
```

Starts with `A`.

```sql
WHERE customer_name LIKE '%son'
```

Ends with `son`.

```sql
WHERE customer_name LIKE '%data%'
```

Contains `data`.

```sql
WHERE code LIKE 'A_1'
```

Exactly three characters, with `A` first and `1` last.

### Performance note

A pattern such as:

```sql
LIKE 'A%'
```

can often use a suitable B-tree index more effectively than:

```sql
LIKE '%A'
```

because the second pattern does not provide a known starting point for a normal index lookup.

Actual behavior should be verified with `EXPLAIN`.

---

## NULL 13. NULL and Three-Valued Logic

SQL conditions can evaluate to:

```text
TRUE
FALSE
UNKNOWN
```

`NULL` represents missing, unknown, or not-applicable information.

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

Or:

```sql
WHERE manager_id IS NOT NULL
```

### Why?

For example:

```sql
SELECT NULL = NULL;
```

The result is `NULL`/unknown rather than TRUE.

Therefore ordinary equality cannot be used to test for NULL.

---

## 🧮 14. NULL in Arithmetic Expressions

Arithmetic involving `NULL` normally produces `NULL`.

```sql
SELECT salary + bonus
FROM employees;
```

If:

```text
salary = 80000
bonus  = NULL
```

the expression does not become `80000`; the result is `NULL`.

If the business rule says a missing bonus should be treated as zero:

```sql
SELECT
    salary + COALESCE(bonus, 0) AS total_compensation
FROM employees;
```

---

## 🛡️ 15. NULLIF for Safe Expressions

`NULLIF(a, b)` returns `NULL` when `a = b`; otherwise it returns `a`.

This is particularly useful for safe division:

```sql
SELECT
    revenue / NULLIF(order_count, 0) AS average_order_value
FROM metrics;
```

If `order_count = 0`, `NULLIF(order_count, 0)` returns `NULL`, avoiding a division-by-zero error.

---

## 🧩 16. Conditional Expressions with CASE

`CASE` allows SQL to implement business rules.

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

`CASE` can be used for:

- Data classification
- Business categories
- Data-quality flags
- Conditional transformations
- KPI logic

---

## 🔀 17. Simple CASE vs Searched CASE

### Simple CASE

Compares one expression against values:

```sql
CASE status
    WHEN 'A' THEN 'ACTIVE'
    WHEN 'I' THEN 'INACTIVE'
    ELSE 'UNKNOWN'
END
```

### Searched CASE

Evaluates independent conditions:

```sql
CASE
    WHEN amount >= 10000 THEN 'HIGH'
    WHEN amount >= 1000 THEN 'MEDIUM'
    ELSE 'LOW'
END
```

Searched `CASE` is more flexible for ranges and compound business rules.

---

## 🔢 18. Bitwise Operators

MySQL supports bitwise operators including:

```text
&   AND
|   OR
^   XOR
~   NOT
<<  left shift
>>  right shift
```

Example:

```sql
SELECT
    5 & 3 AS bitwise_and,
    5 | 3 AS bitwise_or,
    5 ^ 3 AS bitwise_xor;
```

These are less common in everyday analytics SQL but can appear in systems using integer flags or compact status representations.

Do not confuse bitwise `&` with logical `AND`.

---

## 🔄 19. Implicit Type Conversion

MySQL can perform type conversion when operands have different types.

For example, comparing a numeric column to a string literal can cause conversion behavior that may not match your intended data model.

Prefer compatible data types:

```sql
WHERE customer_id = 1001
```

rather than relying on accidental conversions such as:

```sql
WHERE customer_id = '1001'
```

The correct choice depends on the column type and context, but explicit and compatible types make SQL easier to reason about.

### Why Data Engineers should care

Implicit conversions can contribute to:

- Unexpected comparisons
- Data-quality bugs
- Poor index usage
- Difficult-to-debug pipeline behavior

---

## 🏗️ 20. Practical Data Engineering Patterns

### Filter an incremental load

```sql
WHERE updated_at >= :start_watermark
  AND updated_at <  :end_watermark
```

### Exclude invalid records

```sql
WHERE customer_id IS NOT NULL
  AND amount >= 0
```

### Detect suspicious values

```sql
WHERE amount < 0
   OR amount IS NULL
```

### Categorize records

```sql
CASE
    WHEN amount >= 10000 THEN 'large'
    WHEN amount >= 1000 THEN 'medium'
    ELSE 'small'
END
```

### Safe ratio

```sql
revenue / NULLIF(order_count, 0)
```

These patterns appear frequently in staging, validation, transformations, and reporting pipelines.

---

## 🕒 21. Operators in Incremental Data Pipelines

A common extraction rule is:

```sql
WHERE updated_at >= :last_successful_watermark
  AND updated_at <  :current_watermark
```

This uses comparison operators to define a deterministic processing window.

The pipeline should consider:

- Late-arriving records
- Duplicate events
- Clock skew
- Retry behavior
- Watermark advancement
- Time zone handling

A filter that looks syntactically correct can still be operationally wrong if the watermark strategy is poorly designed.

---

## 🌎 22. Real-World Example — Customer Segmentation

Business requirement:

> Classify active customers by monthly spend.

```sql
SELECT
    customer_id,
    monthly_spend,
    CASE
        WHEN monthly_spend >= 100000 THEN 'PLATINUM'
        WHEN monthly_spend >= 50000 THEN 'GOLD'
        WHEN monthly_spend >= 10000 THEN 'SILVER'
        ELSE 'STANDARD'
    END AS customer_tier
FROM customers
WHERE status = 'ACTIVE';
```

This combines:

- Comparison operators
- `CASE`
- Filtering
- Derived expressions

---

## ⚠️ 23. Common Mistakes

### Mistake 1 — Using `= NULL`

Use `IS NULL`.

### Mistake 2 — Forgetting `BETWEEN` is inclusive

Use explicit boundaries when the business requirement needs them.

### Mistake 3 — Misreading AND/OR precedence

Use parentheses.

### Mistake 4 — Using NOT IN without considering NULL

Use `NOT EXISTS` where appropriate for nullable anti-join logic.

### Mistake 5 — Treating NULL as zero

Use `COALESCE` only when the business meaning actually says a missing value should become zero.

### Mistake 6 — Dividing by a potentially zero value

Use `NULLIF` or an explicit condition.

### Mistake 7 — Confusing logical and bitwise operators

`AND` is not the same operation as `&`.

### Mistake 8 — Relying on implicit type conversion

Use compatible data types in comparisons and joins.

### Mistake 9 — Assuming LIKE has identical case behavior everywhere

Case sensitivity depends on character set/collation behavior.

### Mistake 10 — Applying functions to indexed columns unnecessarily

Consider sargable predicates and validate with `EXPLAIN`.

---

## ⚡ 24. Performance Considerations

Operators themselves are usually inexpensive; the important issue is how the resulting predicates interact with indexes and data volume.

Consider:

- Use indexes on columns frequently used for selective filtering or joining.
- Prefer predicates that allow efficient index access.
- Avoid unnecessary functions on indexed columns.
- Be careful with leading-wildcard `LIKE` patterns.
- Use compatible data types to reduce conversion issues.
- Use `EXPLAIN` to verify the actual execution plan.
- Avoid unnecessary calculations on millions of rows when a precomputed or indexed design is more appropriate.

Do not optimize from syntax alone. Measure with representative data.

---

## 🎤 25. Interview-Focused Questions

### Q1. What is the difference between an operator and an expression?

<details>
<summary><strong>Answer</strong></summary>

An operator performs an operation such as addition or comparison. An expression is a combination of columns, literals, operators, and functions that produces a value. For example, `salary * 12` is an expression and `*` is the arithmetic operator.

</details>

---

### Q2. What is three-valued logic in SQL?

<details>
<summary><strong>Answer</strong></summary>

SQL conditions can evaluate to TRUE, FALSE, or UNKNOWN. NULL comparisons commonly produce UNKNOWN. Because a WHERE clause returns only rows whose condition is TRUE, NULL handling must be explicit.

</details>

---

### Q3. Is BETWEEN inclusive in MySQL?

<details>
<summary><strong>Answer</strong></summary>

Yes. Both boundary values are included. For datetime intervals, however, a half-open range such as `>= start AND < next_boundary` is usually easier to reason about.

</details>

---

### Q4. Why can NOT IN produce unexpected results when NULL is present?

<details>
<summary><strong>Answer</strong></summary>

Because comparison with NULL can produce UNKNOWN. If a NOT IN list or subquery contains NULL, the database may be unable to prove that a value is outside the entire set. `NOT EXISTS` is often safer for nullable anti-join logic.

</details>

---

### Q5. What is the difference between AND and OR precedence?

<details>
<summary><strong>Answer</strong></summary>

AND has higher logical precedence than OR. Therefore `A OR B AND C` means `A OR (B AND C)`. Parentheses should be used when the intended business rule requires a different grouping.

</details>

---

### Q6. Why does `salary + bonus` become NULL when bonus is NULL?

<details>
<summary><strong>Answer</strong></summary>

Arithmetic involving NULL normally produces NULL because the missing value makes the result unknown. If the business rule treats missing bonus as zero, use `COALESCE(bonus, 0)`.

</details>

---

### Q7. How would you safely calculate an average when the denominator can be zero?

<details>
<summary><strong>Answer</strong></summary>

Use `NULLIF`:

```sql
revenue / NULLIF(order_count, 0)
```

When `order_count` is zero, `NULLIF` returns NULL instead of zero, preventing division by zero.

</details>

---

### Q8. What is the difference between LIKE `%` and `_`?

<details>
<summary><strong>Answer</strong></summary>

`%` matches zero or more characters. `_` matches exactly one character. Therefore `A%` can match `Asha`, while `A_1` requires exactly one character between A and 1.

</details>

---

### Q9. What is the difference between logical AND and bitwise &?

<details>
<summary><strong>Answer</strong></summary>

Logical `AND` combines boolean conditions. Bitwise `&` operates on the individual bits of numeric values. They solve different problems and should not be used interchangeably.

</details>

---

### Q10. Why should you avoid unnecessary implicit type conversion?

<details>
<summary><strong>Answer</strong></summary>

Implicit conversion can produce unexpected comparisons, hide data-quality issues, and sometimes affect efficient index usage. Using compatible data types makes joins and filters more predictable.

</details>

---

### Q11. How can a LIKE condition affect index performance?

<details>
<summary><strong>Answer</strong></summary>

A pattern with a known prefix such as `LIKE 'A%'` can often use a B-tree index efficiently. A leading wildcard such as `LIKE '%A'` does not provide a known starting position and generally cannot use a normal B-tree index for a direct prefix lookup. Verify with `EXPLAIN`.

</details>

---

### Q12. How would you design a safe timestamp filter for an incremental pipeline?

<details>
<summary><strong>Answer</strong></summary>

Use a half-open range such as:

```sql
WHERE updated_at >= :start_watermark
  AND updated_at <  :end_watermark
```

Then make the watermark advancement and retry strategy deterministic, while accounting for late-arriving records and duplicate events.

</details>

---

### Q13. When would you use CASE in a Data Engineering pipeline?

<details>
<summary><strong>Answer</strong></summary>

Use `CASE` for deterministic business classifications and transformations, such as customer tiers, data-quality flags, status normalization, revenue bands, and conditional metrics.

</details>

---

### Q14. How would you identify records with invalid numeric values?

<details>
<summary><strong>Answer</strong></summary>

Translate the business rule into predicates. For example, if an amount cannot be negative:

```sql
WHERE amount < 0
   OR amount IS NULL
```

The exact validation depends on whether NULL is considered invalid, unknown, or acceptable for the field.

</details>

---

## 🔄 26. Quick Revision

| Concept | Key Point |
|---|---|
| Expression | Produces a value |
| Arithmetic | `+ - * / % DIV` |
| Comparison | `= <> != > < >= <=` |
| `AND` | All conditions must hold |
| `OR` | At least one condition holds |
| `NOT` | Negates a condition |
| `BETWEEN` | Inclusive range |
| `IN` | Membership test |
| `LIKE` | Pattern matching |
| `%` | Zero or more characters |
| `_` | Exactly one character |
| `IS NULL` | Tests NULL |
| `COALESCE` | Fallback for NULL |
| `NULLIF` | Converts a matching value to NULL |
| `CASE` | Conditional business logic |
| Bitwise | Operates on numeric bits |
| Precedence | Determines expression grouping |

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — worked examples for MySQL operators and expressions
- [`practice.sql`](./practice.sql) — hands-on exercises and interview practice
