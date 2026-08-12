# 04 — Create and Alter Tables

## 📌 Overview

Tables are the core storage structures of a relational database. In MySQL, `CREATE TABLE` defines the initial schema, while `ALTER TABLE` changes an existing schema as requirements evolve.

For a Data Engineer, table definition is more than syntax: column definitions, constraints, defaults, indexes, and nullability determine how reliably data can be loaded, validated, queried, and maintained.

## 🎯 Learning Objectives

By the end of this topic, you should be able to:

- Create tables from scratch.
- Choose appropriate columns and data types.
- Define primary keys and constraints.
- Add, modify, rename, and drop columns safely.
- Add and remove constraints and indexes.
- Use `CREATE TABLE ... LIKE` and `CREATE TABLE ... AS SELECT`.
- Inspect table definitions before schema changes.
- Apply schema changes safely in Data Engineering workflows.

## 🧠 1. What Is a Table?

A table stores related records as rows and attributes as columns.

| employee_id | employee_name | department | salary |
|---:|---|---|---:|
| 101 | Asha | Engineering | 90000 |
| 102 | Rahul | Sales | 65000 |

Each column has a data type and may have constraints that describe the valid domain.

A good table design answers: what does each column mean, which values are valid, which column identifies a row, can a value be missing, what defaults apply, and which relationships and indexes are required?

## 🏗️ 2. CREATE TABLE

```sql
CREATE TABLE employees (
    employee_id INT,
    employee_name VARCHAR(100),
    department VARCHAR(50),
    salary DECIMAL(10, 2)
);
```

`CREATE TABLE` defines the structure; it does not insert rows.

### CREATE TABLE IF NOT EXISTS

```sql
CREATE TABLE IF NOT EXISTS employees (
    employee_id INT,
    employee_name VARCHAR(100)
);
```

This is useful for repeatable setup scripts, but it does not verify that an existing table has the schema you expected.

## 🔑 3. Primary Keys

A primary key uniquely identifies each row and cannot contain `NULL`.

```sql
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100)
);
```

Composite keys are useful when the combination of columns defines uniqueness:

```sql
CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT,
    PRIMARY KEY (order_id, product_id)
);
```

## 🚫 4. NOT NULL

`NOT NULL` prevents missing values.

```sql
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(255)
);
```

Use it when the business meaning requires a value. Do not make every column `NOT NULL` automatically.

## 🎯 5. DEFAULT Values

A default is used when an insert does not provide a value.

```sql
CREATE TABLE jobs (
    job_id INT PRIMARY KEY,
    status VARCHAR(20) DEFAULT 'PENDING',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

Defaults are useful for statuses, flags, and audit timestamps.

## 🔗 6. Foreign Keys

A foreign key represents a relationship between tables.

```sql
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);
```

It can prevent references to nonexistent parent rows, subject to the table engine and referential-action rules. Data Engineering systems may enforce such relationships in the database or validate them through pipeline quality checks.

## ✏️ 7. ALTER TABLE

`ALTER TABLE` changes an existing table definition.

```sql
ALTER TABLE employees ADD COLUMN email VARCHAR(255);
ALTER TABLE employees DROP COLUMN email;
ALTER TABLE employees RENAME COLUMN employee_name TO full_name;
```

Schema changes should be tested before production deployment.

## ➕ 8. ADD COLUMN

```sql
ALTER TABLE employees
ADD COLUMN hire_date DATE;
```

With a default:

```sql
ALTER TABLE employees
ADD COLUMN status VARCHAR(20) DEFAULT 'ACTIVE';
```

When adding a required column to an existing populated table, plan how existing rows receive valid values.

## 🔄 9. MODIFY COLUMN

```sql
ALTER TABLE employees
MODIFY COLUMN salary DECIMAL(12, 2);
```

Changing a type can cause conversion, truncation, or rejected values. Profile existing data first.

## 🏷️ 10. CHANGE COLUMN vs RENAME COLUMN

`CHANGE COLUMN` can rename a column and requires the new definition:

```sql
ALTER TABLE employees
CHANGE COLUMN employee_name full_name VARCHAR(150) NOT NULL;
```

`RENAME COLUMN` is intended for a name-only change:

```sql
ALTER TABLE employees
RENAME COLUMN full_name TO employee_name;
```

Use the operation that best communicates the intended migration.

## 🗑️ 11. DROP COLUMN

```sql
ALTER TABLE employees
DROP COLUMN temporary_flag;
```

Dropping a column is destructive. Check views, ETL jobs, procedures, reports, applications, indexes, and downstream pipelines first.

## 📋 12. Inspecting a Table

Use metadata commands before changing a schema.

```sql
DESCRIBE employees;
SHOW CREATE TABLE employees;
```

`SHOW CREATE TABLE` exposes the actual DDL, including columns, constraints, indexes, defaults, and table options.

You can also query metadata:

```sql
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = DATABASE()
  AND table_name = 'employees';
