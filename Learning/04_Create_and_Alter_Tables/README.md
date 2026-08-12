# 04 — Create and Alter Tables

## 📌 Overview

A table is the primary relational structure used to store rows and columns. This topic covers how to create tables, modify their structure safely, inspect definitions, and remove tables when required.

The focus is on practical MySQL usage and the table-definition decisions a Data Engineer should understand.

## 🎯 Learning Objectives

By the end of this topic, you should be able to:

- Create tables with appropriate columns and data types
- Understand the structure of `CREATE TABLE`
- Use `IF NOT EXISTS`
- Create tables with `PRIMARY KEY` and `NOT NULL`
- Add, modify, rename, and drop columns
- Add and remove table constraints
- Rename tables
- Inspect table definitions
- Understand `ALTER TABLE` and its risks
- Distinguish structural changes from data changes
- Apply safe table-evolution practices

---

## 1. What Is a Table?

A table stores data in rows and columns.

```text
employees
├── employee_id
├── employee_name
├── department
└── salary
```

Each column has a defined data type and each row represents a record.

---

## 2. CREATE TABLE

Basic syntax:

```sql
CREATE TABLE table_name (
    column_name data_type,
    column_name data_type
);
```

Example:

```sql
CREATE TABLE employees (
    employee_id INT,
    employee_name VARCHAR(100),
    salary DECIMAL(10, 2)
);
```

The table is created inside the currently selected database.

---

## 3. CREATE TABLE IF NOT EXISTS

Use this when the script should not fail simply because the table already exists.

```sql
CREATE TABLE IF NOT EXISTS employees (
    employee_id INT,
    employee_name VARCHAR(100)
);
```

This is useful in repeatable setup scripts, but it does not modify an existing table.

---

## 4. Creating a Table with Constraints

A table definition can include constraints.

```sql
CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    salary DECIMAL(10, 2)
);
```

Detailed constraint behavior is covered in the next topic, but understanding how constraints appear in a table definition is essential here.

---

## 5. Column Definitions

A column definition normally contains:

```text
column_name + data_type + optional attributes/constraints
```

Example:

```sql
employee_id INT NOT NULL
```

Common attributes include:

- `NOT NULL`
- `DEFAULT`
- `PRIMARY KEY`
- `UNIQUE`
- `AUTO_INCREMENT`
- `CHECK`
- `REFERENCES` / foreign-key definitions

---

## 6. AUTO_INCREMENT

`AUTO_INCREMENT` can generate sequential integer values for a suitable key column.

```sql
CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL
);
```

When a row is inserted without specifying `employee_id`, MySQL can generate the value.

---

## 7. DEFAULT Values

A column can have a default value.

```sql
CREATE TABLE users (
    user_id INT PRIMARY KEY,
    is_active BOOLEAN DEFAULT TRUE
);
```

Defaults are applied when an insert does not provide a value for that column, subject to MySQL's rules and the column definition.

---

## 8. Inspect a Table

Use `DESCRIBE` or `SHOW COLUMNS` to inspect columns.

```sql
DESCRIBE employees;
```

or:

```sql
SHOW COLUMNS FROM employees;
```

To inspect the complete table definition:

```sql
SHOW CREATE TABLE employees;
```

`SHOW CREATE TABLE` is especially useful when you need to understand the exact DDL currently stored by MySQL.

---

## 9. ALTER TABLE

`ALTER TABLE` changes the structure of an existing table.

General form:

```sql
ALTER TABLE table_name ...;
```

It can be used for operations such as:

- Adding columns
- Modifying column definitions
- Renaming columns
- Dropping columns
- Adding constraints
- Removing constraints
- Renaming tables

---

## 10. ADD COLUMN

```sql
ALTER TABLE employees
ADD COLUMN hire_date DATE;
```

You can control placement with `FIRST` or `AFTER` when appropriate:

```sql
ALTER TABLE employees
ADD COLUMN department VARCHAR(50) AFTER employee_name;
```

Column order generally should not be treated as a logical data-modeling requirement.

---

## 11. ADD Multiple Columns

```sql
ALTER TABLE employees
ADD COLUMN phone VARCHAR(20),
ADD COLUMN city VARCHAR(50);
```

Adding related structural changes together can make a migration easier to reason about.

---

## 12. MODIFY COLUMN

`MODIFY COLUMN` changes a column definition without changing its name.

```sql
ALTER TABLE employees
MODIFY COLUMN salary DECIMAL(12, 2);
```

Be careful when narrowing a type or adding `NOT NULL`, because existing data may not satisfy the new definition.

---

## 13. CHANGE COLUMN

`CHANGE COLUMN` can rename a column and define its new specification.

```sql
ALTER TABLE employees
CHANGE COLUMN employee_name full_name VARCHAR(150) NOT NULL;
```

Unlike `MODIFY COLUMN`, `CHANGE COLUMN` requires both the old and new column names.

---

## 14. RENAME COLUMN

MySQL also supports direct column renaming:

```sql
ALTER TABLE employees
RENAME COLUMN full_name TO employee_name;
```

Use this when only the column name needs to change and the definition should otherwise remain intact.

---

## 15. DROP COLUMN

```sql
ALTER TABLE employees
DROP COLUMN phone;
```

> [!WARNING]
> Dropping a column is destructive. The column and its stored values are removed. Confirm dependencies and backups before production changes.

---

## 16. Rename a Table

```sql
RENAME TABLE employees TO staff;
```

You can also use:

```sql
ALTER TABLE staff RENAME TO employees;
```

Table renames should be coordinated with applications, views, procedures, ETL jobs, and downstream dependencies.

---

## 17. Add and Remove Constraints

Structural changes can also modify constraints.

Example:

