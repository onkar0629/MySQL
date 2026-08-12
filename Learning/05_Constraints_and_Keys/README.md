# 05 — Constraints and Keys

## 📌 Overview

Constraints and keys are database rules used to protect **data integrity, uniqueness, validity, and relationships**.

For a Data Engineer, constraints are important because they define what the database considers valid data. They also influence ETL design, schema evolution, deduplication, reconciliation, and downstream reliability.

---

## 🎯 Learning Objectives

By the end of this topic, you should be able to:

- Explain why database constraints are required.
- Use `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `NOT NULL`, `DEFAULT`, and `CHECK`.
- Understand candidate, primary, alternate, natural, and surrogate keys.
- Design single-column and composite keys.
- Understand parent-child relationships.
- Use foreign-key actions such as `CASCADE`, `SET NULL`, and restrictive behavior.
- Add and remove constraints with `ALTER TABLE`.
- Diagnose common integrity problems.
- Design constraints with Data Engineering workloads in mind.

---

## 🧠 1. What Is a Constraint?

A constraint is a rule enforced by the database to restrict invalid data or invalid relationships.

Example:

```sql
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    status VARCHAR(20) DEFAULT 'ACTIVE',
    age INT CHECK (age >= 18)
);
```

Here the database enforces several rules:

- `employee_id` must uniquely identify the row.
- `employee_name` cannot be `NULL`.
- `email` cannot contain duplicate non-NULL values under the applicable MySQL semantics.
- `status` gets a default when omitted.
- `age` must satisfy the `CHECK` condition.

This is stronger than relying only on application code because the rule is attached to the database schema itself.

---

## 🏗️ 2. Why Constraints Matter

Without constraints, an operational table could contain:

```text
customer_id = 101
customer_id = 101
customer_id = 101
```

if no uniqueness rule prevents duplicates.

Similarly, an order could reference a customer that does not exist.

Constraints help prevent these problems at the point where invalid data is written.

For Data Engineering, this matters because bad source data can propagate into:

```text
Source → Staging → Transformation → Warehouse → BI / Analytics
```

The earlier invalid data is detected, the cheaper it usually is to correct.

---

## 📚 3. Main MySQL Constraints

| Constraint | Purpose |
|---|---|
| `PRIMARY KEY` | Uniquely identifies each row |
| `FOREIGN KEY` | Maintains a relationship with another table |
| `UNIQUE` | Prevents duplicate values |
| `NOT NULL` | Requires a value |
| `DEFAULT` | Supplies a value when omitted |
| `CHECK` | Restricts values using a condition |

These constraints solve different problems and should not be treated as interchangeable.

---

## 🔑 4. PRIMARY KEY

A primary key is the table's main row identifier.

```sql
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL
);
```

A primary key:

- Uniquely identifies rows.
- Cannot contain `NULL`.
- Is the table's selected primary identifier.
- Can be referenced by foreign keys.
- Can consist of one or multiple columns.

A table has **one primary key constraint**, although that constraint may contain multiple columns.

### Why does a primary key matter?

Suppose you have:

```text
customer_id | customer_name
------------+--------------
101         | Asha
102         | Rahul
```

`customer_id` lets you identify exactly which customer a row represents.

---

## 🧩 5. Composite Primary Key

A composite primary key uses multiple columns together.

```sql
CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    PRIMARY KEY (order_id, product_id)
);
```

Here:

```text
order_id | product_id
---------+-----------
101      | 10
101      | 20
102      | 10
```

`order_id = 101` can appear more than once, and `product_id = 10` can appear more than once.

But this combination cannot repeat:

```text
(101, 10)
```

### Common use case

Many-to-many relationships often use composite keys in bridge or association tables.

---

## 🔗 6. FOREIGN KEY

A foreign key connects a child table to a parent table.

```sql
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);
```

Relationship:

```text
customers                 orders
---------                 ------
customer_id  <----------  customer_id
   parent                    child