```

## 📑 13. CREATE TABLE LIKE

Creates a structurally similar table:

```sql
CREATE TABLE employees_backup LIKE employees;
```

It is useful when you need a similar table without copying the data. Verify the resulting structure for operational use.

## 🔬 14. CREATE TABLE AS SELECT

Creates a table from a query result:

```sql
CREATE TABLE high_value_customers AS
SELECT customer_id, customer_name
FROM customers
WHERE lifetime_value > 100000;
```

CTAS is useful for derived datasets and staging work. Do not assume that it reproduces all source constraints and indexes.

## 🧱 15. Temporary Tables

```sql
CREATE TEMPORARY TABLE active_customers AS
SELECT *
FROM customers
WHERE status = 'ACTIVE';
```

Temporary tables are session-scoped and useful for intermediate transformations. They are not persistent pipeline storage.

## 📌 16. Indexes in Table Design

Indexes can be defined during creation:

```sql
CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY,
    customer_id BIGINT,
    order_date DATE,
    INDEX idx_orders_customer (customer_id)
);
```

Or added later:

```sql
ALTER TABLE orders
ADD INDEX idx_orders_customer (customer_id);
```

Indexes can improve reads but consume storage and add write/maintenance overhead. Index based on actual query patterns.

## 🔐 17. Constraints During CREATE vs ALTER

Constraints can be created with the table or added later.

```sql
ALTER TABLE orders
ADD CONSTRAINT fk_orders_customer
FOREIGN KEY (customer_id)
REFERENCES customers(customer_id);
```

Named constraints make migrations and troubleshooting easier.

## 🧪 18. Safe Schema-Change Workflow

```text
Requirement
    ↓
Inspect current schema
    ↓
Profile existing data
    ↓
Check dependencies
    ↓
Test migration
    ↓
Apply change
    ↓
Validate schema + data
    ↓
