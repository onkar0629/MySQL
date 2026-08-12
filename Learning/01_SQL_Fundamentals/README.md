# 01 — SQL Fundamentals

## 📌 Overview

SQL (Structured Query Language) is the foundation of relational data work. As a Data Engineer, SQL is used to inspect source systems, transform records, validate pipelines, reconcile datasets, build analytical tables, troubleshoot production issues, and communicate with relational databases.

This topic builds the mental model required for the rest of this repository: what SQL is, how MySQL fits into the database ecosystem, how relational tables work, how SQL statements are structured, how expressions and aliases work, and how MySQL logically processes a query.

> [!NOTE]
> **Goal:** After this topic, you should be able to read a basic SQL query, explain every clause, distinguish SQL from MySQL, understand relational-table terminology, and describe the simplified logical processing order of a query.

---

## 🎯 Learning Objectives

- Explain SQL, DBMS, RDBMS, database, table, row, and column.
- Explain the difference between SQL and MySQL.
- Understand DDL, DML, DQL, DCL, and TCL.
- Write basic `SELECT`, `FROM`, and `WHERE` queries.
- Use aliases and calculated expressions.
- Understand literals, comments, keywords, identifiers, and statement terminators.
- Understand basic MySQL naming and case-sensitivity behavior.
- Explain logical query processing order.
- Understand why SQL is declarative.
- Recognize common beginner mistakes.

---

# 📚 1. What Is SQL?

**SQL (Structured Query Language)** is a language used to communicate with relational database systems.

SQL can be used to:

- Retrieve data
- Insert data
- Update data
- Delete data
- Create database objects
- Modify database objects
- Control access
- Manage transactions

Example:

```sql
SELECT employee_name, salary
FROM employees
WHERE salary > 50000;
```

SQL is primarily **declarative**. You describe **what result you need**; the database engine determines how to produce it.

---

# 📚 2. What Is MySQL?

**MySQL** is a relational database management system (**RDBMS**) that implements SQL and provides the infrastructure required to store and process relational data.

```text
SQL      → Language
MySQL    → RDBMS that implements SQL
```

MySQL also provides capabilities such as query optimization, storage engines, indexes, transactions, users, and permissions.

---

# 📚 3. SQL vs MySQL

| SQL | MySQL |
|---|---|
| A language | An RDBMS/database system |
| Used to communicate with relational databases | Implements SQL and provides database functionality |
| Used by many database products | One specific database product |
| Includes commands such as `SELECT`, `INSERT`, `UPDATE` | Provides optimizer, storage engines, indexes, transactions, security, etc. |

Other RDBMS products include PostgreSQL, Oracle Database, and Microsoft SQL Server.

> [!IMPORTANT]
> SQL concepts transfer between database systems, but exact syntax and features can differ. This repository focuses on **MySQL**.

---

# 📚 4. Database, DBMS, and RDBMS

### Database

An organized collection of data.

### DBMS

A **Database Management System** is software used to create, store, retrieve, modify, and control data.

### RDBMS

A **Relational Database Management System** stores data using the relational model, commonly represented by related tables.

```text
Database
   ↓
Managed by DBMS / RDBMS
   ↓
SQL used to communicate
```

MySQL is an RDBMS.

---

# 📚 5. Relational Database Concepts

A relational database organizes data into tables.

| employee_id | employee_name | department | salary |
|---:|---|---|---:|
| 101 | Amit | Data | 60000 |
| 102 | Priya | Finance | 55000 |
| 103 | Rahul | Data | 70000 |

### Table

A collection of related records.

### Row

One record in a table.

### Column

An attribute describing a record.

### Value

The actual data stored at a row/column intersection.

These terms become essential when we learn keys, joins, normalization, indexes, and data modeling.

---

# 📚 6. SQL Command Categories

| Category | Purpose | Examples |
|---|---|---|
| DDL | Define database objects | `CREATE`, `ALTER`, `DROP`, `TRUNCATE` |
| DML | Modify table data | `INSERT`, `UPDATE`, `DELETE` |
| DQL | Retrieve data | `SELECT` |
| DCL | Control permissions | `GRANT`, `REVOKE` |
| TCL | Control transactions | `COMMIT`, `ROLLBACK`, `SAVEPOINT` |

> [!NOTE]
> Classification varies slightly across references. For interviews, know both the terminology and the practical purpose of each group.

---

# 📚 7. Basic SQL Query Structure

The basic retrieval pattern is:

