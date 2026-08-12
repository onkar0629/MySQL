# 🔢 Numeric and Mathematical Functions

## 📌 Overview

Numeric and mathematical functions are used to perform calculations, rounding, comparisons, absolute-value operations, random-number generation, and other numerical transformations in MySQL.

These functions are important for analytics, financial calculations, KPI generation, data-quality checks, and Data Engineering transformations.

## 🎯 Learning Objectives

By the end of this topic, you should be able to:

- Perform arithmetic calculations in SQL.
- Round and truncate numeric values correctly.
- Work with absolute values and signs.
- Calculate powers, square roots, and remainders.
- Generate and manipulate random values.
- Understand precision and floating-point behavior.
- Apply numeric functions in aggregation and Data Engineering scenarios.

## 📚 Concepts

### 1. Arithmetic Operators

```sql
SELECT 100 + 25;
SELECT 100 - 25;
SELECT 100 * 25;
SELECT 100 / 25;
SELECT 100 % 30;
```

### 2. `ABS()`

Returns the absolute value.

```sql
SELECT ABS(-125);
```

### 3. `SIGN()`

Returns `-1`, `0`, or `1` depending on the sign of a number.

```sql
SELECT SIGN(-10), SIGN(0), SIGN(25);
```

### 4. `ROUND()`

Rounds a number to the specified number of decimal places.

```sql
SELECT ROUND(125.678, 2);
```

### 5. `TRUNCATE()`

Removes decimal digits without rounding.

```sql
SELECT TRUNCATE(125.678, 2);
```

### 6. `CEIL()` / `CEILING()` and `FLOOR()`

```sql
SELECT CEIL(12.3);
SELECT FLOOR(12.9);
```

### 7. `MOD()`

Returns the remainder of division.

```sql
SELECT MOD(17, 5);
```

### 8. `POWER()` / `POW()` and `SQRT()`

```sql
SELECT POWER(2, 5);
SELECT SQRT(144);
```

### 9. `PI()`

Returns the value of π.

```sql
SELECT PI();
```

### 10. Random Numbers

```sql
SELECT RAND();
SELECT RAND(42);
```

`RAND()` should generally not be used when deterministic ordering or reproducible production transformations are required.

## 📝 Practical Examples

### Calculate a discounted price

```sql
SELECT
    product_id,
    price,
    discount_percent,
    ROUND(price * (1 - discount_percent / 100), 2) AS final_price
FROM products;
```

### Detect amount differences

```sql
SELECT
    order_id,
    ABS(source_amount - target_amount) AS absolute_difference
FROM reconciliation;
```

### Bucket values using `FLOOR()`

```sql
SELECT
    customer_id,
    FLOOR(total_spend / 1000) * 1000 AS spend_bucket
FROM customers;
```

## 🌎 Real-World / Data Engineering Use Cases

- Financial and currency calculations.
- Revenue and margin calculations.
- Rounding metrics for reports.
- Reconciliation tolerance checks.
- Data-quality threshold validation.
- Bucketing continuous numeric values.
- Calculating percentage differences.
- ETL/ELT transformations.
- Detecting negative or unexpected measurements.

### Precision Consideration

For financial values, prefer `DECIMAL` rather than approximate floating-point types when exact decimal arithmetic is required.

```sql
DECIMAL(12, 2)
```

Avoid relying on floating-point equality such as:

```sql
WHERE calculated_value = 0.3
```

For approximate calculations, use a tolerance where appropriate.

## ⚠️ Common Mistakes

1. Confusing `ROUND()` with `TRUNCATE()`.
2. Using floating-point types for exact financial values.
3. Forgetting integer division behavior in calculations.
4. Comparing floating-point values with exact equality.
5. Dividing by zero.
6. Assuming `RAND()` provides deterministic row ordering.
7. Rounding before aggregation when the business requirement requires rounding after aggregation.
8. Applying mathematical functions to `NULL` without considering the resulting `NULL`.

## 🎤 Interview-Focused Questions

### Q1. What is the difference between `ROUND()` and `TRUNCATE()`?

<details>
<summary><strong>Answer</strong></summary>

`ROUND()` rounds a value according to the next digit, while `TRUNCATE()` simply removes digits beyond the requested decimal position.

</details>

### Q2. How would you calculate the absolute difference between two amounts?

<details>
<summary><strong>Answer</strong></summary>

Use `ABS()`.

```sql
ABS(source_amount - target_amount)
```

</details>

### Q3. How would you find records whose amount difference exceeds 10?

<details>
<summary><strong>Answer</strong></summary>

```sql
WHERE ABS(source_amount - target_amount) > 10
```

</details>

### Q4. Why should `DECIMAL` be preferred for financial calculations?

<details>
<summary><strong>Answer</strong></summary>

`DECIMAL` provides exact fixed-point decimal arithmetic, making it more appropriate for money than approximate floating-point types such as `FLOAT` or `DOUBLE`.

</details>

### Q5. What is the difference between `CEIL()` and `FLOOR()`?

<details>
<summary><strong>Answer</strong></summary>

`CEIL()` returns the smallest integer greater than or equal to the value. `FLOOR()` returns the largest integer less than or equal to the value.

</details>

### Q6. How can `MOD()` be used to identify even numbers?

<details>
<summary><strong>Answer</strong></summary>

```sql
WHERE MOD(id, 2) = 0
```

</details>

### Q7. How would you create spend buckets of 1,000?

<details>
<summary><strong>Answer</strong></summary>

```sql
FLOOR(total_spend / 1000) * 1000
```

</details>

### Q8. Why can floating-point equality comparisons be dangerous?

<details>
<summary><strong>Answer</strong></summary>

Floating-point values may contain representation and precision differences. A calculated value that mathematically should equal a decimal may not be stored as exactly that decimal. Use appropriate tolerances when exact equality is unsafe.

</details>

### Q9. Where could numeric functions be useful in a Data Engineering pipeline?

<details>
<summary><strong>Answer</strong></summary>

They can be used for normalization, KPI calculations, reconciliation, tolerance checks, bucketing, financial transformations, and data-quality validation.

</details>

### Q10. What is a common aggregation mistake involving rounding?

<details>
<summary><strong>Answer</strong></summary>

Rounding each individual row before aggregation can produce a different result from aggregating first and rounding the final result. The correct approach depends on the business requirement.

</details>

## 🔄 Quick Revision

| Function | Purpose |
|---|---|
| `ABS()` | Absolute value |
| `SIGN()` | Sign of a number |
| `ROUND()` | Round a value |
| `TRUNCATE()` | Remove decimal digits |
| `CEIL()` | Round upward |
| `FLOOR()` | Round downward |
| `MOD()` | Remainder |
| `POWER()` | Raise to a power |
| `SQRT()` | Square root |
| `PI()` | Value of π |
| `RAND()` | Random value |

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — worked examples for MySQL numeric and mathematical functions
- [`practice.sql`](./practice.sql) — hands-on exercises and interview practice
