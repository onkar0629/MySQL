# 12 — String Functions

## 📌 Overview

String functions are used to inspect, clean, transform, format, and compare text data. They are especially important in Data Engineering for standardizing names, parsing identifiers, cleaning source-system values, and preparing data for joins and reporting.

## 🎯 Learning Objectives

- Measure and transform strings
- Extract substrings and tokens
- Change case and remove unwanted spaces
- Concatenate values safely
- Replace and search text
- Compare strings and understand `NULL` behavior
- Apply string functions in ETL and data-cleaning workflows

## 1. Length Functions

```sql
SELECT employee_name, LENGTH(employee_name) AS name_length
FROM employees;
```

`LENGTH()` returns bytes. `CHAR_LENGTH()` returns characters and is preferable when multilingual text matters.

## 2. Case Conversion

```sql
SELECT UPPER(employee_name), LOWER(employee_name)
FROM employees;
```

## 3. Trimming Whitespace

```sql
SELECT TRIM(employee_name)
FROM employees;
```

MySQL also provides `LTRIM()` and `RTRIM()`.

## 4. Concatenation

```sql
SELECT CONCAT(first_name, ' ', last_name) AS full_name
FROM employees;
```

`CONCAT()` returns `NULL` when a required argument is `NULL`. Use `COALESCE()` when missing values should be replaced.

```sql
SELECT CONCAT(COALESCE(first_name, ''), ' ', COALESCE(last_name, ''))
FROM employees;
```

`CONCAT_WS()` is useful when a separator should be applied between values.

## 5. Substrings

```sql
SELECT SUBSTRING(employee_code, 1, 3) AS prefix
FROM employees;
```

Related functions include `LEFT()` and `RIGHT()`.

```sql
SELECT LEFT(employee_code, 3), RIGHT(employee_code, 4)
FROM employees;
```

## 6. Search Functions

```sql
SELECT employee_name, LOCATE('an', employee_name)
FROM employees;
```

`INSTR()` is another way to find the position of a substring.

## 7. Replacement

```sql
SELECT REPLACE(phone_number, '-', '') AS normalized_phone
FROM customers;
```

This is commonly used during source-data normalization.

## 8. Padding

```sql
SELECT LPAD(employee_id, 6, '0') AS formatted_id
FROM employees;
```

`RPAD()` pads on the right.

## 9. Reverse and Repeat

```sql
SELECT REVERSE(employee_code), REPEAT('*', 5)
FROM employees;
```

These are useful for specialized transformations, testing, and formatting.

## 10. String Splitting and Token Extraction

MySQL does not provide a general-purpose `SPLIT()` function like some other platforms. For simple delimited values, functions such as `SUBSTRING_INDEX()` can extract tokens.

```sql
SELECT SUBSTRING_INDEX(email, '@', 1) AS username
FROM customers;
```

For complex multi-value parsing, normalize the data model or use an appropriate ETL transformation rather than storing repeated values in one column.

## 11. Comparison and Pattern Matching

```sql
SELECT *
FROM customers
WHERE LOWER(email) LIKE '%@gmail.com';
```

For indexed production queries, applying functions to a filtered column can prevent efficient index use. Consider normalized/generated columns when appropriate.

## 12. NULL and String Functions

```sql
SELECT CONCAT('Customer: ', COALESCE(customer_name, 'Unknown'))
FROM orders;
```

Always consider whether `NULL` should remain `NULL` or be replaced before applying a transformation.

## 13. Data Engineering Patterns

### Normalize whitespace and case

```sql
SELECT LOWER(TRIM(email)) AS normalized_email
FROM staging_customers;
```

### Create a business key

```sql
SELECT CONCAT(LOWER(TRIM(country_code)), '-', TRIM(customer_code)) AS business_key
FROM staging_customers;
```

### Extract source-system prefix

```sql
SELECT SUBSTRING(source_record_id, 1, 3) AS source_system
FROM staging_records;
```

### Detect malformed values

```sql
SELECT email
FROM staging_customers
WHERE email IS NOT NULL
  AND email NOT LIKE '%@%';
```

## 14. Performance Considerations

- Prefer `CHAR_LENGTH()` when character count matters for multilingual data.
- Avoid wrapping indexed columns in functions inside selective predicates when an equivalent sargable predicate is available.
- Normalize frequently joined business keys during ingestion rather than repeatedly transforming them at query time.
- Use generated/indexed columns when a derived string is queried frequently and the design justifies it.