```sql
ALTER TABLE employees
ADD CONSTRAINT uq_employee_email UNIQUE (email);
```

A constraint can later be removed by its name:

```sql
ALTER TABLE employees
DROP INDEX uq_employee_email;
```

Foreign-key constraint syntax is covered in the Constraints and Keys topic.

---

## 18. Temporary vs Permanent Structure Changes

`CREATE TABLE` creates a persistent table unless a temporary table is explicitly requested.

```sql
CREATE TEMPORARY TABLE staging_employees (
    employee_id INT,
    employee_name VARCHAR(100)
);
```

Temporary tables are session-scoped and are covered in greater detail later.

---

## 19. Create a Table from a Query

MySQL can create a table from a query result using `CREATE TABLE ... AS SELECT`.

```sql
CREATE TABLE employee_backup AS
SELECT
    employee_id,
    employee_name,
    salary
FROM employees;
```

> [!IMPORTANT]
> `CREATE TABLE ... AS SELECT` is useful for derived copies, but it should not be assumed to reproduce every original constraint, index, or table property.

---

## 20. ALTER TABLE and Existing Data

Structural changes can affect existing rows.

For example, adding a nullable column is generally different from adding a `NOT NULL` column without a valid default.

Before changing a production table, consider:

1. Existing row count
2. Existing values
3. Nullability
4. Default values
5. Indexes and constraints
6. Application dependencies
7. Locking and execution impact
8. Rollback or recovery strategy

---

## 21. Safe Schema Evolution

A practical migration workflow is:

```text
Understand change
      ↓
Check dependencies
      ↓
Check existing data
      ↓
Test on representative data
      ↓
Apply migration
      ↓
Verify structure
      ↓
Verify application / ETL behavior
```

For Data Engineering systems, schema changes should be treated as part of the data pipeline lifecycle rather than casual ad-hoc edits.

---

## 22. Common Mistakes

- Creating columns without choosing an appropriate data type
- Assuming `CREATE TABLE IF NOT EXISTS` updates an existing table
- Using `MODIFY COLUMN` when a rename is required
- Forgetting the new definition when using `CHANGE COLUMN`
- Dropping columns without checking dependencies
- Adding `NOT NULL` without checking existing rows
- Assuming `CREATE TABLE ... AS SELECT` copies all indexes and constraints
- Making production DDL changes without testing
- Ignoring downstream ETL and application dependencies
- Treating column order as business logic

---

## 23. Interview-Focused Questions

Try to answer each question yourself before opening the answer.

### Q1. What is the difference between CREATE TABLE and ALTER TABLE?

<details>
<summary><strong>Answer</strong></summary>

`CREATE TABLE` creates a new table. `ALTER TABLE` changes the structure of an existing table, such as adding or modifying columns and constraints.

</details>

---

### Q2. What is the difference between MODIFY COLUMN and CHANGE COLUMN in MySQL?

<details>
<summary><strong>Answer</strong></summary>

`MODIFY COLUMN` changes the definition of an existing column while keeping its name. `CHANGE COLUMN` can rename the column and requires the old and new names plus the full new definition.

</details>

---

### Q3. What is the difference between RENAME COLUMN and CHANGE COLUMN?

<details>
<summary><strong>Answer</strong></summary>

`RENAME COLUMN` is intended specifically for renaming a column. `CHANGE COLUMN` can rename the column but also requires the new column definition.

</details>

---

### Q4. What does CREATE TABLE IF NOT EXISTS do?

<details>
<summary><strong>Answer</strong></summary>

It prevents the normal error when the specified table already exists. It does not modify or synchronize the existing table definition.

</details>

---

### Q5. What happens when you drop a column?

<details>
<summary><strong>Answer</strong></summary>

The column and its stored values are removed from the table. The operation can be destructive and may also affect indexes, constraints, queries, or applications that depend on the column.

</details>

---

### Q6. Why should you be careful when adding a NOT NULL column to an existing table?

<details>
<summary><strong>Answer</strong></summary>

Existing rows need a valid value for the new column. Depending on the definition and MySQL behavior, adding a non-nullable column without an appropriate default can fail or require a migration strategy that backfills existing records.

</details>

---

### Q7. Does CREATE TABLE AS SELECT copy all indexes and constraints from the source table?

<details>
<summary><strong>Answer</strong></summary>

No. `CREATE TABLE ... AS SELECT` creates a table from the query result, but you should not assume that the source table's primary keys, indexes, foreign keys, and other properties are reproduced. Define required structural objects explicitly.

</details>

---

### Q8. How would you safely rename a column used by an ETL pipeline?

<details>
<summary><strong>Answer</strong></summary>

First identify downstream dependencies such as ETL queries, views, procedures, dashboards, and applications. Test the migration, coordinate the code change, rename the column, and verify all dependent workflows. In production, a compatibility or phased migration may be safer than an immediate breaking rename.

</details>

---

### Q9. What should you check before running ALTER TABLE in production?

<details>
<summary><strong>Answer</strong></summary>

Check the table size, existing data, dependencies, indexes, constraints, expected execution impact, locking behavior, backup/recovery options, maintenance window, and whether the migration has been tested on representative data.

</details>

---

### Q10. An interviewer asks: How would you add a salary column with a default of 0.00?

<details>
<summary><strong>Answer</strong></summary>

```sql
ALTER TABLE employees
ADD COLUMN salary DECIMAL(12, 2) NOT NULL DEFAULT 0.00;
```

The exact definition should be based on the business requirement and existing data.

</details>

---

## 24. Quick Revision

| Operation | Syntax / Purpose |
|---|---|
| `CREATE TABLE` | Create a new table |
| `IF NOT EXISTS` | Avoid error if table already exists |
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
- [`practice.sql`](./practice.sql) — hands-on table-definition and schema-migration exercises