```sql
SELECT column1, column2
FROM table_name
WHERE condition;
```

Example:

```sql
SELECT employee_name, salary
FROM employees
WHERE salary > 50000;
```

- `SELECT` → columns or expressions to return
- `FROM` → source of the data
- `WHERE` → row-level filtering condition

This pattern will be extended throughout the repository with joins, grouping, subqueries, CTEs, and window functions.

---

# 📚 8. SELECT

`SELECT` retrieves data.

### Specific columns

```sql
SELECT employee_id, employee_name
FROM employees;
```

### All columns

```sql
SELECT *
FROM employees;
```

`SELECT *` is useful while exploring a table, but production queries should generally select only required columns.

Benefits of explicit columns:

- Clear intent
- Less unnecessary data transfer
- Easier review
- Safer downstream dependencies

---

# 📚 9. FROM

`FROM` identifies the data source.

```sql
SELECT employee_name
FROM employees;
```

Later, a `FROM` clause can involve joins, subqueries, CTEs, views, and derived tables.

For Data Engineering, always ask:

> **What is the grain of this source?**

For example, an `orders` table may contain one row per order, while `order_items` contains one row per order-product combination. This difference becomes critical when joins are introduced.

---

# 📚 10. WHERE

`WHERE` filters rows before grouping and aggregation.

```sql
SELECT employee_name, salary
FROM employees
WHERE salary > 50000;
```

Multiple conditions can be combined:

```sql
SELECT employee_name, salary
FROM employees
WHERE department = 'Data'
  AND salary > 50000;
```

We will study filtering operators in detail in the next topics.

---

# 📚 11. Column Aliases

An alias gives a temporary name to an output column or expression.

```sql
SELECT
    employee_name AS name,
    salary * 12 AS annual_salary
FROM employees;
```

The alias changes the displayed result name; it does **not** rename the underlying table column.

Aliases are particularly useful for calculated values and readable reporting output.

---

# 📚 12. Expressions and Calculated Columns

SQL can calculate values while producing a result.

```sql
SELECT
    employee_name,
    salary,
    salary * 12 AS annual_salary,
    salary + 5000 AS adjusted_salary
FROM employees;
```

Common arithmetic operators:

| Operator | Meaning |
|---|---|
| `+` | Addition |
| `-` | Subtraction |
| `*` | Multiplication |
| `/` | Division |
| `%` | Modulo/remainder |

Expressions are heavily used in transformation logic and feature engineering.

---

# 📚 13. Literals

A literal is a fixed value written directly in SQL.

```sql
SELECT 100 AS number_value;
SELECT 99.50 AS price;
SELECT 'MySQL' AS technology;
```

Common literals include numeric, string, date/time, and `NULL` values.

Example:

```sql
SELECT
    'Mumbai' AS city,
    100000 AS salary,
    NULL AS manager_id;
```

---

# 📚 14. SQL Comments

Comments document SQL and are ignored by the SQL parser.

### Single-line

```sql
-- Retrieve employees
SELECT *
FROM employees;
```

MySQL also supports:

```sql
# Retrieve employees
SELECT *
FROM employees;
```

### Multi-line

```sql
/*
   Retrieve employee information
   for review.
*/
SELECT *
FROM employees;
```

Comments are useful for explaining business logic in production transformations.

---

# 📚 15. Statement Terminator

A semicolon normally terminates a SQL statement.

```sql
SELECT * FROM employees;
SELECT * FROM departments;
```

It is especially important when executing multiple statements in a SQL script.

---

# 📚 16. Keywords and Identifiers

### Keywords

Keywords have special meaning in SQL/MySQL.

```text
SELECT
FROM
WHERE
GROUP BY
ORDER BY
INSERT
UPDATE
DELETE
```

### Identifiers

Identifiers name database objects such as databases, tables, columns, indexes, and views.

```sql
SELECT employee_name
FROM employees;
```

Here `SELECT` and `FROM` are keywords, while `employee_name` and `employees` are identifiers.

---

# 📚 17. Case Sensitivity in MySQL

SQL keywords and function names are generally case-insensitive.

```sql
SELECT employee_name FROM employees;
```

and

```sql
select employee_name from employees;
```

are normally equivalent.

Identifier case behavior is more complicated and can depend on object type, operating system, and MySQL configuration. Table-name behavior is particularly important when moving workloads between environments.

> [!WARNING]
> Use consistent identifier naming. Do not rely on a development environment behaving exactly like production.

