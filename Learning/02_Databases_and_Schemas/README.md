# Databases and Schemas

A **database** is an organized collection of data managed by a database management system. In MySQL, databases and schemas are closely related concepts and are commonly used to organize tables, views, procedures, and other database objects.

> [!NOTE]
> **Goal:** By the end of this topic, you should be able to create, select, inspect, rename/modify where appropriate, and remove databases safely. You should also understand how databases/schemas fit into MySQL object organization and how to qualify objects with a database name.

## 1. Database vs Schema in MySQL

In MySQL, **schema** is essentially a synonym for **database**. Both can be used to refer to a logical container for database objects.

```sql
CREATE DATABASE sales_db;
CREATE SCHEMA analytics_db;
```

Both statements create a database/schema.

> [!IMPORTANT]
> Do not confuse the MySQL meaning of **schema** with systems where a schema is a namespace inside a database. MySQL commonly uses `database` and `schema` interchangeably.

---

## 2. Why Do We Need Databases?

Databases provide logical separation for different applications, environments, or business domains.

Examples:

```text
company_db
├── employees
├── departments
└── payroll

sales_db
├── customers
├── orders
└── products
```

This separation improves organization, administration, security, and maintainability.

---

## 3. Create a Database

```sql
CREATE DATABASE company_db;
```

This creates a database named `company_db`.

### Safer version

```sql
CREATE DATABASE IF NOT EXISTS company_db;
```

`IF NOT EXISTS` prevents an error when the database already exists.

---

## 4. Create a Schema

Because MySQL treats schema as a synonym for database, this is also valid:

```sql
CREATE SCHEMA analytics_db;
```

You can also use:

```sql
CREATE SCHEMA IF NOT EXISTS analytics_db;
```

---

## 5. List Databases

```sql
SHOW DATABASES;
```

This displays databases visible to the current MySQL account.

---

## 6. Select a Database

Before creating or querying objects without fully qualifying their names, select the database with `USE`.

```sql
USE company_db;
```

After this, statements such as the following use `company_db` as the default database:

```sql
SELECT *
FROM employees;
```

---

## 7. Find the Current Database

```sql
SELECT DATABASE();
```

If no database is currently selected, MySQL returns `NULL`.

---

## 8. Create Tables Inside a Database

After selecting a database:

```sql
USE company_db;

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100),
    department VARCHAR(50)
);
```

The table is created inside the selected database.

---

## 9. Fully Qualified Object Names

You can explicitly specify the database name:

```sql
SELECT *
FROM company_db.employees;
```

The general pattern is:

```text
database_name.object_name
```

This is useful when working with multiple databases in the same MySQL server.

---

## 10. Create a Table Without `USE`

You can create an object by qualifying the database name:

```sql
CREATE TABLE company_db.departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100)
);
```

This avoids depending on the current default database.

---

## 11. Inspect Database Metadata

MySQL provides commands for inspecting database objects.

### Show tables in the current database

```sql
SHOW TABLES;
```

### Show tables in a specific database

```sql
SHOW TABLES FROM company_db;
```

### Describe a table

```sql
DESCRIBE company_db.employees;
```

or:

```sql
DESC company_db.employees;
```

---

## 12. Show Database Creation Statement

```sql
SHOW CREATE DATABASE company_db;
```

This can help inspect the database definition and default characteristics.

---

## 13. Drop a Database

```sql
DROP DATABASE company_db;
```

This removes the database and its objects.

### Safer syntax

```sql
DROP DATABASE IF EXISTS company_db;
```

> [!WARNING]
> `DROP DATABASE` is destructive. It removes the database and objects contained within it. Never run it casually in a production environment.

---

## 14. Database Naming Conventions

Use names that are:

- Clear
- Consistent
- Meaningful
- Easy to type
- Appropriate for your team's conventions

Examples:

```text
sales_db
customer_analytics
inventory_db
warehouse_reporting
```

Avoid unnecessarily ambiguous names such as:

```text
newdb
abc
final2
sample123
```

---

## 15. Database Scope vs Table Scope

A database contains database objects. A table contains rows and columns.

```text
MySQL Server
│
├── company_db
│   ├── employees
│   ├── departments
│   └── payroll
│
└── sales_db
    ├── customers
    ├── orders
    └── products
```

This hierarchy is important when working with multiple applications or data domains.

---

## 16. Multiple Databases on One MySQL Server

A MySQL server can contain multiple databases.

```sql
SHOW DATABASES;
```

You can switch between them:

```sql
USE sales_db;
```

and later:

```sql
USE analytics_db;
```

The current database affects unqualified object names.

