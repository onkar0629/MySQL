# Databases and Schemas

> [!NOTE]
> This topic explains how MySQL organizes databases (schemas), how to work safely with them, how to inspect metadata, and how database-level organization is used in Data Engineering.

## 📌 Overview

A **database** is a logical container for database objects such as tables, views, indexes, and stored programs. In MySQL, **database** and **schema** are synonyms.

## 🎯 Learning Objectives

- Explain database, schema, DBMS, and RDBMS.
- Create, select, inspect, and drop databases safely.
- Understand session/database scope.
- Use fully qualified object names.
- Perform cross-database queries.
- Inspect metadata with `SHOW` and `INFORMATION_SCHEMA`.
- Understand character sets and collations.
- Apply database organization patterns in Data Engineering.

---

# 📚 Concepts

## 1. Database, DBMS, and RDBMS

A **database** is an organized collection of data. A **DBMS** manages databases. An **RDBMS** is a DBMS based on the relational model, where data is organized into related tables. MySQL is an RDBMS.

```text
Database → RDBMS → SQL
```

## 2. Database vs Schema in MySQL

MySQL treats schema as a synonym for database:

```sql
CREATE DATABASE sales_db;
CREATE SCHEMA analytics_db;
```

> [!IMPORTANT]
> Other RDBMSs may use schemas as namespaces inside a database. Answer according to the database system being discussed.

## 3. Why Databases Are Needed

Databases provide logical organization and separation:

```text
sales_db
├── customers
├── orders
└── products

hr_db
├── employees
├── departments
└── payroll
```

This supports organization, administration, security, and maintainability.

## 4. Create a Database

```sql
CREATE DATABASE sales_db;
CREATE DATABASE IF NOT EXISTS sales_db;
```

`IF NOT EXISTS` makes repeatable setup scripts safer.

## 5. Create a Schema

```sql
CREATE SCHEMA analytics_db;
CREATE SCHEMA IF NOT EXISTS analytics_db;
```

In MySQL these create databases.

## 6. List Databases

```sql
SHOW DATABASES;
```

Visible results depend on account privileges.

## 7. Select a Database

```sql
USE sales_db;
```

This sets the default database for the current session. Therefore `SELECT * FROM orders;` resolves against `sales_db` when selected.

## 8. Check the Current Database

```sql
SELECT DATABASE();
```

Returns the selected database or `NULL` when none is selected.

## 9. Create Objects

```sql
USE sales_db;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100)
);
```

You can also qualify the database directly:

```sql
CREATE TABLE sales_db.products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100)
);
```

## 10. Fully Qualified Names

```text
database_name.object_name
```

Example:

```sql
SELECT * FROM sales_db.customers;
```

Qualified names remove ambiguity when multiple databases are involved.

## 11. Inspect Objects

```sql
SHOW TABLES;
SHOW TABLES FROM sales_db;
DESCRIBE sales_db.customers;
DESC sales_db.customers;
```

## 12. Inspect Database Definition

```sql
SHOW CREATE DATABASE sales_db;
```

Useful for inspecting database-level definition and defaults.

## 13. Drop a Database

```sql
DROP DATABASE sales_db;
DROP DATABASE IF EXISTS sales_db;
```

> [!WARNING]
> `DROP DATABASE` removes the database and its contained objects. Treat it as a destructive production operation.

## 14. Naming Conventions

Prefer meaningful names such as `sales_db`, `customer_analytics`, and `finance_reporting`. Avoid ambiguous names such as `newdb`, `abc`, and `final2`.

## 15. Multiple Databases on One Server

```text
MySQL Server
├── sales_db
├── hr_db
├── inventory_db
└── analytics_db
```

A session can change its default database with `USE`, while queries can explicitly reference other databases.

## 16. Cross-Database Queries

```sql
SELECT *
FROM sales_db.orders;
```

Cross-database joins are also possible:

```sql
SELECT o.order_id, c.customer_name
FROM sales_db.orders AS o
JOIN crm_db.customers AS c
    ON o.customer_id = c.customer_id;
```

The account needs the required privileges.

## 17. Database-Level Privileges

Database boundaries can participate in access control:

```sql
GRANT SELECT
ON sales_db.*
TO 'report_user'@'localhost';
```

Detailed user/role management belongs to a later security topic.

## 18. Character Sets