## 15. Common Mistakes

- Confusing `LENGTH()` with `CHAR_LENGTH()`
- Forgetting `NULL` behavior in `CONCAT()`
- Using `TRIM()` without understanding the source formatting problem
- Assuming MySQL has a general-purpose `SPLIT()` function
- Applying functions to indexed columns unnecessarily
- Treating string cleaning as a substitute for good source-data modeling

## 16. Interview-Focused Questions

### Q1. What is the difference between `LENGTH()` and `CHAR_LENGTH()`?

<details>
<summary><strong>Answer</strong></summary>

`LENGTH()` returns the number of bytes, while `CHAR_LENGTH()` returns the number of characters. For multilingual text, character count is usually the appropriate measurement.

</details>

---

### Q2. What happens when `CONCAT()` receives a `NULL` argument?

<details>
<summary><strong>Answer</strong></summary>

`CONCAT()` returns `NULL` if any argument is `NULL`. Use `COALESCE()` when missing values should be converted to a non-NULL representation.

</details>

---

### Q3. What is the difference between `CONCAT()` and `CONCAT_WS()`?

<details>
<summary><strong>Answer</strong></summary>

`CONCAT()` joins arguments directly. `CONCAT_WS()` joins arguments using a specified separator and is useful for building formatted strings such as names or addresses.

</details>

---

### Q4. How would you normalize an email address before comparing it?

<details>
<summary><strong>Answer</strong></summary>

A common normalization is `LOWER(TRIM(email))`. The exact normalization policy should match the business and source-system rules.

</details>

---

### Q5. How can you remove hyphens from a phone number?

<details>
<summary><strong>Answer</strong></summary>

Use `REPLACE(phone_number, '-', '')`. Additional normalization may be required for spaces, country codes, parentheses, or extensions.

</details>

---

### Q6. How would you extract the domain from an email address?

<details>
<summary><strong>Answer</strong></summary>

For a simple email format, `SUBSTRING_INDEX(email, '@', -1)` returns the text after the final `@`.

</details>

---

### Q7. Why can `WHERE LOWER(email) = 'x@example.com'` be a performance problem?

<details>
<summary><strong>Answer</strong></summary>

Applying a function to an indexed column can prevent the optimizer from using a normal index efficiently. A normalized or generated indexed column can be considered for frequent workloads.

</details>

---

### Q8. How would you remove leading and trailing spaces from source data?

<details>
<summary><strong>Answer</strong></summary>

Use `TRIM()`. In an ETL pipeline, the transformation can be applied during staging or standardization so downstream systems receive consistent values.

</details>

---

### Q9. How would you extract the first three characters of an identifier?

<details>
<summary><strong>Answer</strong></summary>

Use `LEFT(identifier, 3)` or `SUBSTRING(identifier, 1, 3)`. `LEFT()` is concise when the requirement is specifically a prefix.

</details>

---

### Q10. Would you store comma-separated values in one column and split them later?

<details>
<summary><strong>Answer</strong></summary>

Generally no. Repeating values should normally be modeled relationally in a child table. String parsing can be useful for ingesting legacy or external data, but it should not replace proper normalization when the values need independent querying or relationships.

</details>

## 17. Quick Revision

| Function | Purpose |
|---|---|
| `LENGTH()` | Number of bytes |
| `CHAR_LENGTH()` | Number of characters |
| `UPPER()` | Convert to uppercase |
| `LOWER()` | Convert to lowercase |
| `TRIM()` | Remove surrounding spaces |
| `CONCAT()` | Join strings |
| `CONCAT_WS()` | Join strings with separator |
| `SUBSTRING()` | Extract part of a string |
| `LEFT()` | Extract leftmost characters |
| `RIGHT()` | Extract rightmost characters |
| `LOCATE()` | Find substring position |
| `REPLACE()` | Replace text |
| `LPAD()` | Left-pad text |
| `RPAD()` | Right-pad text |
| `SUBSTRING_INDEX()` | Extract token around a delimiter |
| `REVERSE()` | Reverse a string |

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — worked examples for MySQL string functions
- [`practice.sql`](./practice.sql) — hands-on exercises and interview practice
