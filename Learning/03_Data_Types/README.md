# 03 — MySQL Data Types

> [!NOTE]
> **Goal:** Understand how MySQL data types represent values, how to choose them correctly, and how data-type decisions affect storage, precision, indexing, validation, interoperability, and Data Engineering workloads.

## 📌 Overview

A **data type** defines the kind of value a column can store. Choosing the right type is not just a syntax decision: it is a **data-modeling decision**.

For example:

```sql
employee_id BIGINT
employee_name VARCHAR(100)
salary DECIMAL(12, 2)
hire_date DATE
created_at DATETIME
is_active BOOLEAN
metadata JSON
```

A good data type should represent the business domain accurately while leaving enough room for future growth.

---

## 🎯 Learning Objectives

By the end of this topic, you should be able to:

- Explain why data types matter in MySQL.
- Classify MySQL data types by category.
- Choose appropriate integer types and understand signed vs unsigned.
- Explain `DECIMAL`, `FLOAT`, and `DOUBLE`.
- Distinguish `CHAR`, `VARCHAR`, and `TEXT`.
- Choose between `DATE`, `TIME`, `DATETIME`, and `TIMESTAMP`.
- Understand MySQL boolean behavior.
- Explain `ENUM`, `SET`, `JSON`, and binary types.
- Understand precision, range, storage, and indexing trade-offs.
- Avoid common production data-type mistakes.
- Make data-type decisions from a Data Engineering perspective.

---

# 📚 Core Concepts

## 1. What Is a Data Type?

A data type specifies the kind of value a column, expression, or variable can represent.

```sql
CREATE TABLE employees (
    employee_id INT,
    employee_name VARCHAR(100),
    salary DECIMAL(10, 2),
    hire_date DATE,
    is_active BOOLEAN
);
```

The data type influences:

- Valid values
- Storage requirements
- Precision and range
- Comparison behavior
- Sorting
- Arithmetic
- Indexing
- Query behavior
- Application interoperability

> [!IMPORTANT]
> Do not choose a data type only because it can store today's values. Consider the **business domain, future growth, query patterns, and correctness**.

---

## 2. Major MySQL Data Type Categories

| Category | Common Types |
|---|---|
| Numeric | `TINYINT`, `SMALLINT`, `MEDIUMINT`, `INT`, `BIGINT`, `DECIMAL`, `FLOAT`, `DOUBLE` |
| String | `CHAR`, `VARCHAR`, `TEXT`, `TINYTEXT`, `MEDIUMTEXT`, `LONGTEXT` |
| Date & Time | `DATE`, `TIME`, `DATETIME`, `TIMESTAMP`, `YEAR` |
| Binary | `BINARY`, `VARBINARY`, `BLOB`, `MEDIUMBLOB`, `LONGBLOB` |
| Boolean | `BOOLEAN`, `BOOL` |
| Enumeration | `ENUM`, `SET` |
| JSON | `JSON` |

---

## 3. Integer Types

MySQL provides several integer types with different ranges and storage requirements.

| Type | Storage | Signed Range | Typical Use |
|---|---:|---|---|
| `TINYINT` | 1 byte | -128 to 127 | Small counters, flags |
| `SMALLINT` | 2 bytes | -32,768 to 32,767 | Small numeric values |
| `MEDIUMINT` | 3 bytes | -8,388,608 to 8,388,607 | Medium ranges |
| `INT` | 4 bytes | -2,147,483,648 to 2,147,483,647 | General-purpose integers |
| `BIGINT` | 8 bytes | Very large range | Large IDs, counts, event identifiers |

The exact range is also affected by whether the type is `UNSIGNED`.

### Example

```sql
employee_id BIGINT
age TINYINT UNSIGNED
quantity INT UNSIGNED
```

### Signed vs Unsigned

Signed integers support negative and positive values. `UNSIGNED` removes negative values and increases the positive range.