---

## 17. Cross-Database Queries

If the account has the required privileges, you can query objects in another database by qualifying the name.

```sql
SELECT
    e.employee_name,
    d.department_name
FROM company_db.employees AS e
JOIN company_db.departments AS d
    ON e.department_id = d.department_id;
```

The same database qualification can be used when objects come from different databases.

---

## 18. Database-Level Permissions

Database organization also matters for security.

A user can be granted privileges on a specific database:

```sql
GRANT SELECT
ON sales_db.*
TO 'report_user'@'localhost';
```

Detailed users, roles, and access control are covered in a later topic.

---

## 19. Database Character Set and Collation

A database can have default character-set and collation settings.

For example:

```sql
CREATE DATABASE customer_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;
```

The database defaults can influence objects created within it unless overridden at a lower level.

> [!TIP]
> `utf8mb4` is the modern MySQL character set commonly used when full Unicode support is required.

---

## 20. Inspect Database Defaults

You can inspect database metadata using `INFORMATION_SCHEMA`.

```sql
SELECT
    SCHEMA_NAME,
    DEFAULT_CHARACTER_SET_NAME,
    DEFAULT_COLLATION_NAME
FROM information_schema.SCHEMATA;
```

You can filter for one database:

```sql
SELECT
    SCHEMA_NAME,
    DEFAULT_CHARACTER_SET_NAME,
    DEFAULT_COLLATION_NAME
FROM information_schema.SCHEMATA
WHERE SCHEMA_NAME = 'customer_db';
```

---

## 21. `INFORMATION_SCHEMA`

`INFORMATION_SCHEMA` contains metadata about databases and database objects.

Examples of useful metadata tables include:

```text
SCHEMATA
TABLES
COLUMNS
STATISTICS
KEY_COLUMN_USAGE
```

These become especially useful for database administration, automation, and Data Engineering tasks.

---

## 22. Database vs Schema in Data Engineering

In Data Engineering environments, logical separation is often important for:

- Development
- Testing
- Production
- Staging
- Reporting
- Analytics
- Raw data
- Curated data

A simple conceptual layout could be:

```text
company_data
├── raw
├── staging
├── curated
└── reporting
```

The exact implementation depends on the database platform and architecture. MySQL commonly uses databases/schemas as logical containers.

---

## 23. Safe Database Workflow

A practical workflow is:

```text
1. Check whether the database exists
        ↓
2. Create it if required
        ↓
3. Select it with USE
        ↓
4. Create or inspect objects
        ↓
5. Verify the current database
        ↓
6. Perform required operations
        ↓
7. Drop only when intentionally required
```

Useful commands:

```sql
SHOW DATABASES;
SELECT DATABASE();
USE database_name;
SHOW TABLES;
```

---

## 24. Common Mistakes

### Mistake 1: Querying an unselected database

```sql
SELECT * FROM employees;
```

If no database is selected and the table is not qualified, MySQL may return an error.

### Mistake 2: Using the wrong database

Always verify:

```sql
SELECT DATABASE();
```

### Mistake 3: Dropping the wrong database

Check the exact database name before using `DROP DATABASE`.

### Mistake 4: Assuming schema means the same thing in every RDBMS

MySQL treats schema and database as synonyms, but other database systems may use schemas differently.

### Mistake 5: Ignoring character set and collation requirements

Text storage and comparison behavior can be affected by these settings.

---

## 25. Interview-Focused Questions

Try to answer each question yourself before opening the answer.

### Q1. What is a database?

<details>
<summary><strong>Answer</strong></summary>

A database is an organized collection of data managed by a database management system. In MySQL, a database is also commonly called a schema and acts as a logical container for objects such as tables, views, and stored programs.

</details>

---

### Q2. What is the difference between a database and a schema in MySQL?

<details>
<summary><strong>Answer</strong></summary>

In MySQL, **database** and **schema** are synonyms. `CREATE DATABASE` and `CREATE SCHEMA` can both be used to create a logical container for database objects.

This differs from systems where a schema is a namespace inside a database.

</details>

---

### Q3. What does the `USE` statement do?

<details>
<summary><strong>Answer</strong></summary>

`USE database_name` selects the default database for the current session. After selecting it, unqualified object names such as `employees` are resolved within that database.

```sql
USE company_db;
```

</details>

---

### Q4. How can you check which database is currently selected?

<details>
<summary><strong>Answer</strong></summary>

Use the `DATABASE()` function:

```sql
SELECT DATABASE();
```

It returns the name of the current default database, or `NULL` when no database is selected.

</details>

---

