# 🎯 Interview-Focused Questions

> [!QUESTION]
>
> ## Q1. What is SQL, and what is MySQL?
>
> <details>
> <summary><strong>Answer</strong></summary>
>
> **SQL (Structured Query Language)** is a standard language used to interact with relational databases. It is used to define database objects, retrieve data, insert or modify data, control access, and manage transactions.
>
> **MySQL** is a relational database management system (RDBMS) that implements SQL and provides the software required to store, manage, and retrieve relational data.
>
> In simple terms: **SQL is the language; MySQL is the database system that understands and executes SQL.**
>
> </details>

> [!QUESTION]
>
> ## Q2. What is the difference between SQL and MySQL?
>
> <details>
> <summary><strong>Answer</strong></summary>
>
> SQL is a **language/specification** used to communicate with relational databases. MySQL is a **database management system** that uses SQL.
>
> A useful interview answer is: **SQL tells the database what to do, while MySQL is one system that executes SQL statements and manages the underlying data.**
>
> </details>

> [!QUESTION]
>
> ## Q3. What is a DBMS? What is an RDBMS?
>
> <details>
> <summary><strong>Answer</strong></summary>
>
> A **DBMS (Database Management System)** is software used to store, manage, retrieve, and control data in databases.
>
> An **RDBMS (Relational Database Management System)** stores data in related tables and uses relational concepts such as rows, columns, keys, and relationships.
>
> MySQL is an RDBMS.
>
> </details>

> [!QUESTION]
>
> ## Q4. What is a table in a relational database?
>
> <details>
> <summary><strong>Answer</strong></summary>
>
> A table is a structured collection of related data organized into **rows and columns**.
>
> - **Row:** represents one record.
> - **Column:** represents an attribute or field.
> - **Value:** represents the data stored at the intersection of a row and column.
>
> </details>

> [!QUESTION]
>
> ## Q5. What are DDL, DML, DQL, DCL, and TCL?
>
> <details>
> <summary><strong>Answer</strong></summary>
>
> These categories describe common types of SQL statements:
>
> | Category | Purpose | Examples |
> |---|---|---|
> | DDL | Define database objects | `CREATE`, `ALTER`, `DROP`, `TRUNCATE` |
> | DML | Modify data | `INSERT`, `UPDATE`, `DELETE` |
> | DQL | Retrieve data | `SELECT` |
> | DCL | Control permissions | `GRANT`, `REVOKE` |
> | TCL | Manage transactions | `COMMIT`, `ROLLBACK`, `SAVEPOINT` |
>
> </details>

> [!QUESTION]
>
> ## Q6. What is the difference between `SELECT *` and selecting specific columns?
>
> <details>
> <summary><strong>Answer</strong></summary>
>
> `SELECT *` requests all columns from the selected table, while explicitly naming columns requests only the required data.
>
> In production queries, selecting only required columns is generally preferable because it makes the query clearer and can reduce unnecessary data transfer and processing.
>
> </details>

> [!QUESTION]
>
> ## Q7. What is a column alias? Why is it used?
>
> <details>
> <summary><strong>Answer</strong></summary>
>
> A column alias gives a temporary name to a column or expression in the query result.
>
> ```sql
> SELECT salary * 12 AS annual_salary
> FROM employees;
> ```
>
> Here, `annual_salary` is the alias. Aliases improve readability and make calculated columns easier to understand.
>
> </details>

> [!QUESTION]
>
> ## Q8. What is the logical order of SQL query execution?
>
> <details>
> <summary><strong>Answer</strong></summary>
>
> Although we normally write `SELECT` first, a simplified logical processing order is:
>
> ```text
> FROM
> WHERE
> GROUP BY
> HAVING
> SELECT
> DISTINCT
> ORDER BY
> LIMIT
> ```
>
> Understanding this order helps explain why a `SELECT` alias generally cannot be referenced in `WHERE`.
>
> </details>

> [!QUESTION]
>
> ## Q9. What is the difference between a SQL keyword and an identifier?
>
> <details>
> <summary><strong>Answer</strong></summary>
>
> A **keyword** is a reserved or special word that has meaning in SQL, such as `SELECT`, `FROM`, and `WHERE`.
>
> An **identifier** is a name given to database objects such as databases, tables, columns, indexes, and views.
>
> Good naming practices avoid unnecessary conflicts with reserved keywords.
>
> </details>

> [!QUESTION]
>
> ## Q10. Is SQL case-sensitive in MySQL?
>
> <details>
> <summary><strong>Answer</strong></summary>
>
> The answer depends on what is being considered.
>
> SQL keywords are conventionally written in uppercase, but SQL keywords themselves are not case-sensitive. Identifier behavior can differ depending on the object type and MySQL configuration, particularly on case-sensitive operating systems.
>
> For consistent code, use a standard naming convention and write SQL keywords consistently in uppercase.
>
> </details>

> [!QUESTION]
>
> ## Q11. Why is SQL called a declarative language?
>
> <details>
> <summary><strong>Answer</strong></summary>
>
> SQL is generally considered **declarative** because you specify **what result you want**, rather than explicitly describing every step the database must perform to obtain that result.
>
> For example:
>
> ```sql
> SELECT employee_name
> FROM employees
> WHERE salary > 50000;
> ```
>
> The database optimizer determines an execution strategy for producing the requested result.
>
> </details>

> [!QUESTION]
>
> ## Q12. Why should we avoid `SELECT *` in production queries?
>
> <details>
> <summary><strong>Answer</strong></summary>
>
> `SELECT *` can return columns that the application does not need. This can increase data transfer, make result sets harder to maintain, and create unexpected behavior when the table schema changes.
>
> Prefer explicitly selecting the required columns, especially in production and data pipelines.
>
> </details>

> [!QUESTION]
>
> ## Q13. What happens if you omit the `FROM` clause?
>
> <details>
> <summary><strong>Answer</strong></summary>
>
> `FROM` identifies the source table or relation. However, MySQL can evaluate expressions without a table.
>
> ```sql
> SELECT 10 + 20 AS result;
> ```
>
> This returns `30` without reading a table.
>
> </details>

> [!QUESTION]
>
> ## Q14. What is the purpose of the semicolon (`;`) in SQL?
>
> <details>
> <summary><strong>Answer</strong></summary>
>
> The semicolon is commonly used to terminate an SQL statement. It tells the SQL client that the current statement is complete and that another statement may follow.
>
> ```sql
> SELECT * FROM employees;
> ```
>
> </details>

> [!QUESTION]
>
> ## Q15. What are common beginner mistakes when writing SQL?
>
> <details>
> <summary><strong>Answer</strong></summary>
>
> Common mistakes include:
>
> - Using `SELECT *` when only a few columns are required.
> - Forgetting the correct table or column name.
> - Confusing SQL with MySQL.
> - Using an alias incorrectly in `WHERE`.
> - Forgetting the difference between logical query order and written query order.
> - Ignoring `NULL` behavior.
> - Using reserved keywords as identifiers without understanding the implications.
> - Writing ambiguous or poorly named columns.
>
> </details>