```sql
age TINYINT UNSIGNED
```

If age can never be negative, `UNSIGNED` can express that domain more accurately.

> [!TIP]
> Use `UNSIGNED` when it genuinely matches the business domain. Do not add it automatically to every integer column.

---

## 4. Choosing INT vs BIGINT

Suppose an application currently has 50 million records.

```sql
id INT
```

may be sufficient depending on the identifier domain.

But a globally generated event identifier or very large warehouse table may justify:

```sql
id BIGINT
```

The important question is not simply:

> "Which type uses less storage?"

Ask:

> "What is the maximum value this column can realistically reach during the system's lifetime?"

This is particularly important for:

- Event IDs
- Transaction IDs
- Log records
- Fact-table row identifiers
- Large counters

---

## 5. Exact Numeric Types — DECIMAL

`DECIMAL` is an exact fixed-point numeric type.

```sql
price DECIMAL(10, 2)
```

`DECIMAL(10, 2)` means:

- `10` = total number of digits
- `2` = digits after the decimal point

Therefore, up to 8 digits can appear before the decimal point.

Example values:

```text
2499.99
799.50
129999.95
```

### Typical Uses

Use `DECIMAL` when exact decimal arithmetic matters:

- Money
- Prices
- Tax amounts
- Account balances
- Financial reporting
- Exact business measurements

> [!IMPORTANT]
> `DECIMAL` is generally preferred for monetary values because floating-point types represent numbers approximately.

---

## 6. FLOAT and DOUBLE

`FLOAT` and `DOUBLE` are approximate floating-point types.

```sql
sensor_value FLOAT
measurement DOUBLE
```

They are useful when approximate representation is acceptable, such as:

- Sensor measurements
- Scientific calculations
- Some analytical workloads
- Ratios and continuous measurements

### Why not FLOAT for money?

Binary floating-point representation can produce values that are extremely close to the intended decimal value but not exactly equal to it.

For example, a financial calculation involving repeated addition, subtraction, or rounding can expose these differences.

Use:

```sql
amount DECIMAL(12, 2)
```

rather than:

```sql
amount FLOAT
```

for normal monetary storage.

---

## 7. CHAR vs VARCHAR

### CHAR

`CHAR(n)` is fixed-length character data.

```sql
country_code CHAR(2)
```

Good candidates include values with consistently fixed size:

```text
IN
US
UK
CA
```

### VARCHAR

`VARCHAR(n)` stores variable-length character strings.

```sql
name VARCHAR(100)
email VARCHAR(255)
city VARCHAR(100)
```

It is commonly used for names, emails, addresses, labels, and other bounded strings.

### Comparison

| `CHAR` | `VARCHAR` |
|---|---|
| Fixed-length | Variable-length |
| Useful for fixed-size values | Useful for varying-size values |
| Appropriate for some codes | Common for names and emails |

> [!NOTE]
> Do not assume `CHAR` is automatically faster. Choose based on the data's actual characteristics and workload.

---

## 8. VARCHAR Length Is a Limit, Not a Target

Consider:

```sql
name VARCHAR(100)
```

This does not mean every name consumes 100 characters. It defines a maximum length for the column.

Do not choose:

```sql
name VARCHAR(1000)
```

simply because it is convenient if the domain is actually a bounded short string.

Good schema design communicates the expected domain without being unnecessarily restrictive.

---

## 9. TEXT Types

MySQL provides:

- `TINYTEXT`
- `TEXT`
- `MEDIUMTEXT`
- `LONGTEXT`

Example:

```sql
description TEXT
```

Use text types for larger character content when a normal bounded `VARCHAR` is not appropriate.

Typical examples:

- Article content
- Long descriptions
- Large textual payloads
- Documentation

For normal fields such as names, email addresses, and country codes, prefer an appropriately sized `VARCHAR`.

---

## 10. DATE, TIME, DATETIME, TIMESTAMP, YEAR