### Q5. How do you query a table from another database?

<details>
<summary><strong>Answer</strong></summary>

Use a fully qualified object name:

```sql
SELECT *
FROM sales_db.orders;
```

The general syntax is `database_name.object_name`.

</details>

---

### Q6. What is the difference between `DROP DATABASE` and `DROP TABLE`?

<details>
<summary><strong>Answer</strong></summary>

`DROP DATABASE` removes the database and the objects contained within it. `DROP TABLE` removes only the specified table.

Both are destructive operations, so they should be used carefully.

</details>

---

### Q7. How can you list all databases available to your MySQL account?

<details>
<summary><strong>Answer</strong></summary>

Use:

```sql
SHOW DATABASES;
```

The results depend on the databases visible to the current account's privileges.

</details>

---

### Q8. Why would you use `IF NOT EXISTS` when creating a database?

<details>
<summary><strong>Answer</strong></summary>

It makes the operation idempotent with respect to an existing database: if the database already exists, MySQL does not raise the normal "database exists" error.

```sql
CREATE DATABASE IF NOT EXISTS sales_db;
```

</details>

---

### Q9. What is a fully qualified table name?

<details>
<summary><strong>Answer</strong></summary>

A fully qualified table name includes the database name:

```sql
SELECT *
FROM sales_db.orders;
```

It explicitly identifies which database contains the table and is useful when multiple databases are involved.

</details>

---

### Q10. What is `INFORMATION_SCHEMA` used for?

<details>
<summary><strong>Answer</strong></summary>

`INFORMATION_SCHEMA` provides metadata about databases and database objects. It can be queried to inspect schemas, tables, columns, indexes, constraints, and other metadata.

It is useful for administration, auditing, automation, and Data Engineering workflows.

</details>

---

### Q11. Can two databases contain tables with the same name?

<details>
<summary><strong>Answer</strong></summary>

Yes. For example, both `sales_db` and `analytics_db` can contain a table named `customers`.

They can be distinguished using fully qualified names:

```sql
SELECT * FROM sales_db.customers;
SELECT * FROM analytics_db.customers;
```

</details>

---

### Q12. Why should you verify the current database before running a destructive statement?

<details>
<summary><strong>Answer</strong></summary>

Because the current database determines the target of many unqualified object references. Checking with:

```sql
SELECT DATABASE();
```

helps prevent accidental changes to the wrong database.

</details>

---

### Q13. What are character set and collation at the database level?

<details>
<summary><strong>Answer</strong></summary>

A **character set** defines how text characters are represented and stored. A **collation** defines rules used for comparing and sorting text.

A database can have default values that influence objects created inside it.

</details>

---

### Q14. How would you explain the importance of databases in a Data Engineering environment?

<details>
<summary><strong>Answer</strong></summary>

Databases provide logical organization and separation for data and database objects. They can help separate domains, environments, workloads, and access boundaries.

For example, an organization may logically separate raw, staging, curated, and reporting data depending on its architecture.

</details>

---

### Q15. An interviewer asks: "You have two databases, `sales_db` and `reporting_db`. How can you read `orders` from `sales_db` without changing the current database?"

<details>
<summary><strong>Answer</strong></summary>

Use the fully qualified table name:

```sql
SELECT *
FROM sales_db.orders;
```

This explicitly references `sales_db.orders` regardless of which database is currently selected with `USE`.

</details>

---

## 26. Quick Revision

```text
Database / Schema → Logical container for MySQL objects
CREATE DATABASE   → Create a database
CREATE SCHEMA     → Create a schema (synonym in MySQL)
SHOW DATABASES    → List visible databases
USE db_name       → Select current/default database
DATABASE()        → Return current database
SHOW TABLES       → List tables in current database
DROP DATABASE     → Remove database and its objects

database.table    → Fully qualified object name

INFORMATION_SCHEMA → Metadata about databases and objects
```

### Essential Commands

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

- [`examples.sql`](./examples.sql) — worked examples for databases, schemas, and metadata
- [`practice.sql`](./practice.sql) — hands-on exercises and interview practice

## ✅ Completion Checklist

- [ ] Explain database vs schema in MySQL
- [ ] Create a database/schema
- [ ] List databases
- [ ] Select a database with `USE`
- [ ] Check the current database
- [ ] Create and inspect tables inside a database
- [ ] Use fully qualified object names
- [ ] Query `INFORMATION_SCHEMA`
- [ ] Understand database character set and collation defaults
- [ ] Explain safe use of `DROP DATABASE`
- [ ] Understand multiple databases on one MySQL server
- [ ] Answer the interview questions confidently
