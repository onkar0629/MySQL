# 12 — String Functions

## 📌 Overview

String functions are used to **inspect, clean, transform, parse, compare, and standardize text data**.

For a Data Engineer, string manipulation is not just formatting. It is commonly used while ingesting messy source data, standardizing business keys, cleaning customer attributes, parsing identifiers, validating records, and preparing fields for reliable joins.

A useful principle is:

> **Normalize data at the appropriate pipeline boundary instead of repeatedly cleaning the same value in every downstream query.**

---

## 🎯 Learning Objectives

By the end of this topic, you should be able to:

- Understand byte length vs character length.
- Convert string case.
- Remove unwanted whitespace.
- Concatenate strings safely.
- Extract substrings and prefixes/suffixes.
- Search for text inside strings.
- Replace characters and substrings.
- Pad and format identifiers.
- Extract tokens from delimited values.
- Reverse and repeat strings.
- Handle `NULL` correctly in string expressions.
- Understand collation and case-sensitivity implications.
- Build data-cleaning and normalization pipelines.
- Recognize when string parsing indicates a poor data model.
- Understand performance implications of functions on indexed columns.

---

## 🧠 1. What Is a String Function?

A string function accepts text and returns a transformed, extracted, measured, or otherwise derived value.

Example:

```sql
SELECT
    customer_name,
    UPPER(customer_name) AS normalized_name
FROM customers;
```

The stored value is not changed. The function creates a value in the query result.

String functions can appear in:

```text
SELECT
WHERE
ORDER BY
GROUP BY
JOIN conditions
UPDATE
ETL transformations
```

Use them carefully in `WHERE` and `JOIN` predicates because transforming a column can affect index usage.

---

## 📏 2. LENGTH() vs CHAR_LENGTH()

These two functions are frequently asked in interviews.

### LENGTH()

Returns the number of **bytes**.

```sql
SELECT LENGTH('Python');
```

For ASCII text, bytes and characters are usually the same.

### CHAR_LENGTH()

Returns the number of **characters**.

```sql
SELECT CHAR_LENGTH('Python');
```

For multilingual text, the difference matters.

```sql
SELECT
    LENGTH('é') AS bytes,
    CHAR_LENGTH('é') AS characters;
```

### Rule

```text
LENGTH()      → bytes
CHAR_LENGTH() → characters
```

When the requirement is human-readable character count, prefer `CHAR_LENGTH()`.

---

## 🔤 3. UPPER() and LOWER()

Convert text to uppercase or lowercase.

```sql
SELECT
    UPPER(customer_name) AS upper_name,
    LOWER(customer_name) AS lower_name
FROM customers;
```

A common ETL normalization pattern is:

```sql
SELECT LOWER(TRIM(email)) AS normalized_email
FROM staging_customers;
```

### Important

Case comparison can also depend on the column/expression collation. Do not assume `LOWER()` is always required for case-insensitive comparison; understand the schema's collation first.

---

## 🧹 4. TRIM(), LTRIM(), RTRIM()

### TRIM()

Removes leading and trailing spaces.

```sql
SELECT TRIM(customer_name)
FROM customers;
```

### LTRIM()

Removes leading spaces.

```sql
SELECT LTRIM(customer_name)
FROM customers;
```

### RTRIM()

Removes trailing spaces.

```sql
SELECT RTRIM(customer_name)
FROM customers;
```

### Data Engineering example

Source data may contain:

```text
'  Mumbai  '
```

Normalize it:

```sql
SELECT TRIM(city) AS normalized_city
FROM staging_customers;
```

Whitespace normalization is especially important before grouping, joining, or uniqueness checks.

---

## 🔗 5. CONCAT()

`CONCAT()` joins multiple values into one string.

```sql
SELECT
    CONCAT(first_name, ' ', last_name) AS full_name
FROM employees;
```

### NULL behavior

If an argument is `NULL`, `CONCAT()` returns `NULL`.

For example, if:

```text
first_name = 'Asha'
last_name  = NULL
```

then:

```sql
CONCAT(first_name, ' ', last_name)
```

returns `NULL`.

If the business rule says missing values should become empty strings:

```sql
SELECT CONCAT(
    COALESCE(first_name, ''),
    ' ',
    COALESCE(last_name, '')
) AS full_name
FROM employees;
```

---

## 🧩 6. CONCAT_WS()

`CONCAT_WS()` means **CONCAT With Separator**.

```sql
SELECT
    CONCAT_WS(', ', city, state, country) AS location
FROM customers;
```

This is useful for building formatted addresses or labels.

A key distinction is that `CONCAT_WS()` handles `NULL` arguments differently from `CONCAT()`; `NULL` values are skipped when separating arguments, while a `NULL` separator causes the result to be `NULL`.

Always verify the desired output for missing values.

---

## ✂️ 7. SUBSTRING()

Extract part of a string.

```sql
SELECT
    SUBSTRING(employee_code, 1, 3) AS prefix
FROM employees;
```

The basic form is:

```text
SUBSTRING(string, start, length)
```

Example:

```sql
SELECT SUBSTRING('DATAENGINEER', 1, 4);
```

Result:

```text
DATA
```

MySQL also supports negative starting positions for extracting from the end.

---

## ⬅️ 8. LEFT() and RIGHT()

Use `LEFT()` for prefixes:

```sql
SELECT LEFT(employee_code, 3)
FROM employees;
```

Use `RIGHT()` for suffixes:

```sql
SELECT RIGHT(employee_code, 4)
FROM employees;
```

These are often easier to read than `SUBSTRING()` when the requirement is simply “first N characters” or “last N characters.”

---

## 🔎 9. LOCATE() and INSTR()

Find the position of a substring.

```sql
SELECT LOCATE('@', email)
FROM customers;
```

For example, this can identify where an email domain begins.

`INSTR()` provides another way to find a substring:

```sql
SELECT INSTR(email, '@')
FROM customers;
```

If the substring is not found, the position is `0`.

---

## 🔄 10. REPLACE()

Replace occurrences of text.

```sql
SELECT
    REPLACE(phone_number, '-', '') AS normalized_phone
FROM customers;
```

Another example:

```sql
SELECT
    REPLACE(product_name, 'Ltd.', '') AS cleaned_name
FROM products;
```

Use replacement rules carefully. A broad replacement can alter valid text unexpectedly.

---

## 🔢 11. LPAD() and RPAD()

Padding is useful for fixed-width identifiers.

```sql
SELECT LPAD(employee_id, 6, '0') AS formatted_id
FROM employees;
```

If `employee_id = 123`, the result is conceptually:

```text
000123
```

Right padding:

```sql
SELECT RPAD(code, 10, '.')
FROM products;
```

Padding is presentation logic unless the business system explicitly requires a formatted identifier.

---

## 🔁 12. REVERSE() and REPEAT()

Reverse text:

```sql
SELECT REVERSE(employee_code)
FROM employees;
```

Repeat text:

```sql
SELECT REPEAT('*', 5);
```

These are less common in production ETL but are useful for specialized transformations and interview questions.

---

## 🧩 13. SUBSTRING_INDEX()

`SUBSTRING_INDEX()` is useful for extracting tokens from a delimiter-separated string.

Example:

```sql
SELECT
    SUBSTRING_INDEX(email, '@', 1) AS username,
    SUBSTRING_INDEX(email, '@', -1) AS domain
FROM customers;
```

For:

```text
onkar@example.com
```

results are conceptually:

```text
username → onkar
domain   → example.com
```

### Important Data Engineering lesson

This is useful for parsing legacy source data, but if a column contains multiple independent business values, a normalized child table is usually a better long-term design.

---

## 🔤 14. Pattern Matching with LIKE

String functions often work alongside `LIKE`.

```sql
SELECT *
FROM customers
WHERE email LIKE '%@gmail.com';
```

Wildcards:

| Symbol | Meaning |
|---|---|
| `%` | Zero or more characters |
| `_` | Exactly one character |

Examples:

```sql
WHERE customer_name LIKE 'A%'
```

Starts with A.

```sql
WHERE customer_name LIKE '%son'
```

Ends with son.

```sql
WHERE customer_name LIKE '%data%'
```

Contains data.

---

## 🧠 15. String Comparison and Collation