```

The child table references a key in the parent table.

### Referential integrity

A foreign key helps prevent this situation:

```text
orders.customer_id = 9999

but customer 9999 does not exist
```

This is called an orphan reference.

---

## 🧱 7. Parent and Child Tables

Consider:

```text
Customer
--------
customer_id
customer_name

       1
       │
       │
       ├──────────< many
       │
Orders
------
order_id
customer_id
```

One customer can have many orders.

Therefore:

- `customers.customer_id` is the parent key.
- `orders.customer_id` is the foreign key.

Understanding this relationship becomes critical when you learn joins later.

---

## 🔐 8. UNIQUE Constraint

`UNIQUE` prevents duplicate values for a column or column combination.

```sql
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    email VARCHAR(255) UNIQUE
);
```

A second row with the same email would violate the uniqueness rule.

### Composite UNIQUE

```sql
CREATE TABLE inventory (
    warehouse_id INT,
    product_id INT,
    UNIQUE (warehouse_id, product_id)
);
```

This means the same product cannot be registered twice for the same warehouse.

But the product can exist in different warehouses.

---

## ⚖️ 9. PRIMARY KEY vs UNIQUE

| Feature | PRIMARY KEY | UNIQUE |
|---|---|---|
| Main row identifier | Yes | Not necessarily |
| Multiple per table | No | Yes |
| Allows NULL | No | MySQL permits NULL values subject to its unique-index semantics |
| Can be composite | Yes | Yes |
| Can be referenced by FK | Yes | A suitable unique key can be referenced |

A common design is:

```sql
customer_id BIGINT PRIMARY KEY,
email VARCHAR(255) UNIQUE
```

Here `customer_id` identifies the row, while `email` protects the business rule that email addresses should be unique.

---

## 🚫 10. NOT NULL

`NOT NULL` requires a value.

```sql
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL
);
```

This prevents:

```sql
INSERT INTO employees (employee_id, employee_name)
VALUES (1, NULL);
```

### When should you use it?

Use `NOT NULL` when missing data violates the business meaning.

For example:

```text
order_id      → required
order_date    → required
customer_id   → usually required
middle_name   → potentially optional
```

Do not make every column `NOT NULL` without understanding the domain.

---

## 🎯 11. DEFAULT

A `DEFAULT` value is used when an insert does not explicitly provide a value.

```sql
CREATE TABLE jobs (
    job_id INT PRIMARY KEY,
    status VARCHAR(20) DEFAULT 'PENDING'
);
```

Then:

```sql
INSERT INTO jobs (job_id)
VALUES (1);
```

can result in:

```text
job_id | status
-------+---------
1      | PENDING
```

Defaults are useful for:

- Status values
- Audit timestamps
- Flags
- Pipeline metadata

---

## ✅ 12. CHECK Constraint

A `CHECK` constraint restricts values using a condition.

```sql
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    price DECIMAL(10,2),
    CHECK (price >= 0)
);
```

Now negative prices are rejected by the constraint.

Another example:

```sql
age INT CHECK (age >= 18)
```

### Data Engineering use case

A pipeline target could enforce:

```sql
quantity INT CHECK (quantity >= 0)
```

This prevents obviously invalid records from entering the trusted table.

---

## 🔄 13. Foreign-Key Actions

Foreign keys can specify what should happen when a referenced parent row changes.

### ON DELETE CASCADE

```sql
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id)
ON DELETE CASCADE
```

Deleting a parent can automatically delete dependent child rows.

Use this only when child records genuinely have no independent meaning.

### ON DELETE SET NULL

```sql
FOREIGN KEY (manager_id)
REFERENCES employees(employee_id)
ON DELETE SET NULL
```

The child reference becomes `NULL` when the parent is deleted.

The child column must permit `NULL`.

### ON DELETE RESTRICT

The parent deletion is prevented while dependent child rows exist.

This is useful when accidental deletion of referenced business entities must be prevented.

### ON UPDATE CASCADE

```sql
ON UPDATE CASCADE
```

A change to the referenced key can propagate to the foreign key.

In practice, primary keys are normally stable, so relying heavily on key updates should be avoided when possible.

---

## 🧠 14. Types of Keys

### Candidate Key

A candidate key is a minimal column or column combination capable of uniquely identifying a row.

For example, if both `employee_id` and a guaranteed-unique `email` identify employees, both can be candidate keys.

### Primary Key

The candidate key selected as the main identifier.

### Alternate Key

A candidate key that was not selected as the primary key.

It is often enforced using `UNIQUE`.

### Natural Key

A key that comes from real business data.

Examples:

- Government-issued identifier
- Business registration number
- Product SKU

### Surrogate Key

A generated identifier with no business meaning.

```sql
customer_id BIGINT AUTO_INCREMENT PRIMARY KEY
```

Surrogate keys are common because business identifiers can change or have complicated semantics.

---

## 🏭 15. Surrogate Keys in Data Warehousing

A Data Warehouse dimension might contain:

```text
customer_sk | customer_id | customer_name
------------+-------------+--------------
10001       | C001        | Asha
10002       | C002        | Rahul
```

Here:

- `customer_sk` = surrogate key.
- `customer_id` = business/natural identifier.

Keeping both can be useful because the business identifier identifies the source entity while the surrogate key provides a warehouse-specific stable identifier.

This becomes particularly important for Slowly Changing Dimensions, which we will cover later.

---

## 🔢 16. AUTO_INCREMENT

`AUTO_INCREMENT` generates sequential integer values for suitable columns.

```sql
CREATE TABLE customers (
    customer_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL
);
```

Then:

```sql
INSERT INTO customers (customer_name)
VALUES ('Asha');
```

MySQL can generate the identifier.

Important distinction:

> `AUTO_INCREMENT` generates values. It is not itself a key constraint.

---

## 🧩 17. Adding Constraints After Table Creation

Constraints can be added with `ALTER TABLE`.

### Add Primary Key

```sql
ALTER TABLE customers
ADD PRIMARY KEY (customer_id);
```

### Add UNIQUE

```sql
ALTER TABLE customers
ADD CONSTRAINT uq_customer_email
UNIQUE (email);
```

### Add FOREIGN KEY

```sql
ALTER TABLE orders
ADD CONSTRAINT fk_orders_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);
```

### Add CHECK

```sql
ALTER TABLE products
ADD CONSTRAINT chk_product_price
CHECK (price >= 0);
```

Before adding a constraint to an existing table, check whether existing data already violates it.

---

## 🗑️ 18. Removing Constraints

A foreign key can be removed by its constraint name:

```sql
ALTER TABLE orders
DROP FOREIGN KEY fk_orders_customer;
```

For unique constraints, MySQL represents uniqueness through an index, so inspect the actual table definition before dropping the object.

```sql
SHOW CREATE TABLE orders;
```

### Important

Removing a constraint does not necessarily remove existing bad data. It removes the rule that would prevent future invalid data.

---

## 🔍 19. Constraint Validation Before Migration

Suppose you want to add:

```sql
UNIQUE (email)
```

First find duplicates:

```sql
SELECT email, COUNT(*) AS cnt
FROM customers
WHERE email IS NOT NULL
GROUP BY email
HAVING COUNT(*) > 1;
```

If duplicates exist, adding the constraint can fail.

Similarly, before adding a foreign key:

```sql
SELECT o.customer_id
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.customer_id IS NOT NULL
  AND c.customer_id IS NULL;