### DATE

Stores a calendar date.

```sql
birth_date DATE
```

Example:

```text
2026-08-13
```

Use it when the time of day is not part of the business meaning.

### TIME

Stores a time value.

```sql
start_time TIME
```

Example:

```text
09:30:00
```

### DATETIME

Stores date and time together.

```sql
created_at DATETIME
```

Example:

```text
2026-08-13 09:30:00
```

### TIMESTAMP

Stores date and time and has MySQL-specific timestamp behavior, including timezone-related conversion behavior for values retrieved and stored by the server/session.

It is commonly used for:

- Audit timestamps
- Row creation/update timestamps
- Event timestamps

### YEAR

Stores a year value.

```sql
release_year YEAR
```

---

## 11. DATE vs DATETIME — Business Meaning

Suppose a customer places an order on August 13.

If the requirement is only:

> "Which day was the order placed?"

then:

```sql
order_date DATE
```

may be sufficient.

If the requirement is:

> "At exactly what time did the order enter the system?"

then:

```sql
created_at DATETIME
```

or an appropriate timestamp representation is required.

The type should reflect the **business meaning**, not just the source format.

---

## 12. Event Time vs Ingestion Time

This distinction is especially important in Data Engineering.

Consider an event generated by an application at:

```text
event_time = 2026-08-13 10:00:00
```

but received by the pipeline at:

```text
ingested_at = 2026-08-13 10:03:12
```

These are different facts.

A robust table may contain:

```sql
event_time DATETIME,
ingested_at DATETIME
```

Do not overwrite event time with ingestion time just because the pipeline receives the record later.

---

## 13. Boolean Values in MySQL

MySQL supports:

```sql
BOOLEAN
BOOL
```

These are aliases for `TINYINT(1)`.

Example:

```sql
is_active BOOLEAN
```

Typical values are:

```sql
TRUE
FALSE
```

Internally, MySQL represents these using numeric behavior such as `1` and `0`.

```sql
INSERT INTO accounts (is_active)
VALUES (TRUE);
```

---

## 14. ENUM

`ENUM` restricts a column to one value from a predefined list.

```sql
status ENUM('pending', 'running', 'completed', 'failed')
```

This can be useful when the domain is:

- Small
- Stable
- Controlled by the database schema

### Caution

If business values change frequently, modifying an `ENUM` definition can become inconvenient.

For highly dynamic domains, a lookup/reference table or `VARCHAR` plus validation may be more flexible.

---

## 15. SET

`SET` allows zero or more values from a predefined list.

```sql
skills SET('SQL', 'Python', 'Spark', 'Hadoop')
```

An example value could represent:

```text
SQL,Python,Spark
```

### Why use SET carefully?

Multi-valued attributes can become harder to query, validate, migrate, and integrate with other systems.

A normalized design may instead use:

```text
employees
employee_skills
skills
```

or a suitable JSON structure when semi-structured data is genuinely required.

---

## 16. JSON

MySQL provides a native `JSON` data type.

```sql
metadata JSON
```

Example:

```json
{"source":"api","priority":"high"}
```

JSON is useful when attributes are:

- Semi-structured
- Variable between records
- Naturally represented as nested objects/arrays

Example:

```sql
CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY,
    metadata JSON
);
```

You can extract values from JSON:

```sql
SELECT
    order_id,
    metadata->>'$.source' AS source
FROM orders;
```

> [!IMPORTANT]
> Do not put every column into JSON. Frequently queried, strongly structured attributes are usually easier to validate, index, join, and analyze as relational columns.

---

## 17. Binary Data Types

Binary types store raw bytes rather than normal character strings.

Common types:

- `BINARY`
- `VARBINARY`
- `BLOB`
- `MEDIUMBLOB`
- `LONGBLOB`

Example:

```sql
hash_value VARBINARY(32)
```

Binary types may be appropriate for:

- Hash values
- Raw binary payloads
- Encoded identifiers
- Files or binary objects

Large binary objects should be handled carefully because they can increase storage, backup, network, and query costs.

---

# 🔬 Deep Dive

## 18. Precision vs Range

Two different questions must be separated:

### Range

How large or small can the value be?

Example:

```text
INT → smaller range
BIGINT → much larger range
```

### Precision

How accurately can a numeric value be represented?

For example:

```text
DECIMAL → exact decimal representation within defined precision
DOUBLE  → approximate floating-point representation
```

A good data model considers both.

---

## 19. DECIMAL Precision and Scale

Consider:

```sql
amount DECIMAL(12, 2)
```

This means:

```text
12 total digits
 2 digits after decimal point
10 digits before decimal point
```

Examples that fit:

```text
1299999999.99
9999999999.99
```

The exact maximum depends on the precision/scale definition and sign.

> [!TIP]
> Always choose precision and scale from the business domain. Do not blindly use `DECIMAL(10,2)` for every financial column.

---

## 20. NULL Is Not a Data Type

`NULL` represents the absence of a value or an unknown/missing value. It is not the same as zero or an empty string.

```text
NULL       → no value / unknown
0          → numeric zero
''         → empty string
```

Example:

```sql
CREATE TABLE scores (
    student_id INT,
    score DECIMAL(5,2)
);
```

A missing score can be represented as:

```sql
NULL
```

Do not use special values such as `-1` to represent missing data unless the business domain explicitly defines that convention.

---

## 21. Data Type and Indexing

Data types also influence indexes.

Suppose two columns contain the same logical identifier:

```sql
customer_id INT
```

and:

```sql
customer_id VARCHAR(100)
```

If the identifier is truly numeric, storing it as a numeric type can avoid unnecessary string comparisons and may produce a more compact representation.

The correct choice depends on the identifier's semantics. Do not convert a genuinely alphanumeric identifier into an integer simply for performance.

---

## 22. Data Type and Joins

Join columns should normally use compatible data types.

Prefer:

```sql
customers.customer_id BIGINT
orders.customer_id BIGINT
```

over unnecessary mismatches such as:

```sql
customers.customer_id BIGINT
orders.customer_id VARCHAR(50)
```

Type mismatches can create conversion work, complicate query plans, and increase the risk of inconsistent data.

> [!IMPORTANT]
> When designing primary and foreign keys, keep the corresponding columns compatible in type and semantics.

---

## 23. Data Type and Data Quality

A good data type can act as part of your data-quality strategy.

For example:

```sql
age TINYINT UNSIGNED
```

communicates that negative ages are not valid.

Similarly:

```sql
amount DECIMAL(12,2)
```

communicates an exact decimal business value.

Schema design is therefore one layer of data validation.

---

## 24. Data Type and ETL/ELT Pipelines

Data Engineers frequently transform data between systems.

Example source:

```text
"2026-08-13"
```

Target:

```sql
order_date DATE
```

The pipeline may need to parse and validate the source value before loading it.

Another example:

```text
source_amount = "12999.95"
```

Target:

```sql
amount DECIMAL(12,2)
```

The pipeline should validate malformed values rather than silently converting them into incorrect data.

---

## 25. Data Type and Schema Evolution

Data Engineers should think about what happens when the domain grows.

For example, if a source system initially sends:

```text
status = pending | completed
```

but later introduces:

```text
cancelled
refunded
partially_refunded
```

an overly rigid representation can become difficult to evolve.

This is one reason `ENUM` should be used deliberately for domains that are truly small and stable.

---

# 🌎 Real-World Examples

## Example 1 — E-Commerce Orders

```sql
CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    order_amount DECIMAL(12,2) NOT NULL,
    order_date DATE NOT NULL,
    created_at DATETIME NOT NULL,
    status VARCHAR(30) NOT NULL,
    metadata JSON
);
```

Reasoning:

