# 03 — MySQL Data Types

## 📌 Overview

MySQL data types define what kind of value a column can store. Choosing the correct data type affects **storage, validation, performance, indexing, and query behavior**.

This topic covers MySQL data types from fundamentals through practical Data Engineering considerations.

## 🎯 Learning Objectives

By the end of this topic, you should be able to:

- Explain why data types matter
- Choose appropriate numeric, string, date/time, and binary types
- Understand signed vs unsigned numeric types
- Distinguish `CHAR` from `VARCHAR`
- Choose between `DECIMAL` and floating-point types
- Work with `DATE`, `DATETIME`, `TIMESTAMP`, and `TIME`
- Understand `ENUM`, `SET`, `JSON`, and binary types
- Recognize storage and precision trade-offs
- Identify common data-type mistakes in production systems

---

## 1. What Is a Data Type?

A data type specifies the kind of data that a column, variable, or expression can represent.

Examples:

```sql
employee_id INT
employee_name VARCHAR(100)
salary DECIMAL(10, 2)
hire_date DATE
is_active BOOLEAN
```

A data type determines characteristics such as:

- What values are valid
- How much storage is required
- How comparisons work
- How arithmetic behaves
- How indexes and sorting behave

---

## 2. Major MySQL Data Type Categories

| Category | Common Types |
|---|---|
| Numeric | `TINYINT`, `SMALLINT`, `MEDIUMINT`, `INT`, `BIGINT`, `DECIMAL`, `FLOAT`, `DOUBLE` |
| String | `CHAR`, `VARCHAR`, `TEXT` and related types |
| Date & Time | `DATE`, `TIME`, `DATETIME`, `TIMESTAMP`, `YEAR` |
| Binary | `BINARY`, `VARBINARY`, `BLOB` |
| Boolean | `BOOLEAN`, `BOOL` |
| Enumeration | `ENUM`, `SET` |
| JSON | `JSON` |

---

## 3. Integer Types

MySQL provides several integer sizes:

| Type | Typical Use |
|---|---|
| `TINYINT` | Small counters, flags |
| `SMALLINT` | Small numeric ranges |
| `MEDIUMINT` | Medium numeric ranges |
| `INT` | General-purpose integer values |
| `BIGINT` | Very large identifiers or counts |

Use the smallest type that safely supports the expected domain, but do not optimize prematurely at the expense of correctness.

### Signed vs Unsigned

Integer types are signed by default. `UNSIGNED` removes negative values and increases the positive range.

```sql
age TINYINT UNSIGNED
quantity INT UNSIGNED
```

Use `UNSIGNED` only when negative values are genuinely invalid for the business domain.

---

## 4. Exact Numeric Types

### DECIMAL

`DECIMAL` stores exact fixed-point values and is appropriate for values where precision matters.

```sql
salary DECIMAL(10, 2)
price DECIMAL(12, 2)
```

`DECIMAL(10, 2)` means up to 10 total digits, with 2 digits after the decimal point.

Typical use cases:

- Money
- Financial calculations
- Prices
- Measurements requiring exact decimal precision

### FLOAT and DOUBLE

Floating-point types are approximate numeric types.

```sql
measurement DOUBLE
ratio FLOAT
```

They are useful for scientific or analytical measurements where approximate representation is acceptable.

> [!IMPORTANT]
> Do not choose `FLOAT` or `DOUBLE` for monetary values simply because they use floating-point representation. Exact financial values generally require `DECIMAL`.

---

## 5. CHAR vs VARCHAR

### CHAR

`CHAR(n)` is a fixed-length string type.

```sql
country_code CHAR(2)
```

It is useful when values have a consistently fixed length.

### VARCHAR

`VARCHAR(n)` is a variable-length string type.

```sql
employee_name VARCHAR(100)
email VARCHAR(255)
```

It is commonly preferred for variable-length text.

### Comparison

| `CHAR` | `VARCHAR` |
|---|---|
| Fixed length | Variable length |
| Good for fixed-size values | Good for varying-size values |
| Can be useful for codes | Common for names, emails, addresses |

---

## 6. TEXT Types

MySQL provides text types for larger character data, including `TINYTEXT`, `TEXT`, `MEDIUMTEXT`, and `LONGTEXT`.

Use text types when the value can be substantially larger than a normal `VARCHAR` column.

```sql
description TEXT
```

For normal bounded strings such as names and emails, a properly sized `VARCHAR` is usually more appropriate.

---

## 7. DATE and Time Types

### DATE

Stores a calendar date.

```sql
birth_date DATE
```

### TIME

Stores a time value.

```sql
start_time TIME
```

### DATETIME

Stores date and time together.

```sql
created_at DATETIME
```

### TIMESTAMP

Stores a date and time value with MySQL-specific timestamp behavior and is commonly used for event/audit timestamps.

```sql
updated_at TIMESTAMP
```

### YEAR

Stores a year value.

```sql
release_year YEAR
```

> [!TIP]
> For Data Engineering, be explicit about timestamp semantics: know whether a column represents an event time, ingestion time, update time, or business date.

---

## 8. Boolean Values

MySQL supports `BOOLEAN` and `BOOL` as aliases for `TINYINT(1)`.

```sql
is_active BOOLEAN
```

Typical values are represented as `0` and `1`.

```sql
INSERT INTO users (is_active)
VALUES (1);
```

---

## 9. ENUM

`ENUM` restricts a column to a predefined set of string values.

```sql
status ENUM('active', 'inactive', 'pending')
```