Monitor downstream jobs
```

For example, before changing `INT` to `BIGINT`, check current values, dependent objects, indexes, constraints, applications, and future growth.

## 🌎 19. Real-World Orders Table

```sql
CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    order_amount DECIMAL(12, 2) NOT NULL,
    order_date DATE NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_orders_customer (customer_id),
    INDEX idx_orders_date (order_date)
);
```

The design communicates identifier size, monetary precision, required business fields, defaults, audit time, and expected lookup patterns.

## 🏗️ 20. Data Engineering Use Cases

Table creation and modification are used for:

- Staging and ingestion targets.
- Warehouse facts and dimensions.
- Audit columns such as `created_at` and `updated_at`.
- Source schema evolution.
- Temporary transformation tables.
- Derived datasets with CTAS.
- Operational indexes.
- Environment-to-environment migrations.

Example:

```sql
ALTER TABLE staging_orders
ADD COLUMN ingestion_ts DATETIME DEFAULT CURRENT_TIMESTAMP;
```

This separates pipeline ingestion time from business event time.

## ⚠️ 21. Common Mistakes

- Changing a type without profiling existing data.
- Dropping columns without checking dependencies.
- Making every column `NOT NULL`.
- Assuming CTAS copies all constraints and indexes.
- Adding indexes without considering write cost.
- Using vague column names.
- Making breaking schema changes without coordinating consumers.

## ⚡ 22. Performance Considerations

Schema design affects performance before query tuning begins.

- Appropriate types reduce storage and conversion overhead.
- Primary keys and indexes support lookups and joins.
- Excessive indexes increase write cost.
- Wide rows can increase I/O.
- Large text/blob values should be used deliberately.
- Join columns should have compatible data types.
- Schema changes on large production tables require operational planning.

## 🎤 23. Interview-Focused Questions

### Q1. What is the difference between CREATE TABLE and ALTER TABLE?

<details>
<summary><strong>Answer</strong></summary>

`CREATE TABLE` creates a new table and its initial schema. `ALTER TABLE` changes an existing table, such as adding a column, modifying a type, or adding an index.

</details>

### Q2. What happens when you add a NOT NULL column to a populated table?

<details>
<summary><strong>Answer</strong></summary>

Existing rows need valid values. Without a compatible default or migration strategy, the operation may fail. A production change should be planned and tested.

</details>

### Q3. CREATE TABLE LIKE vs CREATE TABLE AS SELECT?

<details>
<summary><strong>Answer</strong></summary>

`LIKE` creates a structurally similar table. CTAS creates a table from query results. CTAS should not be assumed to reproduce all source constraints and indexes.

</details>

### Q4. Why use SHOW CREATE TABLE before a migration?

<details>
<summary><strong>Answer</strong></summary>

It exposes the actual current DDL, including columns, indexes, constraints, defaults, and options, reducing the risk of changing the schema based on assumptions.

</details>

### Q5. DROP COLUMN vs DELETE?

<details>
<summary><strong>Answer</strong></summary>

`DROP COLUMN` changes the schema by removing an attribute. `DELETE` removes rows while keeping the table structure.

</details>

### Q6. Why can changing a data type be dangerous?

<details>
<summary><strong>Answer</strong></summary>

Existing values may not fit the new type, causing conversion, truncation, or failure. The change can also affect indexes, applications, joins, and downstream consumers.

</details>

### Q7. When would you use a temporary table in Data Engineering?

<details>
<summary><strong>Answer</strong></summary>

For session-scoped intermediate transformations or complex calculations. It is not a substitute for persistent staging or warehouse storage.

</details>

### Q8. Why consider indexes during table design?

<details>
<summary><strong>Answer</strong></summary>

Indexes can improve filtering, joins, and lookups, but consume storage and add write overhead. They should reflect actual access patterns.

</details>

### Q9. How would you safely rename a column used by ETL jobs?

<details>
<summary><strong>Answer</strong></summary>

Identify consumers, update or version them, test the migration, deploy in a controlled sequence, and validate downstream jobs. A direct rename can cause widespread failures.

</details>

### Q10. How would you add a required column to a large production table?

<details>
<summary><strong>Answer</strong></summary>

A common safe pattern is to add it compatibly, populate existing rows, validate, update consumers, and then enforce the final constraint. The exact approach depends on table size, workload, MySQL version, and availability requirements.

</details>

### Q11. Why name constraints explicitly?

<details>
<summary><strong>Answer</strong></summary>

Explicit names make schema definitions easier to understand and make migrations, troubleshooting, and later constraint operations more predictable.

</details>

### Q12. What should you check before dropping a column?

<details>
<summary><strong>Answer</strong></summary>

Check applications, ETL jobs, views, procedures, reports, indexes, constraints, dashboards, downstream systems, and historical/audit requirements.

</details>

### Q13. What is schema evolution?

<details>
<summary><strong>Answer</strong></summary>

Schema evolution is the controlled process of changing data structures as source or business requirements change while maintaining data quality and consumer compatibility.

</details>

### Q14. Why is schema design important in Data Engineering?

<details>
<summary><strong>Answer</strong></summary>

The target schema controls how data is stored and validated. Poor choices can cause type mismatches, failed loads, inaccurate calculations, inefficient queries, and downstream compatibility problems.

</details>

## 🔄 24. Quick Revision

| Operation | Purpose |
|---|---|
| `CREATE TABLE` | Create a table |
| `IF NOT EXISTS` | Avoid error if table exists |
| `DESCRIBE` | Inspect columns |
| `SHOW CREATE TABLE` | Inspect complete table DDL |
| `ADD COLUMN` | Add a column |
| `MODIFY COLUMN` | Change a column definition |
| `CHANGE COLUMN` | Rename and redefine a column |
| `RENAME COLUMN` | Rename a column |
| `DROP COLUMN` | Remove a column |
| `RENAME TABLE` | Rename a table |
| `CREATE TABLE AS SELECT` | Create a table from query results |

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — worked examples for creating, inspecting, and altering tables
- [`practice.sql`](./practice.sql) — table-definition and schema-migration exercises