---

# 📚 18. Naming Conventions

A practical convention for this repository is `snake_case`.

```text
employee_id
customer_id
order_date
product_name
created_at
```

Good names should be descriptive, consistent, stable, and meaningful to the business.

Avoid names such as:

```text
x
abc
col1
new_data
final_final_table
```

---

# 📚 19. Logical Query Processing Order

The order in which SQL is **written** differs from the simplified logical order in which the query is evaluated.

Example:

```sql
SELECT
    department,
    COUNT(*) AS employee_count
FROM employees
WHERE salary > 50000
GROUP BY department
HAVING COUNT(*) >= 2
ORDER BY employee_count DESC;
```

Simplified logical order:

```text
1. FROM
2. WHERE
3. GROUP BY
4. HAVING
5. SELECT
6. ORDER BY
```

This mental model helps explain many interview questions involving aliases, aggregation, joins, and window functions.

> [!IMPORTANT]
> Logical processing order is a conceptual model. It is not the same as the physical execution plan chosen by MySQL.

---

# 📚 20. SQL Is Declarative

In SQL, you specify **what** result you want rather than manually describing every processing step.

```sql
SELECT employee_name
FROM employees
WHERE salary > 50000;
```

You do not tell MySQL exactly how to scan every row. The optimizer determines an execution strategy based on available information such as indexes, statistics, and table structure.

This distinction becomes important when we learn `EXPLAIN` and query optimization.

---

# 🔬 21. Logical Processing vs Physical Execution

These concepts should not be confused.

### Logical processing

A conceptual model used to understand query meaning:

```text
FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY
```

### Physical execution

The actual operations selected by MySQL.

MySQL may consider:

- Index access
- Table scans
- Filtering strategies
- Join algorithms
- Sorting
- Statistics
- Data distribution

The physical plan can differ from the simplified logical order while still producing the correct result.

---

# 🌎 22. Real-World Example

Suppose an e-commerce `orders` table contains:

```text
order_id
customer_id
order_date
status
amount
```

Business requirement:

> Find completed orders above ₹10,000.

SQL:

```sql
SELECT
    order_id,
    customer_id,
    order_date,
    amount
FROM orders
WHERE status = 'COMPLETED'
  AND amount > 10000;
```

The same pattern can be used for reporting, ETL/ELT transformations, data-quality checks, and pipeline debugging.

---

# 🏗️ 23. Data Engineering Use Cases

### Source inspection

```sql
SELECT *
FROM source_orders
LIMIT 10;
```

### Record counting

```sql
SELECT COUNT(*)
FROM source_orders;
```

### Data-quality check

```sql
SELECT COUNT(*)
FROM source_orders
WHERE order_id IS NULL;
```

### Transformation

```sql
SELECT
    order_id,
    amount * 1.18 AS amount_with_tax
FROM source_orders;
```

### Pipeline validation

```sql
SELECT COUNT(*)
FROM target_orders;
```

These simple patterns form the foundation for more complex ETL/ELT logic later.

---

# ⚠️ 24. Common Mistakes

### Mistake 1 — Confusing SQL and MySQL

SQL is the language; MySQL is an RDBMS that implements SQL.

### Mistake 2 — Using `SELECT *` everywhere

Useful for exploration, but often too broad for production transformations.

### Mistake 3 — Forgetting the source table

```sql
SELECT employee_name;
```

This does not retrieve a column from a table because no table source is specified.

### Mistake 4 — Referencing a non-existent column

```sql
SELECT employee_name, age
FROM employees;
```

This fails if `age` is not defined.

### Mistake 5 — Ignoring logical processing order

This creates confusion around aliases, aggregation, joins, and window functions.

### Mistake 6 — Assuming identifier casing is identical everywhere

Environment and configuration can affect identifier behavior.

### Mistake 7 — Memorizing syntax without understanding the result

Interviewers frequently test **why** a query works, not only whether you remember syntax.

---

# 🎤 25. Interview-Focused Questions

Try answering each question yourself before opening the answer.

### Q1. What is SQL, and why is it called declarative?

<details>
<summary><strong>Answer</strong></summary>

SQL is a language used to communicate with relational databases. It is declarative because the user specifies the required result while the database determines how to execute the request.

</details>

---

### Q2. What is the difference between SQL and MySQL?

<details>
<summary><strong>Answer</strong></summary>

SQL is a language. MySQL is an RDBMS that implements SQL and provides database functionality such as storage, optimization, indexes, transactions, and security.