A character set defines how characters are represented and stored.

```sql
CREATE DATABASE customer_db
    CHARACTER SET utf8mb4;
```

`utf8mb4` is commonly used when full Unicode support is required.

## 19. Collation

A collation defines how text is compared and sorted.

```sql
CREATE DATABASE customer_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;
```

```text
Character Set → How text is represented
Collation     → How text is compared/sorted
```

Available collations depend on the MySQL version.

## 20. Database Defaults

Database-level character-set and collation settings can act as defaults for objects created inside the database unless overridden at a lower level.

## 21. `INFORMATION_SCHEMA`

`INFORMATION_SCHEMA` exposes metadata about databases and objects.

Useful views include `SCHEMATA`, `TABLES`, `COLUMNS`, `STATISTICS`, and `KEY_COLUMN_USAGE`.

```sql
SELECT
    SCHEMA_NAME,
    DEFAULT_CHARACTER_SET_NAME,
    DEFAULT_COLLATION_NAME
FROM information_schema.SCHEMATA;
```

## 22. Inspect One Database

```sql
SELECT
    SCHEMA_NAME,
    DEFAULT_CHARACTER_SET_NAME,
    DEFAULT_COLLATION_NAME
FROM information_schema.SCHEMATA
WHERE SCHEMA_NAME = 'sales_db';
```

## 23. Metadata for Data Engineering

Metadata queries help Data Engineers discover tables and columns, generate validation SQL, build documentation, verify expected objects, and detect structural changes.

```sql
SELECT TABLE_SCHEMA, TABLE_NAME, TABLE_TYPE
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'sales_db';
```

---

# 🔬 Deep Dive

## Current Database vs Qualified Name

These can target the same object:

```sql
USE sales_db;
SELECT * FROM orders;
```

and:

```sql
SELECT * FROM sales_db.orders;
```

The second is explicit and is useful in ETL scripts, migrations, and multi-database applications.

## Session Scope

`USE` applies to the current client session. Two independent connections can have different default databases.

## Logical vs Physical Separation

A database is a logical organization boundary, not automatically a separate server or machine. Physical storage depends on configuration, storage engine, filesystem layout, and deployment architecture.

---

# 🌎 Real-World Examples

### Application domains

```text
crm_db
sales_db
support_db
```

### Reporting access

```sql
GRANT SELECT
ON reporting_db.*
TO 'report_user'@'localhost';
```

### Metadata automation

```sql
SELECT TABLE_NAME
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'sales_db';
```

A pipeline can discover tables dynamically instead of maintaining fragile hard-coded lists.

---

# 🏗️ Data Engineering Use Cases

### Environment separation

```text
sales_dev
sales_test
sales_prod
```

### Data-layer separation

Depending on architecture:

```text
raw
staging
curated
reporting
```

### Schema discovery

Metadata queries can discover source structures for ingestion and validation.

### Data-quality checks

Pipelines can verify that expected tables and columns exist before processing.

### Cross-database integration

Operational and reporting workloads may reside in different logical databases and be joined when architecture and privileges permit it.

---

# ⚡ Performance and Operational Considerations

Database selection itself is not a query optimization technique. Query performance depends on indexes, table size, predicates, join strategy, statistics, storage engine, execution plan, and network transfer.

Explicit qualification mainly improves clarity. Metadata queries should retrieve only the metadata required by an automation task.

---

# ⚠️ Common Mistakes

1. **No database selected:** unqualified references may fail.
2. **Wrong database:** verify with `SELECT DATABASE();`.
3. **Unsafe drop:** verify the target before `DROP DATABASE`.
4. **Schema misconception:** MySQL uses database and schema as synonyms.
5. **Ignoring privileges:** existence does not imply access.
6. **Ignoring character set/collation:** text behavior can depend on them.
7. **Hard-coded metadata:** use `INFORMATION_SCHEMA` for metadata-driven workflows.

---

# 🎤 Interview-Focused Questions

### Q1. What is a database?

<details>
<summary><strong>Answer</strong></summary>

A database is an organized collection of data managed by a DBMS. In MySQL it is also commonly called a schema and acts as a logical container for database objects.
</details>

### Q2. Database vs schema in MySQL?

<details>
<summary><strong>Answer</strong></summary>

They are synonyms in MySQL. `CREATE DATABASE` and `CREATE SCHEMA` create the same kind of logical container.
</details>

