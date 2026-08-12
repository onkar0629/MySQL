# SQL Fundamentals

SQL (Structured Query Language) is the standard language used to communicate with relational databases. This topic builds the foundation required to write, read, understand, and troubleshoot SQL queries in MySQL.

> [!NOTE]
> **Goal:** By the end of this topic, you should understand the SQL language itself, how MySQL fits into the database ecosystem, how a basic SQL statement is structured, and how MySQL logically processes a query.

## 1. What Is SQL?

**SQL (Structured Query Language)** is a declarative language used to work with data stored in relational databases.

SQL can be used to:

- Retrieve data
- Insert new data
- Modify existing data
- Delete data
- Create and modify database objects
- Control access to database objects
- Manage transactions

SQL is **declarative**, meaning you describe **what data you want**, while the database engine determines how to execute the request.

Example:

```sql
SELECT employee_name, salary
FROM employees
WHERE salary > 50000;
```

The query describes the required result. MySQL decides the execution strategy.

---

## 2. What Is MySQL?

**MySQL** is a relational database management system (**RDBMS**) that stores data in tables and provides a SQL interface for working with that data.

In simple terms:

```text
SQL      → Language
MySQL    → Database Management System that understands SQL
```

MySQL provides the database engine, storage, query processing, transactions, indexes, security features, and other capabilities needed to manage relational data.

---

## 3. SQL vs MySQL

| SQL | MySQL |
|---|---|
| A programming/query language | An RDBMS/database system |
| Defines how we communicate with relational databases | Implements SQL and provides database functionality |
| Used by many relational database systems | One specific database product |
| Examples include `SELECT`, `INSERT`, `UPDATE` | Provides storage engines, optimizer, indexes, transactions, users, etc. |

Other relational database systems include PostgreSQL, Oracle Database, Microsoft SQL Server, and others. They all use SQL, but their syntax and features can differ.

---

## 4. DBMS, RDBMS, and Database

### Database

A **database** is an organized collection of data.

### DBMS

A **Database Management System (DBMS)** is software used to create, store, manage, retrieve, and control data in databases.

### RDBMS

A **Relational Database Management System (RDBMS)** stores data using related tables and follows the relational model.

MySQL is an RDBMS.

```text
Database
   ↓
Managed by
   ↓
DBMS / RDBMS
   ↓
SQL used to communicate with it
```

---

## 5. Relational Database Concepts

A relational database organizes data into **tables**.

Example:

| employee_id | employee_name | department | salary |
|---:|---|---|---:|
| 101 | Amit | Data | 60000 |
| 102 | Priya | Finance | 55000 |
| 103 | Rahul | Data | 70000 |

### Table

A table stores related records.

### Row

A row represents one record.

### Column

A column represents an attribute of the data.

### Value

A value is the actual piece of data stored at the intersection of a row and column.

---

## 6. SQL Command Categories

SQL statements are commonly grouped into these categories.

| Category | Meaning | Examples |
|---|---|---|
| DDL | Data Definition Language | `CREATE`, `ALTER`, `DROP`, `TRUNCATE` |
| DML | Data Manipulation Language | `INSERT`, `UPDATE`, `DELETE` |
| DQL | Data Query Language | `SELECT` |
| DCL | Data Control Language | `GRANT`, `REVOKE` |
| TCL | Transaction Control Language | `COMMIT`, `ROLLBACK`, `SAVEPOINT` |

> [!IMPORTANT]
> Different references sometimes classify `SELECT` differently or group SQL commands differently. For interview preparation, know both the terminology and the practical purpose of each command.

---

## 7. Basic SQL Statement Structure

A basic query commonly follows this structure:

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

At this stage, understand the role of each clause:

- `SELECT` → specifies the columns or expressions to return
- `FROM` → specifies the source table or tables
- `WHERE` → filters rows based on a condition

---

## 8. SELECT

`SELECT` is used to retrieve data.

### Select specific columns

```sql
SELECT employee_id, employee_name
FROM employees;
```

### Select all columns

```sql
SELECT *
FROM employees;
```

> [!TIP]
> `SELECT *` is useful while exploring a table, but explicitly selecting required columns is usually preferable in production queries because it improves readability and avoids unnecessary data retrieval.

---

## 9. FROM

`FROM` identifies the data source.

```sql
SELECT employee_name
FROM employees;
```

The source can later become more complex, including joins, subqueries, CTEs, and derived tables.

---

## 10. Column Aliases

An alias gives a temporary name to a column or expression in the query result.

```sql
SELECT
    employee_name AS name,
    salary * 12 AS annual_salary
FROM employees;
```

`AS` is commonly used, although MySQL also permits omission of `AS` in many alias expressions.

---

## 11. Expressions and Calculated Columns

SQL can perform calculations directly inside a query.

```sql
SELECT
    employee_name,
    salary,
    salary * 12 AS annual_salary
FROM employees;
```

Common operators include:

```text
+   Addition
-   Subtraction
*   Multiplication
/   Division
%   Modulo
```

---

## 12. Literals

A literal is a fixed value written directly in a SQL statement.

Examples:

```sql
SELECT 100 AS number_value;
SELECT 'MySQL' AS technology;
SELECT 99.50 AS price;
```

Common literal types include numeric, string, date/time, and boolean-like values depending on context and MySQL data types.

---

## 13. SQL Comments

Comments document SQL and are ignored by the SQL parser.

### Single-line comment

```sql
-- This is a comment
SELECT * FROM employees;
```

MySQL also supports `#` for single-line comments.