String comparison behavior depends on character set and collation.

A collation can influence:

- Case sensitivity
- Accent sensitivity
- Sort behavior
- Equality comparisons

Therefore, do not blindly assume:

```sql
LOWER(a) = LOWER(b)
```

is always the best solution.

If a field is frequently compared case-insensitively, a schema-level normalization or appropriate collation may be more efficient and maintainable.

---

## NULL 16. NULL in String Expressions

`NULL` is not the same as an empty string.

```text
NULL → missing/unknown
''   → known string of length zero
```

For example:

```sql
SELECT
    CONCAT('Customer: ', customer_name)
FROM customers;
```

If `customer_name` is `NULL`, the result is `NULL`.

To provide a fallback:

```sql
SELECT
    CONCAT('Customer: ', COALESCE(customer_name, 'Unknown'))
FROM customers;
```

Always determine the business meaning of missing text before replacing it.

---

## 🧮 17. Combining String Functions

Real transformations often combine several functions.

```sql
SELECT
    LOWER(TRIM(email)) AS normalized_email
FROM staging_customers;
```

A more complex identifier:

```sql
SELECT
    CONCAT(
        LOWER(TRIM(country_code)),
        '-',
        TRIM(customer_code)
    ) AS business_key
FROM staging_customers;
```

Think from inside to outside:

```text
TRIM()
  ↓
LOWER()
  ↓
CONCAT()
```

---

## 🏗️ 18. Data Engineering Pattern — Standardizing Emails

Raw data:

```text
' Onkar@Example.COM '
```

A common normalization is:

```sql
SELECT
    LOWER(TRIM(email)) AS normalized_email
FROM staging_customers;
```

This produces a consistent representation for downstream matching.

### Important

Normalization rules should be defined by the business. Do not assume every email transformation is universally safe.

---

## 📞 19. Data Engineering Pattern — Phone Normalization

Suppose source data contains:

```text
+91-98765-43210
(022) 1234-5678
```

A basic transformation can remove selected characters:

```sql
SELECT
    REPLACE(
        REPLACE(phone_number, '-', ''),
        ' ',
        ''
    ) AS normalized_phone
FROM staging_customers;
```

For production systems, phone normalization often requires country-specific validation rather than simple character removal.

---

## 🔑 20. Data Engineering Pattern — Business Keys

Suppose a source system provides:

```text
country_code = ' IN '
customer_code = ' 00125 '
```

A standardized key can be built as:

```sql
SELECT
    CONCAT(
        UPPER(TRIM(country_code)),
        '-',
        TRIM(customer_code)
    ) AS business_key
FROM staging_customers;
```

Business-key normalization is especially important when joining data from multiple source systems.

---

## 🧪 21. Data Quality — Detecting Invalid Strings

### Missing email

```sql
WHERE email IS NULL
   OR TRIM(email) = ''
```

### Basic malformed email detection

```sql
WHERE email IS NOT NULL
  AND email NOT LIKE '%@%'
```

This is only a basic rule, not full email validation.

### Unexpected prefix

```sql
WHERE LEFT(source_record_id, 3) NOT IN ('CRM', 'ERP', 'WEB')
```

String functions can therefore be used to turn business validation rules into SQL predicates.

---

## 📊 22. Grouping by Normalized Strings

Suppose source systems contain:

```text
Mumbai
mumbai
 Mumbai 
MUMBAI
```

Grouping directly may produce multiple values depending on collation and stored data.

A normalization expression can be used:

```sql
SELECT
    LOWER(TRIM(city)) AS normalized_city,
    COUNT(*) AS customer_count
FROM staging_customers
GROUP BY LOWER(TRIM(city));
```

For large workloads, consider materializing the normalized value during ingestion instead of recalculating it repeatedly.

---

## 🔗 23. String Functions and JOINs

A common legacy-data problem is mismatched keys:

```text
Source A: ' CUST-001 '
Source B: 'cust-001'
```

A transformation might be:

```sql
SELECT ...
FROM source_a AS a
JOIN source_b AS b
    ON LOWER(TRIM(a.customer_code)) = LOWER(TRIM(b.customer_code));
```