```

These are orphan references that must be addressed before the relationship can safely be enforced.

---

## 🏗️ 20. Constraints in Data Engineering

Constraints are particularly useful in operational databases, but analytical pipelines often need additional validation.

A typical workflow is:

```text
Source Data
    ↓
Schema Validation
    ↓
Data Quality Checks
    ↓
Staging
    ↓
Transformation
    ↓
Constraint / Business Validation
    ↓
Trusted Dataset
```

Important considerations:

- Source systems may contain unexpected data.
- Not every analytical platform enforces foreign keys physically.
- ETL jobs should validate business keys.
- Duplicate keys can cause fact multiplication.
- Nullability affects downstream calculations.
- Constraint changes are schema changes and should be tested.

---

## 🌎 21. Real-World Example — E-Commerce Schema

```sql
CREATE TABLE customers (
    customer_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    customer_name VARCHAR(100) NOT NULL
);

CREATE TABLE orders (
    order_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    order_amount DECIMAL(12,2) NOT NULL CHECK (order_amount >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);
```

This design establishes several rules:

1. Every customer has a unique system identifier.
2. Email cannot be duplicated.
3. Customer name is required.
4. Every order must reference a customer.
5. Order amount cannot be negative.
6. An omitted order status defaults to `PENDING`.

---

## ⚠️ 22. Common Mistakes

### Mistake 1 — Confusing primary and foreign keys

A primary key identifies rows in its own table. A foreign key references a key in another table.

### Mistake 2 — Assuming UNIQUE and PRIMARY KEY are identical

They have different roles and different table-level rules.

### Mistake 3 — Adding a constraint without profiling existing data

Existing duplicates or orphan references can prevent a constraint from being added.

### Mistake 4 — Using CASCADE without understanding the impact

One parent deletion can delete many child records.

### Mistake 5 — Using a natural key without considering change

Business identifiers can change or may not be globally stable.

### Mistake 6 — Assuming AUTO_INCREMENT is a constraint

It is a value-generation mechanism.

### Mistake 7 — Treating database constraints as the only data-quality layer

ETL pipelines still need validation, especially when consuming external or weakly controlled sources.

---

## ⚡ 23. Performance Considerations

Constraints can affect performance because many are backed by indexes or require validation during writes.

Consider:

- Primary keys influence row identification and indexing.
- Unique constraints require uniqueness checks.
- Foreign keys require referential checks.
- Additional indexes increase storage and write cost.
- Composite keys affect index width and access patterns.
- Very wide indexes can increase I/O.

Do not add constraints or indexes blindly. Design them according to integrity requirements and workload behavior.

---

## 🎤 24. Interview-Focused Questions

### Q1. What is the difference between a primary key and a unique key?

<details>
<summary><strong>Answer</strong></summary>

A primary key is the table's main row identifier. A table has one primary key constraint and its key columns cannot be `NULL`. A table can have multiple `UNIQUE` constraints for alternate identifiers. MySQL's handling of `NULL` in unique indexes also differs from a primary key, so `UNIQUE` should not be treated as simply another primary key.

</details>

---

### Q2. Can a primary key contain multiple columns?

<details>
<summary><strong>Answer</strong></summary>

Yes. This is a composite primary key. The combination of all key columns must be unique, even though individual columns may contain duplicate values.

</details>

---

### Q3. What is the difference between a primary key and a foreign key?

<details>
<summary><strong>Answer</strong></summary>

A primary key uniquely identifies a row in its own table. A foreign key stores a value that references a candidate/primary key in another table and is used to maintain referential integrity.

</details>

---

### Q4. Can a foreign key contain NULL?

<details>
<summary><strong>Answer</strong></summary>

Yes, if the foreign-key column allows `NULL`. A NULL foreign key represents an absent/unknown relationship rather than a reference to a parent row. If the relationship is mandatory, define the column as `NOT NULL`.

</details>

---

### Q5. What happens with ON DELETE CASCADE?

<details>
<summary><strong>Answer</strong></summary>

When a referenced parent row is deleted, matching child rows are automatically deleted. It can be appropriate when child rows have no independent meaning, but it should be used carefully because a single parent deletion can affect many rows.

</details>

---

### Q6. What is the difference between a natural key and a surrogate key?

<details>
<summary><strong>Answer</strong></summary>

A natural key comes from real business data, such as a business identifier. A surrogate key is an artificial identifier generated for the database. Surrogate keys are often useful in warehouse dimensions because business identifiers can change and because warehouse history may need multiple versions of the same business entity.

</details>

---

### Q7. Can a table have more than one UNIQUE constraint?

<details>
<summary><strong>Answer</strong></summary>

Yes. A table can have multiple unique constraints, each enforcing uniqueness for a different column or column combination.

</details>

---

### Q8. What is a composite key and where would you use it?

<details>
<summary><strong>Answer</strong></summary>

A composite key combines two or more columns to uniquely identify a row. It is common in association tables such as `order_items`, where the combination of `order_id` and `product_id` identifies one relationship row.

</details>

---

### Q9. How would you check for duplicate values before adding a UNIQUE constraint?

<details>
<summary><strong>Answer</strong></summary>

Group by the proposed unique columns and use `HAVING COUNT(*) > 1`:

```sql
SELECT email, COUNT(*) AS cnt
FROM customers
WHERE email IS NOT NULL
GROUP BY email
HAVING COUNT(*) > 1;
```

Any returned group must be resolved before the constraint can safely be enforced.

</details>

---

### Q10. How would you find orphan records before adding a foreign key?

<details>
<summary><strong>Answer</strong></summary>

Compare the child table against the parent table with a `LEFT JOIN`:

```sql
SELECT o.customer_id
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE o.customer_id IS NOT NULL
  AND c.customer_id IS NULL;
```

The result identifies child keys with no matching parent.

</details>

---

### Q11. Why should you profile data before adding a CHECK constraint?

<details>
<summary><strong>Answer</strong></summary>

Existing rows may violate the proposed condition. For example, adding `CHECK (price >= 0)` is unsafe if negative prices already exist. Profile and remediate invalid records before enforcing the rule.

</details>

---

### Q12. What is the difference between a candidate key and an alternate key?

<details>
<summary><strong>Answer</strong></summary>

A candidate key is any minimal set of columns capable of uniquely identifying a row. Once one candidate key is selected as the primary key, the remaining candidate keys are alternate keys.

</details>

---

### Q13. Why are surrogate keys common in Data Warehousing?

<details>
<summary><strong>Answer</strong></summary>

Surrogate keys provide stable warehouse identifiers independent of source-system business keys. They are especially useful when tracking historical versions of dimensions, where the same business entity can legitimately have multiple dimension rows over time.

</details>

---

### Q14. What should you check before adding a foreign key to a production table?

<details>
<summary><strong>Answer</strong></summary>

Check for orphan child records, verify compatible key data types, confirm parent-key uniqueness, understand application behavior, assess locking and migration impact, and test the change before production deployment.

</details>

---

## 🔄 25. Quick Revision

| Concept | Key Point |
|---|---|
| `PRIMARY KEY` | Main unique row identifier |
| `FOREIGN KEY` | Maintains parent-child relationships |
| `UNIQUE` | Prevents duplicate values |
| `NOT NULL` | Requires a value |
| `DEFAULT` | Supplies a value when omitted |
| `CHECK` | Enforces a condition |
| Composite Key | Uses multiple columns together |
| Candidate Key | Any minimal unique identifier |
| Alternate Key | Candidate key not chosen as primary |
| Natural Key | Comes from business data |
| Surrogate Key | Artificial database identifier |
| `AUTO_INCREMENT` | Generates numeric identifiers |
| Referential Integrity | Keeps relationships valid |
| `CASCADE` | Propagates selected parent changes |

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — worked examples for constraints, keys, and relationships
- [`practice.sql`](./practice.sql) — hands-on exercises and interview practice