- `BIGINT` → scalable identifiers
- `DECIMAL` → exact money
- `DATE` → business order date
- `DATETIME` → exact creation time
- `VARCHAR` → status that may evolve
- `JSON` → optional semi-structured metadata

---

## Example 2 — IoT Sensor Data

```sql
CREATE TABLE sensor_readings (
    sensor_id BIGINT,
    event_time DATETIME,
    temperature DOUBLE,
    humidity DOUBLE,
    ingested_at DATETIME
);
```

Approximate floating-point types may be appropriate for physical measurements where exact decimal arithmetic is not the primary requirement.

---

## Example 3 — Customer Profile

```sql
CREATE TABLE customers (
    customer_id BIGINT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(255),
    country_code CHAR(2),
    date_of_birth DATE,
    is_active BOOLEAN
);
```

Each type communicates the intended domain of the attribute.

---

# 🏗️ Data Engineering Use Cases

## 1. Data Modeling

Choose types during source-to-target schema design rather than treating them as an afterthought.

## 2. ETL / ELT

Convert source representations into validated target types.

## 3. Data Warehousing

Correct numeric and temporal types improve consistency across fact and dimension tables.

## 4. Schema Validation

Pipelines can compare expected and actual column types before loading data.

## 5. Data Quality

Types can prevent or expose invalid values before downstream processing.

## 6. Performance

Appropriate types can reduce unnecessary storage and make indexing and comparisons more efficient.

## 7. Schema Evolution

Type choices should consider future source-system and business changes.

---

# ⚡ Performance and Operational Considerations

Data type selection can affect:

- Row size
- Index size
- Memory usage
- Disk usage
- Network transfer
- Sorting
- Joins
- Query execution
- Backup size
- ETL throughput

However, **smaller is not automatically better**.

For example, choosing `SMALLINT` for an identifier that eventually exceeds its range is worse than choosing an appropriate larger type from the beginning.

The correct priority is:

```text
Correctness
    ↓
Business domain
    ↓
Future growth
    ↓
Query / indexing requirements
    ↓
Storage and performance optimization
```

---

# ⚠️ Common Mistakes

### Mistake 1 — Using VARCHAR for everything

```sql
age VARCHAR(10)
price VARCHAR(20)
order_date VARCHAR(30)
```

This loses useful type semantics and makes validation and computation harder.

### Mistake 2 — Using FLOAT for money

Use an exact decimal type for normal financial values.

### Mistake 3 — Storing dates as strings

Prefer `DATE`, `DATETIME`, or `TIMESTAMP` according to the business meaning.

### Mistake 4 — Choosing INT without considering growth

A primary key may outgrow `INT` in a high-volume system.

### Mistake 5 — Using TEXT unnecessarily

Use bounded `VARCHAR` when the domain is naturally bounded and normal string operations are sufficient.

### Mistake 6 — Treating BOOLEAN as a separate storage type

In MySQL, `BOOLEAN`/`BOOL` are aliases for `TINYINT(1)`.

### Mistake 7 — Overusing ENUM

An `ENUM` can become inconvenient when business values change frequently.

### Mistake 8 — Putting structured attributes into JSON

If an attribute is frequently filtered, joined, aggregated, or constrained, a normal relational column may be a better design.

### Mistake 9 — Mixing incompatible key types

Primary and foreign keys should normally use compatible data types.

### Mistake 10 — Confusing event time and ingestion time

A late-arriving event can have an earlier business event time than its ingestion timestamp.

### Mistake 11 — Ignoring character set and collation

Text comparison, sorting, and multilingual support depend on these settings.

### Mistake 12 — Optimizing storage before correctness

A type that is too small creates data-quality and production problems that are usually more expensive than the storage saved.

---

# 🎤 Interview-Focused Questions

Try to answer each question yourself before opening the answer.

### Q1. Why are data types important in a relational database?