This may solve the immediate problem, but it can be expensive on large datasets because both join expressions are transformed.

### Better Data Engineering approach

Normalize keys during staging:

```text
Raw source
   ↓
Standardization
   ↓
Normalized key
   ↓
Indexed / optimized downstream joins
```

---

## ⚡ 24. Performance Considerations

String functions can be CPU-intensive on large datasets.

Consider:

- Avoid repeatedly applying functions to millions of rows when the result can be materialized once.
- Avoid functions around indexed columns in selective `WHERE` and `JOIN` predicates when a normalized column can be used instead.
- Use generated/indexed columns when a derived string is queried frequently and the design justifies it.
- Keep string columns appropriately sized.
- Prefer relational modeling over repeated parsing of complex delimited values.
- Use `EXPLAIN` to validate whether indexes are actually being used.

For example, this may be less index-friendly:

```sql
WHERE LOWER(email) = 'user@example.com'
```

than querying a normalized, indexed representation:

```sql
WHERE normalized_email = 'user@example.com'
```

---

## 🧠 25. String Functions in UPDATE

String functions are also useful during data cleanup.

```sql
UPDATE customers
SET email = LOWER(TRIM(email))
WHERE email IS NOT NULL;
```

Before running a production update:

1. Preview the transformation with `SELECT`.
2. Identify the affected rows.
3. Use a transaction where appropriate.
4. Validate the result.
5. Commit only after verification.

Example preview:

```sql
SELECT
    email AS old_email,
    LOWER(TRIM(email)) AS new_email
FROM customers
WHERE email IS NOT NULL;
```

This is safer than immediately modifying the source table.

---

## ⚠️ 26. Common Mistakes

### Mistake 1 — Confusing LENGTH and CHAR_LENGTH

`LENGTH()` counts bytes; `CHAR_LENGTH()` counts characters.

### Mistake 2 — Forgetting NULL behavior

`CONCAT()` can return NULL when an argument is NULL.

### Mistake 3 — Treating empty strings as NULL

They are different values.

### Mistake 4 — Applying functions to indexed columns unnecessarily

This can reduce index efficiency.

### Mistake 5 — Using string parsing instead of proper modeling

Comma-separated business values usually belong in a related table.

### Mistake 6 — Assuming LOWER() is always required

Collation may already define case-insensitive comparison behavior.

### Mistake 7 — Performing destructive cleanup without previewing it

Use a SELECT to validate the transformation before UPDATE.

### Mistake 8 — Assuming simple LIKE rules fully validate structured data

A basic email pattern is not a complete email validator.

---

## 🎤 27. Interview-Focused Questions

### Q1. What is the difference between LENGTH() and CHAR_LENGTH()?

<details>
<summary><strong>Answer</strong></summary>

`LENGTH()` returns the number of bytes, while `CHAR_LENGTH()` returns the number of characters. This distinction matters for multibyte character sets and multilingual text.

</details>

---

### Q2. What happens when CONCAT() receives a NULL argument?

<details>
<summary><strong>Answer</strong></summary>

`CONCAT()` returns `NULL` if any argument is `NULL`. Use `COALESCE()` when the business rule requires a fallback value.

</details>

---

### Q3. What is the difference between CONCAT() and CONCAT_WS()?

<details>
<summary><strong>Answer</strong></summary>

`CONCAT()` combines values directly. `CONCAT_WS()` inserts a specified separator between arguments and handles NULL arguments differently. It is useful for formatted labels and addresses.

</details>

---

### Q4. How would you normalize an email address?

<details>
<summary><strong>Answer</strong></summary>

A common transformation is:

```sql
LOWER(TRIM(email))
```

The exact normalization policy should follow the source and business requirements.

</details>

---

### Q5. How would you remove hyphens from a phone number?

<details>
<summary><strong>Answer</strong></summary>

Use `REPLACE(phone_number, '-', '')`. Production phone normalization may require additional country-specific parsing and validation.

</details>

---

### Q6. How would you extract the domain from an email address?

<details>
<summary><strong>Answer</strong></summary>

For a simple email structure, use:

```sql
SUBSTRING_INDEX(email, '@', -1)
```