### Q3. What does `USE database_name` do?

<details>
<summary><strong>Answer</strong></summary>

It selects the default database for the current session, allowing unqualified object names to be resolved against it.
</details>

### Q4. How do you check the current database?

<details>
<summary><strong>Answer</strong></summary>

```sql
SELECT DATABASE();
```

It returns the selected database or `NULL`.
</details>

### Q5. How do you query another database without changing the current database?

<details>
<summary><strong>Answer</strong></summary>

Use a qualified name such as `SELECT * FROM sales_db.orders;`.
</details>

### Q6. `DROP DATABASE` vs `DROP TABLE`?

<details>
<summary><strong>Answer</strong></summary>

`DROP DATABASE` removes the database and its objects. `DROP TABLE` removes only the specified table. Both are destructive.
</details>

### Q7. How do you list databases?

<details>
<summary><strong>Answer</strong></summary>

```sql
SHOW DATABASES;
```

The visible results depend on account privileges.
</details>

### Q8. Why use `IF NOT EXISTS`?

<details>
<summary><strong>Answer</strong></summary>

It prevents the normal error when the target database already exists and makes setup scripts safer to rerun.
</details>

### Q9. What is a fully qualified table name?

<details>
<summary><strong>Answer</strong></summary>

A name containing the database and object, such as `sales_db.orders`, which explicitly identifies the target database.
</details>

### Q10. What is `INFORMATION_SCHEMA`?

<details>
<summary><strong>Answer</strong></summary>

It provides metadata about databases and objects such as tables, columns, indexes, and constraints. It is useful for administration and Data Engineering automation.
</details>

### Q11. Can two databases contain tables with the same name?

<details>
<summary><strong>Answer</strong></summary>

Yes. `sales_db.customers` and `crm_db.customers` can both exist because the database name distinguishes them.
</details>

### Q12. What happens if no database is selected?

<details>
<summary><strong>Answer</strong></summary>

Unqualified object references may fail because MySQL has no default database in which to resolve the object. Use `USE` or a qualified name.
</details>

### Q13. What are character set and collation?

<details>
<summary><strong>Answer</strong></summary>

A character set defines how characters are represented and stored. A collation defines rules for comparing and sorting text.
</details>

### Q14. Why is `INFORMATION_SCHEMA` useful for Data Engineers?

<details>
<summary><strong>Answer</strong></summary>

It enables metadata-driven workflows such as schema discovery, automated validation, documentation, SQL generation, and structural-change detection.
</details>

### Q15. How would you join `sales_db.orders` with `crm_db.customers`?

<details>
<summary><strong>Answer</strong></summary>

```sql
SELECT o.order_id, c.customer_name
FROM sales_db.orders AS o
JOIN crm_db.customers AS c
    ON o.customer_id = c.customer_id;
```
</details>

### Q16. Why check `SELECT DATABASE()` before a destructive operation?

<details>
<summary><strong>Answer</strong></summary>

It verifies the session's current database and reduces the chance of operating on an unintended database through an unqualified reference.
</details>

### Q17. Is a MySQL database the same as a physical server?

<details>
<summary><strong>Answer</strong></summary>

No. A MySQL server can contain multiple logical databases. Physical storage depends on the deployment and storage configuration.
</details>

---

# 🔄 Quick Revision

```text
Database / Schema → Synonyms in MySQL
CREATE DATABASE   → Create database
CREATE SCHEMA     → Create schema/database
SHOW DATABASES    → List visible databases
USE db_name       → Select default database
DATABASE()        → Check current database
SHOW TABLES       → List tables
DESC table        → Inspect structure
DROP DATABASE     → Remove database and objects

database.table    → Fully qualified object name
INFORMATION_SCHEMA → Metadata
CHARACTER SET      → Character representation
COLLATION          → Comparison/sorting rules
```

## Essential Commands

```sql
CREATE DATABASE IF NOT EXISTS sales_db;
SHOW DATABASES;
USE sales_db;
SELECT DATABASE();
SHOW TABLES;
SELECT * FROM sales_db.orders;
DROP DATABASE IF EXISTS sales_db;
```

---

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — worked examples for databases, schemas, metadata, and cross-database references
- [`practice.sql`](./practice.sql) — hands-on exercises and interview practice
