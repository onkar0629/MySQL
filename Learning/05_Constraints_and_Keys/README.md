# 05 — Constraints and Keys

## 📌 Overview

Constraints and keys are rules that protect **data integrity, consistency, uniqueness, and relationships** in a relational database.

This topic covers MySQL constraints from fundamentals through practical database-design and Data Engineering scenarios.

## 🎯 Learning Objectives

By the end of this topic, you should be able to:

- Explain why constraints are needed
- Use `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `NOT NULL`, `DEFAULT`, and `CHECK`
- Understand candidate, alternate, natural, and surrogate keys
- Create single-column and composite keys
- Understand parent-child relationships
- Control foreign-key actions such as `CASCADE`, `SET NULL`, and `RESTRICT`
- Add and modify constraints with `ALTER TABLE`
- Identify common integrity problems and design mistakes

---

## 1. What Is a Constraint?

A constraint is a database rule that restricts the values or relationships allowed in a table.

Example:

```sql
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    email VARCHAR(255) UNIQUE,
    employee_name VARCHAR(100) NOT NULL,
    status VARCHAR(20) DEFAULT 'active',
    age INT CHECK (age >= 18)
);
```

Constraints move important data-quality rules into the database instead of relying only on application code.

---

## 2. Main MySQL Constraints

| Constraint | Purpose |
|---|---|
| `PRIMARY KEY` | Uniquely identifies each row |
| `FOREIGN KEY` | Maintains a relationship with another table |
| `UNIQUE` | Prevents duplicate values |
| `NOT NULL` | Requires a value |
| `DEFAULT` | Supplies a value when one is not provided |
| `CHECK` | Restricts values using a condition |

---

## 3. PRIMARY KEY

A primary key uniquely identifies every row in a table.

```sql
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL
);
```

A primary key:

- Must be unique
- Cannot contain `NULL`
- A table can have only one primary key constraint
- Can contain multiple columns as a composite primary key

### Composite Primary Key

```sql
CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    PRIMARY KEY (order_id, product_id)
);
```

The combination of `order_id` and `product_id` identifies each row.

---

## 4. FOREIGN KEY

A foreign key connects a child table to a parent table.

```sql
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);
```

This helps prevent an order from referencing a customer that does not exist.

### Parent and Child

```text
customers                 orders
---------                 ------
customer_id  <----------  customer_id
```

The parent contains the referenced key; the child contains the foreign key.

---

## 5. Foreign-Key Actions

MySQL can define what happens when a referenced parent row is updated or deleted.

Common actions include:

| Action | Meaning |
|---|---|
| `RESTRICT` | Prevent the parent operation when dependent rows exist |
| `CASCADE` | Propagate the update/delete to child rows |
| `SET NULL` | Set the child foreign-key value to `NULL` |
| `NO ACTION` | Similar to restrictive behavior in MySQL/InnoDB |
| `SET DEFAULT` | Not supported as a normal MySQL foreign-key action |

Example:

```sql
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id)
ON DELETE CASCADE
ON UPDATE CASCADE
```

Use cascading actions deliberately. A delete cascade can remove many dependent rows.

---

## 6. UNIQUE Constraint

`UNIQUE` prevents duplicate values in a column or column combination.

```sql
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    email VARCHAR(255) UNIQUE
);
```

A composite unique constraint can enforce uniqueness across multiple columns:

```sql
UNIQUE (warehouse_id, product_id)
```

> [!IMPORTANT]
> `UNIQUE` and `PRIMARY KEY` are not identical. A table has one primary key, but it can have multiple unique constraints.

---

## 7. NOT NULL

`NOT NULL` requires a column to contain a value.

```sql
employee_name VARCHAR(100) NOT NULL
```

Use it when the business rule says that missing data is invalid.

Do not use `NOT NULL` automatically for every column. Optional attributes may legitimately need `NULL`.

---

## 8. DEFAULT

`DEFAULT` supplies a value when an `INSERT` does not provide one.

```sql
status VARCHAR(20) DEFAULT 'active'
```

Example:

```sql
INSERT INTO employees (employee_id, employee_name)
VALUES (1, 'Amit');
```

If `status` is omitted, MySQL can use the defined default.

---

## 9. CHECK Constraint

`CHECK` restricts values according to a condition.

```sql
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    price DECIMAL(10,2) CHECK (price >= 0)
);
```

Another example:

```sql
age INT CHECK (age >= 18)
```

Use `CHECK` for domain rules that can be expressed as a database condition.

---

## 10. Types of Keys

### Candidate Key

A candidate key is a column or column combination that can uniquely identify a row.

Example: both `employee_id` and a guaranteed-unique `email` could be candidate keys.

### Primary Key

The candidate key selected as the table's main identifier.

### Alternate Key

A candidate key that was not selected as the primary key, often enforced with `UNIQUE`.

### Natural Key

A key derived from real business data, such as a government-issued or business-defined identifier.

### Surrogate Key

An artificial identifier created specifically for the database, such as an auto-increment integer.

```sql
customer_id BIGINT AUTO_INCREMENT PRIMARY KEY
```

For many Data Engineering warehouse designs, surrogate keys are useful because business identifiers can change or have complex semantics.

---

## 11. AUTO_INCREMENT and Keys

`AUTO_INCREMENT` is commonly used with integer primary keys.

```sql
CREATE TABLE customers (
    customer_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL
);
```

It generates a new numeric value when one is not explicitly supplied.

`AUTO_INCREMENT` is a generation mechanism; it is not itself a constraint.

---

## 12. Adding Constraints with ALTER TABLE

Constraints can be added after table creation.

### Add Primary Key

```sql
ALTER TABLE customers
ADD PRIMARY KEY (customer_id);
```

### Add Unique Constraint

```sql
ALTER TABLE customers
ADD CONSTRAINT uq_customers_email UNIQUE (email);
```

### Add Foreign Key

```sql
ALTER TABLE orders
ADD CONSTRAINT fk_orders_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);
```

### Add CHECK

```sql
ALTER TABLE products
ADD CONSTRAINT chk_products_price
CHECK (price >= 0);
```

---

## 13. Dropping Constraints

Constraints can be removed when the schema requirements change.

```sql
ALTER TABLE orders
DROP FOREIGN KEY fk_orders_customer;
```

For a named unique constraint/index, the exact syntax depends on the object being removed; inspect the table definition before making schema changes.

Use caution in production because removing a constraint can allow invalid data to enter the system.

---

## 14. Constraints and Data Engineering

Constraints are especially useful in operational relational databases because they protect source-of-truth data.

For Data Engineering, also consider:

- Source-system constraints may be weaker than expected
- ETL/ELT pipelines should validate incoming data
- Foreign-key relationships may not exist physically in analytical platforms
- Duplicate business keys can create incorrect facts
- Nullability affects downstream transformations
- Schema changes should be versioned and tested

A pipeline should not assume that incoming data is clean simply because the source database has constraints.

---

## 15. Common Mistakes

- Confusing a primary key with a foreign key
- Allowing duplicate business identifiers
- Using `NULL` where a value is mandatory
- Creating a foreign key without matching parent data
- Choosing `CASCADE` without understanding its deletion impact
- Assuming `UNIQUE` and `PRIMARY KEY` are identical
- Treating `AUTO_INCREMENT` as a constraint
- Using a natural key without considering future changes
- Forgetting composite-key requirements
- Adding constraints to production without checking existing bad data

---

## 16. Interview-Focused Questions

### Q1. What is the difference between a primary key and a unique key?

<details>
<summary><strong>Answer</strong></summary>

A primary key is the main identifier for a table, cannot contain `NULL`, and a table has only one primary key constraint. A table can have multiple `UNIQUE` constraints. A unique constraint is used to prevent duplicate values for an alternate identifier.

</details>

---

### Q2. Can a primary key contain multiple columns?

<details>
<summary><strong>Answer</strong></summary>

Yes. This is called a composite primary key. The combination of the columns must be unique, even though each column individually may contain duplicate values.

</details>

---

### Q3. What is the difference between a primary key and a foreign key?

<details>
<summary><strong>Answer</strong></summary>

A primary key uniquely identifies rows in its own table. A foreign key references a key in another table and is used to maintain referential integrity between parent and child tables.

</details>

---

### Q4. Can a foreign key contain NULL?

<details>
<summary><strong>Answer</strong></summary>

Yes, unless the foreign-key column is also defined as `NOT NULL`. A `NULL` foreign key generally represents an optional relationship and does not reference a parent row.

</details>

---

### Q5. What happens when you use ON DELETE CASCADE?

<details>
<summary><strong>Answer</strong></summary>

When a referenced parent row is deleted, matching child rows are automatically deleted. It is useful when child records have no meaning without the parent, but it must be used carefully because one delete can remove many rows.

</details>

---

### Q6. What is the difference between a natural key and a surrogate key?

<details>
<summary><strong>Answer</strong></summary>

A natural key comes from real business data, while a surrogate key is an artificial identifier created by the system. Surrogate keys can simplify relationships and remain stable when business attributes change.

</details>

---

### Q7. Can a table have more than one UNIQUE constraint?

<details>
<summary><strong>Answer</strong></summary>

Yes. A table can have multiple unique constraints, each enforcing uniqueness for a different column or combination of columns.

</details>

---

### Q8. What is a composite key?

<details>
<summary><strong>Answer</strong></summary>

A composite key uses two or more columns together to uniquely identify a row. It is useful when no single column is sufficient to identify the record.

</details>

---

### Q9. Why should constraints be considered during ETL design?

<details>
<summary><strong>Answer</strong></summary>

Constraints describe data-integrity expectations. ETL pipelines should understand those expectations so that duplicates, invalid references, missing required values, and invalid domain values can be detected before loading trusted data.

</details>

---

### Q10. What should you check before adding a new constraint to an existing table?

<details>
<summary><strong>Answer</strong></summary>

First check whether existing rows already violate the proposed rule. Clean or remediate invalid data, test the migration, understand application dependencies, and then add the constraint safely.

</details>

---

## 17. Quick Revision

| Concept | Key Point |
|---|---|
| `PRIMARY KEY` | Main unique row identifier |
| `FOREIGN KEY` | Maintains parent-child relationships |
| `UNIQUE` | Prevents duplicate values |
| `NOT NULL` | Requires a value |
| `DEFAULT` | Supplies a value when omitted |
| `CHECK` | Enforces a condition |
| Composite Key | Uses multiple columns together |
| Natural Key | Comes from business data |
| Surrogate Key | Artificial system-generated identifier |
| `AUTO_INCREMENT` | Generates sequential numeric identifiers |
| Referential Integrity | Keeps relationships between tables valid |

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — worked examples for constraints, keys, and relationships
- [`practice.sql`](./practice.sql) — hands-on exercises and interview practice