It can be useful for small, stable sets of values, but it should be used carefully when the allowed values may change frequently.

---

## 10. SET

`SET` allows a column to contain zero or more values selected from a predefined list.

```sql
skills SET('SQL', 'Python', 'Spark')
```

For many Data Engineering systems, a normalized child table or JSON structure may be more flexible when values are dynamic.

---

## 11. JSON

MySQL provides a native `JSON` data type for storing JSON documents.

```sql
metadata JSON
```

Example:

```sql
'{"source":"api","priority":"high"}'
```

JSON is useful when the structure is semi-structured or varies between records, but relational columns are often preferable for frequently queried, strongly structured attributes.

---

## 12. Binary Data Types

Binary types store raw bytes rather than character data.

Common types include:

- `BINARY`
- `VARBINARY`
- `BLOB`
- `MEDIUMBLOB`
- `LONGBLOB`

Typical use cases include binary payloads, hashes, or files. Large binary objects should be used deliberately because they can affect storage and query performance.

---

## 13. Choosing Data Types — Data Engineering Perspective

When designing a table, ask:

1. What values are valid?
2. Can the value be negative?
3. What is the maximum expected value?
4. Does decimal precision matter?
5. Is the string fixed or variable length?
6. Does the column represent a date, time, or timestamp?
7. How will the column be queried and indexed?
8. Is the data structured or semi-structured?
9. Could the domain grow beyond today's assumptions?

### Example

```sql
CREATE TABLE orders (
    order_id BIGINT,
    customer_id BIGINT,
    order_amount DECIMAL(12, 2),
    order_date DATE,
    created_at DATETIME,
    status VARCHAR(30),
    metadata JSON
);
```

The types communicate the intended domain of each attribute.

---

## 14. Common Mistakes

- Using `VARCHAR` for every column
- Using floating-point types for exact monetary values
- Choosing `INT` without considering future range requirements
- Storing dates as strings
- Using `TEXT` when a bounded `VARCHAR` is sufficient
- Confusing `DATE` with `DATETIME`
- Assuming `BOOLEAN` is a separate storage type in MySQL
- Using `ENUM` for rapidly changing business values
- Ignoring character set and collation requirements
- Choosing a type only by storage size without considering correctness

---

## 15. Interview-Focused Questions

Try to answer each question yourself before opening the answer.

### Q1. Why are data types important in a relational database?

<details>
<summary><strong>Answer</strong></summary>

Data types define valid values and influence storage, precision, comparisons, sorting, indexing, and query behavior. Choosing an appropriate type also communicates the business meaning of a column.

</details>

---

### Q2. What is the difference between INT and BIGINT?

<details>
<summary><strong>Answer</strong></summary>

Both store integer values, but `BIGINT` supports a much larger range and requires more storage. `BIGINT` is appropriate when identifiers or counts may exceed the safe range of `INT`.

</details>

---

### Q3. What is the difference between CHAR and VARCHAR?

<details>
<summary><strong>Answer</strong></summary>

`CHAR` is fixed-length, while `VARCHAR` is variable-length. `CHAR` is useful for consistently sized values such as short codes; `VARCHAR` is generally better for values whose lengths vary.

</details>

---

### Q4. Why should DECIMAL be preferred over FLOAT for money?

<details>
<summary><strong>Answer</strong></summary>

`DECIMAL` represents fixed-point decimal values exactly within its defined precision, while floating-point types use approximate binary representation. Financial calculations generally require exact decimal behavior.

</details>

---

### Q5. What is the difference between DATE, DATETIME, and TIMESTAMP?

<details>
<summary><strong>Answer</strong></summary>

`DATE` stores only a calendar date. `DATETIME` stores date and time together. `TIMESTAMP` also stores date and time but has MySQL-specific timestamp behavior and is commonly used for audit or event timestamp columns.

</details>

---

### Q6. Is BOOLEAN a true separate data type in MySQL?

<details>
<summary><strong>Answer</strong></summary>

MySQL treats `BOOLEAN` and `BOOL` as aliases for `TINYINT(1)`. Conventionally, `0` represents false and `1` represents true.

</details>

---

### Q7. When would you use JSON instead of normal columns?

<details>
<summary><strong>Answer</strong></summary>

JSON is useful for semi-structured or variable attributes that do not fit a stable relational schema. Frequently queried and strongly structured attributes are usually better represented as normal columns.

</details>

---

### Q8. What factors should you consider when choosing a data type for a Data Engineering table?

<details>
<summary><strong>Answer</strong></summary>

Consider the valid domain, maximum range, precision requirements, nullability, expected growth, query patterns, indexing, storage, interoperability, and whether the data is structured or semi-structured.

</details>

---

## 16. Quick Revision

| Concept | Key Point |
|---|---|
| `INT` | General-purpose integer |
| `BIGINT` | Large integer range |
| `DECIMAL` | Exact fixed-point number |
| `FLOAT` / `DOUBLE` | Approximate floating-point numbers |
| `CHAR` | Fixed-length string |
| `VARCHAR` | Variable-length string |
| `TEXT` | Larger text values |
| `DATE` | Date only |
| `DATETIME` | Date + time |
| `TIMESTAMP` | Date + time with MySQL timestamp behavior |
| `BOOLEAN` | Alias for `TINYINT(1)` |
| `ENUM` | One predefined value |
| `SET` | Zero or more predefined values |
| `JSON` | Semi-structured JSON document |
| `BLOB` | Binary data |

---

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — worked examples for MySQL data types
- [`practice.sql`](./practice.sql) — hands-on exercises and interview practice