</details>

---

### Q3. What is the difference between DBMS and RDBMS?

<details>
<summary><strong>Answer</strong></summary>

A DBMS manages databases. An RDBMS is a DBMS based on the relational model, where data is represented as related tables. MySQL is an RDBMS.

</details>

---

### Q4. What are DDL, DML, DQL, DCL, and TCL?

<details>
<summary><strong>Answer</strong></summary>

DDL defines objects (`CREATE`, `ALTER`, `DROP`, `TRUNCATE`), DML modifies data (`INSERT`, `UPDATE`, `DELETE`), DQL retrieves data (`SELECT`), DCL controls permissions (`GRANT`, `REVOKE`), and TCL controls transactions (`COMMIT`, `ROLLBACK`, `SAVEPOINT`).

</details>

---

### Q5. What is the difference between a row and a column?

<details>
<summary><strong>Answer</strong></summary>

A row represents one record. A column represents an attribute of that record. For example, one employee is a row and `salary` is a column.

</details>

---

### Q6. Why is selecting specific columns generally better than SELECT * in production?

<details>
<summary><strong>Answer</strong></summary>

It makes the query explicit, reduces unnecessary data retrieval, improves readability, and reduces accidental dependencies on future schema changes.

</details>

---

### Q7. What is a column alias?

<details>
<summary><strong>Answer</strong></summary>

An alias temporarily changes the name displayed for a column or expression.

```sql
SELECT salary * 12 AS annual_salary
FROM employees;
```

It does not rename the physical table column.

</details>

---

### Q8. What is the simplified logical order of query processing?

<details>
<summary><strong>Answer</strong></summary>

For a grouped query:

```text
FROM
WHERE
GROUP BY
HAVING
SELECT
ORDER BY
```

This is a conceptual order used to reason about SQL behavior.

</details>

---

### Q9. Why can a SELECT alias generally not be used in WHERE?

<details>
<summary><strong>Answer</strong></summary>

Because `WHERE` is logically processed before `SELECT`, so the alias created by `SELECT` is not available at the `WHERE` stage. A subquery or CTE can be used when filtering a calculated result at a later stage.

</details>

---

### Q10. Is MySQL case-sensitive?

<details>
<summary><strong>Answer</strong></summary>

SQL keywords and function names are generally case-insensitive. Identifier case behavior depends on the object type, operating system, and MySQL configuration. Table-name case behavior is particularly important across environments.

</details>

---

### Q11. What is the difference between a keyword and an identifier?

<details>
<summary><strong>Answer</strong></summary>

A keyword has special meaning in SQL, such as `SELECT` or `FROM`. An identifier names an object, such as a table or column.

</details>

---

### Q12. What happens at a high level when MySQL receives a query?

<details>
<summary><strong>Answer</strong></summary>

MySQL parses and validates the statement, determines an execution strategy, and executes it. The optimizer can consider indexes, statistics, access paths, and other factors before execution.

</details>

---

### Q13. What is the difference between logical query processing and physical execution?

<details>
<summary><strong>Answer</strong></summary>

Logical processing is the conceptual model used to understand the query. Physical execution is the actual strategy selected by MySQL. The optimizer may use an index or another access path even though the logical model starts with `FROM`.

</details>

---

### Q14. Why are SQL fundamentals important for a Data Engineer?

<details>
<summary><strong>Answer</strong></summary>

Data Engineers use SQL for extraction, transformation, validation, reconciliation, incremental processing, warehouse operations, and troubleshooting. Advanced topics such as joins, CTEs, window functions, and optimization all depend on these fundamentals.

</details>

---

## 🔄 26. Quick Revision

```text
SQL       → language
MySQL     → RDBMS
Database  → organized collection of data
Table     → collection of related records
Row       → one record
Column    → one attribute

DDL → CREATE / ALTER / DROP / TRUNCATE
DML → INSERT / UPDATE / DELETE
DQL → SELECT
DCL → GRANT / REVOKE
TCL → COMMIT / ROLLBACK / SAVEPOINT

Basic query:
SELECT ...
FROM ...
WHERE ...

Logical order:
FROM
WHERE
GROUP BY
HAVING
SELECT
ORDER BY
```

> [!TIP]
> If you can explain every item in this revision block without memorizing the wording, you have the foundation required for the next topics.

---

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — worked SQL fundamentals examples
- [`practice.sql`](./practice.sql) — hands-on exercises and interview practice