<details>
<summary><strong>Answer</strong></summary>

Data types define valid values and influence storage, precision, comparisons, sorting, indexing, arithmetic, and query behavior. They also communicate the intended business meaning of a column.

</details>

---

### Q2. What is the difference between INT and BIGINT?

<details>
<summary><strong>Answer</strong></summary>

Both store integer values, but `BIGINT` supports a much larger range and uses more storage. The correct choice depends on the expected domain and future growth of the value.

</details>

---

### Q3. What is the difference between signed and unsigned integers?

<details>
<summary><strong>Answer</strong></summary>

Signed integers allow negative and positive values. `UNSIGNED` removes the negative range and provides a larger positive range. It should be used when negative values are invalid for the business domain.

</details>

---

### Q4. What is the difference between CHAR and VARCHAR?

<details>
<summary><strong>Answer</strong></summary>

`CHAR` is fixed-length, while `VARCHAR` is variable-length. `CHAR` can be suitable for consistently sized values such as country codes; `VARCHAR` is commonly used for names, emails, and other variable-length strings.

</details>

---

### Q5. Why should DECIMAL generally be preferred over FLOAT for money?

<details>
<summary><strong>Answer</strong></summary>

`DECIMAL` represents fixed-point decimal values exactly within its defined precision and scale. Floating-point types use approximate binary representation, which can introduce small representation errors that are undesirable for financial calculations.

</details>

---

### Q6. What does DECIMAL(10,2) mean?

<details>
<summary><strong>Answer</strong></summary>

It defines a fixed-point number with 10 total digits and 2 digits after the decimal point. Therefore, up to 8 digits are available before the decimal point.

</details>

---

### Q7. What is the difference between DATE, DATETIME, and TIMESTAMP?

<details>
<summary><strong>Answer</strong></summary>

`DATE` stores a calendar date only. `DATETIME` stores date and time without the same automatic timezone conversion behavior associated with `TIMESTAMP`. `TIMESTAMP` stores date/time values with MySQL-specific timestamp behavior and is commonly used for audit or event timestamps.

</details>

---

### Q8. Is BOOLEAN a true separate data type in MySQL?

<details>
<summary><strong>Answer</strong></summary>

No. `BOOLEAN` and `BOOL` are aliases for `TINYINT(1)` in MySQL. Conventionally, `0` represents false and `1` represents true.

</details>

---

### Q9. When would you use JSON instead of normal columns?

<details>
<summary><strong>Answer</strong></summary>

Use JSON when data is naturally semi-structured, nested, or variable between records. Strongly structured attributes that are frequently queried, joined, indexed, or constrained are usually better modeled as relational columns.

</details>

---

### Q10. What is ENUM and when should you avoid it?

<details>
<summary><strong>Answer</strong></summary>

`ENUM` restricts a column to one value from a predefined list. It can be useful for small, stable domains. It should be reconsidered when allowed values change frequently or are managed dynamically by the business.

</details>

---

### Q11. What is the difference between NULL, 0, and an empty string?

<details>
<summary><strong>Answer</strong></summary>

`NULL` represents missing or unknown information. `0` is a numeric value equal to zero. `''` is an empty string. They have different meanings and should not be used interchangeably.

</details>

---

### Q12. Why should primary and foreign key columns have compatible data types?

<details>
<summary><strong>Answer</strong></summary>

Compatible types reduce implicit conversions, improve consistency, and help avoid unexpected join or comparison behavior. The columns should also have compatible semantics, not just similar syntax.

</details>

---

### Q13. You are designing an order table. Would you store order amount as FLOAT or DECIMAL?

<details>
<summary><strong>Answer</strong></summary>

Use `DECIMAL`, for example:

```sql
order_amount DECIMAL(12,2)
```

because an order amount is normally a financial value requiring exact decimal behavior.

</details>

---

### Q14. A sensor produces temperature readings such as 23.456789. Would DECIMAL always be the best choice?