```sql
# This is also a MySQL single-line comment
SELECT * FROM employees;
```

### Multi-line comment

```sql
/*
   This is a
   multi-line comment.
*/
SELECT * FROM employees;
```

---

## 14. Statement Terminator

A semicolon `;` is commonly used to terminate a SQL statement.

```sql
SELECT * FROM employees;
SELECT * FROM departments;
```

It is especially important when executing multiple statements in a script or SQL client.

---

## 15. SQL Keywords and Identifiers

### Keywords

Keywords are reserved or special words recognized by SQL/MySQL.

Examples:

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

Identifiers are names of database objects such as:

- Databases
- Tables
- Columns
- Indexes
- Views

Example:

```sql
SELECT employee_name
FROM employees;
```

Here `SELECT` and `FROM` are keywords, while `employee_name` and `employees` are identifiers.

---

## 16. Case Sensitivity in MySQL

SQL keywords are conventionally written in uppercase for readability:

```sql
SELECT employee_name
FROM employees;
```

MySQL generally treats SQL keywords and function names case-insensitively. Identifier case sensitivity can depend on the object type, operating system, and MySQL configuration. Table-name behavior is particularly important when moving applications between environments.

> [!WARNING]
> Do not assume that every identifier behaves as case-insensitive everywhere. Follow consistent naming conventions and test portability when environments differ.

---

## 17. Naming Conventions

Use clear, consistent names for database objects.

Recommended style:

```text
snake_case
```

Examples:

```text
employee_id
customer_orders
order_date
product_name
```

Good names make SQL easier to read, maintain, and review.

---

## 18. Logical Query Processing Order

One of the most important concepts for SQL interviews is that the order in which we **write** a query is not the same as the logical order in which SQL processes it.

For a typical query:

```sql
SELECT department, COUNT(*) AS employee_count
FROM employees
WHERE salary > 50000
GROUP BY department
HAVING COUNT(*) >= 2
ORDER BY employee_count DESC;
```

The simplified logical processing order is:

```text
1. FROM
2. WHERE
3. GROUP BY
4. HAVING
5. SELECT
6. ORDER BY
```

Later topics will add concepts such as joins, window functions, and `LIMIT` to this model.

> [!IMPORTANT]
> Understanding logical query processing order explains many common SQL interview questions, especially questions involving aliases, filtering aggregated results, and window functions.

---

## 19. SQL Is Declarative

SQL focuses on **what** result is required rather than explicitly describing every computational step.

For example:

```sql
SELECT employee_name
FROM employees
WHERE salary > 50000;
```

You specify the required result. The MySQL optimizer determines an execution strategy based on available indexes, statistics, table structure, and other factors.

This distinction becomes especially important when learning **execution plans and query optimization**.

---

## 20. Common Beginner Mistakes

### Mistake 1: Forgetting `FROM`

```sql
SELECT employee_name;
```

This is not a valid way to retrieve a column from a table.

### Mistake 2: Selecting a column that does not exist

```sql
SELECT employee_name, age
FROM employees;
```

If `age` does not exist, MySQL returns an error.

### Mistake 3: Confusing SQL and MySQL

SQL is the language; MySQL is an RDBMS that implements SQL and provides additional database functionality.

### Mistake 4: Using `SELECT *` everywhere

It can make queries less explicit and may retrieve unnecessary columns.

### Mistake 5: Ignoring naming consistency

Inconsistent object naming makes databases harder to maintain.

### Mistake 6: Memorizing syntax without understanding logical processing

Understanding how a query is logically processed is more valuable than memorizing isolated statements.

---

## 21. Interview-Focused Questions

You should be able to answer these confidently:

1. What is SQL?
2. What is MySQL?
3. What is the difference between SQL and MySQL?
4. What is an RDBMS?
5. What is the difference between a database, DBMS, and RDBMS?
6. What are DDL, DML, DQL, DCL, and TCL?
7. What does `SELECT` do?
8. What does `FROM` do?
9. What is a column alias?
10. What is the difference between a column and a row?
11. What is the purpose of `SELECT *`?
12. What is the logical order of SQL query processing?
13. Why is SQL called a declarative language?
14. What are SQL keywords and identifiers?
15. Is SQL case-sensitive in MySQL?

---

## 22. Quick Revision

```text
SQL       → Language used to work with relational data
MySQL     → RDBMS that implements SQL
Table     → Collection of related records
Row       → One record
Column     → Attribute of a record
SELECT    → Retrieve columns/expressions
FROM      → Define the data source
Alias     → Temporary output name
Expression→ Calculation or value evaluated by SQL
DDL       → Define database objects
DML       → Modify table data
DQL       → Retrieve data
DCL       → Control access
TCL       → Control transactions
```

### Basic Query Template

```sql
SELECT column1, column2
FROM table_name
WHERE condition;
```

### Logical Processing Reminder

```text
FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY
```

---

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — worked examples covering the concepts above
- [`practice.sql`](./practice.sql) — hands-on exercises for reinforcement

## ✅ Completion Checklist

- [ ] Understand SQL and MySQL
- [ ] Understand DBMS and RDBMS
- [ ] Understand tables, rows, columns, and values
- [ ] Know SQL command categories
- [ ] Understand `SELECT` and `FROM`
- [ ] Write basic expressions and aliases
- [ ] Use SQL comments correctly
- [ ] Understand keywords and identifiers
- [ ] Understand MySQL case-sensitivity considerations
- [ ] Explain logical query processing order
- [ ] Answer the interview questions above confidently