This returns the portion after the final `@`.

</details>

---

### Q7. Why can WHERE LOWER(email) = ... hurt performance?

<details>
<summary><strong>Answer</strong></summary>

Applying a function to the indexed column can prevent efficient use of a normal index. A normalized/generated indexed column can be a better design for frequent lookups.

</details>

---

### Q8. How would you remove leading and trailing spaces?

<details>
<summary><strong>Answer</strong></summary>

Use `TRIM()`. In a Data Engineering pipeline, this transformation is often best performed during staging or standardization so downstream systems receive consistent values.

</details>

---

### Q9. How would you extract the first three characters of a code?

<details>
<summary><strong>Answer</strong></summary>

Use:

```sql
LEFT(code, 3)
```

or:

```sql
SUBSTRING(code, 1, 3)
```

</details>

---

### Q10. Would you store comma-separated values in one column?

<details>
<summary><strong>Answer</strong></summary>

Generally no when the values are independent business entities that need querying or relationships. A normalized child table is usually better. String parsing is appropriate when ingesting legacy or external data that cannot immediately be remodeled.

</details>

---

### Q11. How would you detect blank or whitespace-only strings?

<details>
<summary><strong>Answer</strong></summary>

A common check is:

```sql
WHERE column_name IS NULL
   OR TRIM(column_name) = ''
```

This distinguishes NULL from a string containing only whitespace.

</details>

---

### Q12. How would you standardize customer city values before grouping?

<details>
<summary><strong>Answer</strong></summary>

A simple normalization is:

```sql
LOWER(TRIM(city))
```

For production pipelines, materializing a standardized dimension/key can be preferable to repeatedly calculating it.

</details>

---

### Q13. How can string functions cause JOIN performance problems?

<details>
<summary><strong>Answer</strong></summary>

Expressions such as `LOWER(TRIM(a.key)) = LOWER(TRIM(b.key))` require transformations during the join and can prevent normal indexes from being used efficiently. Normalize keys earlier and join on the normalized columns when practical.

</details>

---

### Q14. How would you safely clean an email column in production?

<details>
<summary><strong>Answer</strong></summary>

First preview the transformation:

```sql
SELECT email, LOWER(TRIM(email)) AS cleaned_email
FROM customers;
```

Then validate affected records, use an appropriate transaction strategy, update the data, and verify the results before committing.

</details>

---

### Q15. What is SUBSTRING_INDEX useful for?

<details>
<summary><strong>Answer</strong></summary>

It extracts a portion of a string based on a delimiter. It is useful for parsing simple legacy values such as `username@domain.com`, but repeated use for multi-valued business data can indicate that the source should be normalized.

</details>

---

### Q16. Does LOWER() guarantee case-insensitive comparison?

<details>
<summary><strong>Answer</strong></summary>

No. String comparison behavior is also influenced by character set and collation. The correct solution depends on the schema and business requirement.

</details>

---

## 🔄 28. Quick Revision

| Function / Concept | Key Point |
|---|---|
| `LENGTH()` | Number of bytes |
| `CHAR_LENGTH()` | Number of characters |
| `UPPER()` | Uppercase conversion |
| `LOWER()` | Lowercase conversion |
| `TRIM()` | Removes surrounding spaces |
| `LTRIM()` | Removes leading spaces |
| `RTRIM()` | Removes trailing spaces |
| `CONCAT()` | Combines strings; NULL-sensitive |
| `CONCAT_WS()` | Combines strings with separator |
| `SUBSTRING()` | Extracts substring |
| `LEFT()` | Extracts prefix |
| `RIGHT()` | Extracts suffix |
| `LOCATE()` | Finds substring position |
| `INSTR()` | Finds substring position |
| `REPLACE()` | Replaces text |
| `LPAD()` | Left padding |
| `RPAD()` | Right padding |
| `SUBSTRING_INDEX()` | Extracts delimiter-based tokens |
| `REVERSE()` | Reverses text |
| `REPEAT()` | Repeats text |
| Collation | Controls important comparison/sort behavior |

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — worked MySQL string-function examples
- [`practice.sql`](./practice.sql) — hands-on cleaning, parsing, and interview exercises