<details>
<summary><strong>Answer</strong></summary>

Not necessarily. If approximate numerical representation is acceptable and the workload is analytical/scientific, `FLOAT` or `DOUBLE` may be appropriate. The decision depends on the required precision and business meaning.

</details>

---

### Q15. Why might you choose BIGINT for an event ID?

<details>
<summary><strong>Answer</strong></summary>

High-volume event systems can generate very large numbers of records. `BIGINT` provides a much larger integer range and reduces the risk of exhausting the identifier space as the system grows.

</details>

---

### Q16. What is the difference between event time and ingestion time?

<details>
<summary><strong>Answer</strong></summary>

**Event time** is when the business/application event actually occurred. **Ingestion time** is when the pipeline or database received the record. They can differ because of network delays, retries, buffering, or late-arriving data.

</details>

---

### Q17. Why is using VARCHAR for every column considered poor schema design?

<details>
<summary><strong>Answer</strong></summary>

It removes useful type semantics. Numeric calculations become harder, date validation becomes weaker, storage may be inefficient, and indexing/comparison behavior may be less appropriate. Strongly typed columns communicate and enforce the intended domain.

</details>

---

### Q18. When would TEXT be preferred over VARCHAR?

<details>
<summary><strong>Answer</strong></summary>

Use a text type when the value can contain substantially larger text than a normal bounded string. Examples include article content or large descriptions. For bounded attributes such as names and emails, `VARCHAR` is generally more appropriate.

</details>

---

### Q19. An interviewer asks: "How would you choose a data type for a new column?"

<details>
<summary><strong>Answer</strong></summary>

I would first identify the business meaning and valid domain, then determine range and precision requirements, expected growth, nullability, query/index patterns, interoperability requirements, and whether the data is structured or semi-structured. I would optimize storage only after correctness and future growth are covered.

</details>

---

### Q20. A source system sends `customer_id` as VARCHAR, but the target database models it as BIGINT. What should a Data Engineer consider before converting it?

<details>
<summary><strong>Answer</strong></summary>

First confirm that the identifier is truly numeric and never contains leading zeros, letters, signs, or meaningful formatting. Check the full historical domain and future requirements. If the identifier is actually an alphanumeric business key, converting it to `BIGINT` would be incorrect even if current values look numeric.

</details>

---

# 🔄 Quick Revision

| Type / Concept | Key Point |
|---|---|
| `TINYINT` | Very small integer |
| `SMALLINT` | Small integer |
| `MEDIUMINT` | Medium integer |
| `INT` | General-purpose integer |
| `BIGINT` | Large integer range |
| `DECIMAL` | Exact fixed-point number |
| `FLOAT` | Approximate floating-point number |
| `DOUBLE` | Higher-precision approximate floating-point number |
| `CHAR` | Fixed-length string |
| `VARCHAR` | Variable-length string |
| `TEXT` | Large text |
| `DATE` | Calendar date |
| `TIME` | Time value |
| `DATETIME` | Date + time |
| `TIMESTAMP` | Date + time with MySQL-specific timestamp behavior |
| `YEAR` | Year value |
| `BOOLEAN` | Alias for `TINYINT(1)` |
| `ENUM` | One value from predefined options |
| `SET` | Zero or more predefined options |
| `JSON` | Semi-structured JSON document |
| `BINARY` / `VARBINARY` | Raw binary values |
| `BLOB` | Binary large object |
| `NULL` | Missing / unknown value, not a data type |

### Essential Examples

```sql
CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    order_amount DECIMAL(12, 2) NOT NULL,
    order_date DATE NOT NULL,
    created_at DATETIME NOT NULL,
    status VARCHAR(30),
    metadata JSON
);
```

---

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — worked examples covering numeric, string, temporal, JSON, binary, NULL, and practical data-type choices
- [`practice.sql`](./practice.sql) — hands-on exercises and interview practice
