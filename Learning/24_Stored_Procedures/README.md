# 24 — Stored Procedures

> [!NOTE]
> A stored procedure is a named, stored SQL program that can accept parameters, execute multiple SQL statements, use variables and control flow, and return result sets or output values.
>
> For a Data Engineer, the important question is not simply how to write a procedure. It is **when procedural database logic is appropriate, how transactions and errors behave, and when logic should instead live in an ETL/application layer**.

## What You Will Learn

- What stored procedures are and why they exist
- Procedure syntax and `DELIMITER`
- `IN`, `OUT`, and `INOUT` parameters
- Local variables and `DECLARE`
- `SET` and `SELECT ... INTO`
- `IF`, `ELSEIF`, `ELSE`, and `CASE`
- Loops and why they should be used carefully
- Cursors and their practical limitations
- Condition/error handlers
- Transactions inside procedures
- Result sets and output parameters
- Procedure vs function vs application code
- Security and `SQL SECURITY`
- Dependency, deployment, and maintainability concerns
- Data Engineering use cases
- Common mistakes and interview scenarios

---

# 1. Mental Model

Think of a stored procedure as a **database-side program**.

```text
Application / ETL job
        |
        | CALL procedure(...)
        v
+---------------------------+
| MySQL stored procedure    |
|                           |
| variables                 |
| validation                |
| SQL statements            |
| control flow              |
| transaction logic         |
| error handling            |
+---------------------------+
        |
        v
      tables
```

A procedure is useful when a sequence of database operations belongs naturally together and should be invoked as one named operation.

It is not automatically better than application or pipeline code. Database-side procedural logic introduces deployment, testing, observability, and portability considerations.

---

# 2. Basic Syntax

```sql
DELIMITER //

CREATE PROCEDURE procedure_name()
BEGIN
    SELECT 'Hello MySQL';
END //

DELIMITER ;
```

Call it with:

```sql
CALL procedure_name();
```

### Why `DELIMITER`?

The MySQL client normally treats `;` as the end of a statement. A procedure contains multiple statements that themselves end with `;`.

Changing the client delimiter lets MySQL receive the entire procedure definition as one statement.

`DELIMITER` is a **client command**, not a SQL language feature stored inside the procedure.

---

# 3. Procedure With an IN Parameter

`IN` is the normal input parameter.

```sql
DELIMITER //

CREATE PROCEDURE get_employee(IN p_department_id INT)
BEGIN
    SELECT
        employee_id,
        employee_name,
        salary
    FROM employees
    WHERE department_id = p_department_id;
END //

DELIMITER ;
```

Call:

```sql
CALL get_employee(10);
```

The procedure receives a value and uses it during execution.

---

# 4. IN, OUT, and INOUT

## IN

Input only.

```sql
CREATE PROCEDURE example(IN p_id INT)
```

## OUT

The procedure writes a value back to the caller.

```sql
CREATE PROCEDURE count_employees(OUT p_count INT)
BEGIN
    SELECT COUNT(*) INTO p_count
    FROM employees;
END;
```

Call:

```sql
CALL count_employees(@employee_count);
SELECT @employee_count;
```

## INOUT

The parameter enters with a value and can be changed by the procedure.

```sql
CREATE PROCEDURE add_bonus(INOUT p_salary DECIMAL(10,2))
BEGIN
    SET p_salary = p_salary + 5000;
END;
```

Call:

```sql
SET @salary = 80000;
CALL add_bonus(@salary);
SELECT @salary;
```

### Interview rule

```text
IN    → pass value in
OUT   → return value out
INOUT → pass in and modify it
```

---

# 5. Local Variables

Variables declared inside a procedure are local to that procedure invocation.

```sql
DELIMITER //

CREATE PROCEDURE employee_summary(IN p_department_id INT)
BEGIN
    DECLARE v_employee_count INT DEFAULT 0;
    DECLARE v_avg_salary DECIMAL(12,2) DEFAULT 0;

    SELECT COUNT(*), AVG(salary)
    INTO v_employee_count, v_avg_salary
    FROM employees
    WHERE department_id = p_department_id;

    SELECT
        p_department_id AS department_id,
        v_employee_count AS employee_count,
        v_avg_salary AS average_salary;
END //

DELIMITER ;
```

### Important

`DECLARE` statements must appear at the beginning of the relevant `BEGIN ... END` block, before executable statements such as `SET` or `SELECT`.

---

# 6. SET vs SELECT ... INTO

Use `SET` when assigning an expression:

```sql
SET v_status = 'READY';
```

Use `SELECT ... INTO` when retrieving values from a query:

```sql
SELECT COUNT(*)
INTO v_count
FROM orders
WHERE customer_id = p_customer_id;
```

Be careful that a `SELECT ... INTO` intended for one value does not unexpectedly return multiple rows.

---

# 7. IF / ELSEIF / ELSE

```sql
IF v_total >= 100000 THEN
    SET v_segment = 'VIP';
ELSEIF v_total >= 50000 THEN
    SET v_segment = 'PREMIUM';
ELSE
    SET v_segment = 'STANDARD';
END IF;
```

This is useful for procedural decisions.

For a single row-level transformation, however, a normal SQL `CASE` expression is usually simpler:

```sql
CASE
    WHEN total >= 100000 THEN 'VIP'
    WHEN total >= 50000 THEN 'PREMIUM'
    ELSE 'STANDARD'
END
```

Do not use procedural `IF` when a set-based SQL expression solves the problem cleanly.

---

# 8. CASE Inside a Procedure

`CASE` can be used as an expression or as a procedural statement.

For data transformation, the expression form is often preferable:

```sql
SELECT
    customer_id,
    CASE
        WHEN total_spend >= 100000 THEN 'VIP'
        WHEN total_spend >= 50000 THEN 'PREMIUM'
        ELSE 'STANDARD'
    END AS segment
FROM customer_summary;
```

The key distinction is:

```text
CASE expression → calculates a value
IF statement    → controls procedural execution
```

---

# 9. Loops

MySQL procedures support constructs such as `LOOP`, `WHILE`, and `REPEAT`.

Example:

```sql
DELIMITER //

CREATE PROCEDURE generate_numbers(IN p_limit INT)
BEGIN
    DECLARE v_num INT DEFAULT 1;

    number_loop: LOOP
        SELECT v_num;

        SET v_num = v_num + 1;

        IF v_num > p_limit THEN
            LEAVE number_loop;
        END IF;
    END LOOP;
END //

DELIMITER ;
```

### Production warning

A row-by-row loop over millions of records is usually a poor design.

Prefer a set-based statement such as:

```sql
UPDATE employees
SET salary = salary * 1.05
WHERE department_id = 10;
```

instead of looping through every employee and updating them individually.

> [!IMPORTANT]
> **Set-based SQL should normally be your first choice.** Use procedural loops when the problem genuinely requires procedural iteration.

---

# 10. Cursors

A cursor lets a procedure process a result set one row at a time.

Conceptually:

```text
DECLARE cursor
      ↓
OPEN cursor
      ↓
FETCH row
      ↓
process row
      ↓
FETCH next row
      ↓
repeat
      ↓
CLOSE cursor
```

Example skeleton:

```sql
DECLARE done INT DEFAULT FALSE;
DECLARE v_employee_id INT;

DECLARE cur CURSOR FOR
    SELECT employee_id
    FROM employees;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN cur;

read_loop: LOOP
    FETCH cur INTO v_employee_id;

    IF done THEN
        LEAVE read_loop;
    END IF;

    -- process current row
END LOOP;

CLOSE cur;
```

### Why cursors are usually a last resort

Row-by-row processing can be slower and harder to reason about than set-based SQL.

Before using a cursor, ask:

> Can the same requirement be expressed with one `INSERT`, `UPDATE`, `DELETE`, join, aggregation, or other set-based operation?

For MySQL, do not assume cursor-based processing is equivalent to a high-performance ETL engine.

---

# 11. Condition and Error Handling

Procedures can define handlers for conditions.

A common pattern is:

```sql
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    ROLLBACK;
    RESIGNAL;
END;
```

This is useful when a procedure performs a transaction and an error should prevent partial completion.

### Important distinction

```text
CONTINUE HANDLER → handle condition and continue
EXIT HANDLER     → handle condition and leave the block
```

Do not blindly catch errors and ignore them. Suppressing an error can make a failed ETL job appear successful.

---

# 12. Transactions Inside Procedures

A procedure can coordinate multiple DML operations:

```sql
START TRANSACTION;

UPDATE accounts
SET balance = balance - 100
WHERE account_id = 1;

UPDATE accounts
SET balance = balance + 100
WHERE account_id = 2;

COMMIT;
```

A safer pattern includes error handling:

```sql
DECLARE EXIT HANDLER FOR SQLEXCEPTION
BEGIN
    ROLLBACK;
    RESIGNAL;
END;

START TRANSACTION;

-- related changes

COMMIT;
```

The exact transaction boundary should be designed carefully. A procedure that is called from an application transaction can have important interaction with the caller's transaction state.

---

# 13. Result Sets vs OUT Parameters

A procedure can return a result set directly:

```sql
CREATE PROCEDURE get_orders(IN p_customer_id INT)
BEGIN
    SELECT *
    FROM orders
    WHERE customer_id = p_customer_id;
END;
```

It can also return scalar values through `OUT` parameters.

Use a result set when the caller needs rows.

Use an `OUT` parameter when the procedure needs to return a small number of explicit values such as a count, status, or generated identifier.

---

# 14. Procedure vs Function

| Stored Procedure | Stored Function |
|---|---|
| Called with `CALL` | Used in expressions / `SELECT` |
| Can return result sets | Returns one value |
| Supports `IN`, `OUT`, `INOUT` | Parameters are inputs |
| Common for multi-step operations | Common for reusable calculations |
| Can contain transaction/control logic subject to MySQL restrictions | Has additional restrictions on side effects |

Do not choose a function merely because the calculation is reusable. Consider where the calculation belongs and whether it needs database-side execution.

---

# 15. Procedure vs Application / ETL Code

A stored procedure is not automatically the right place for business logic.

### Procedure can make sense when:

- Multiple database operations form one database transaction.
- Logic is tightly coupled to the database.
- A controlled database API is useful.
- The operation is reused by multiple database clients.
- Set-based SQL can perform the work efficiently.

### Pipeline/application code may be better when:

- Logic is complex and easier to test outside the database.
- You need external APIs or files.
- You need Python/Java libraries.
- The workflow is distributed across systems.
- Versioning and CI/CD are easier outside the database.

### Data Engineer interview answer

> I would keep data-intensive, set-based operations close to the database when that improves consistency and performance, but avoid turning stored procedures into large application frameworks. Cross-system orchestration and complex business workflows generally belong in the pipeline/application layer.

---

# 16. Security and SQL SECURITY

Stored routines can have a security context.

The important concepts are:

```text
SQL SECURITY DEFINER
SQL SECURITY INVOKER
```

- `DEFINER` executes using the routine definer's privileges.
- `INVOKER` executes using the caller's privileges.

This matters when a user is allowed to execute a procedure but should not necessarily receive direct access to every underlying table.

Treat privilege design carefully. A procedure should not become an unintended privilege-escalation mechanism.

---

# 17. Deployment and Version Control

Stored procedures are database objects, so they should be treated like code.

A production workflow should consider:

```text
SQL source
   ↓
version control
   ↓
review
   ↓
CI/CD or migration
   ↓
test database
   ↓
production
```

Important concerns:

- Procedure definition changes
- Dependencies on tables/views/functions
- Deployment ordering
- Rollback strategy
- Permissions/definer accounts
- Backward compatibility
- Testing with representative data

Do not make undocumented production edits directly in a database and assume the repository is still authoritative.

---

# 18. Data Engineering Use Cases

### 18.1 Controlled batch operation

A procedure can perform a small, well-defined set of staging-to-target operations atomically.

### 18.2 Data-quality validation

A procedure can calculate validation counts and return a status before a load is committed.

### 18.3 Reusable database operation

Multiple applications can call the same controlled operation instead of duplicating SQL.

### 18.4 Administrative operations

Procedures can encapsulate carefully controlled maintenance operations.

### 18.5 Small database-side transformations

Set-based transformations that are tightly coupled to the MySQL database can sometimes be cleanly packaged as a procedure.

Avoid using procedures as a substitute for a distributed orchestration system.

---

# 19. Idempotency

A procedure used by an ETL pipeline should be designed with retries in mind.

Suppose a pipeline calls:

```sql
CALL load_daily_orders('2026-08-20');
```

If the pipeline retries after a network timeout, the procedure may run again.

Ask:

> Can running the procedure twice create duplicate target data?

Possible strategies include:

- Unique business keys
- Delete-and-reload for a controlled partition
- Staging + deterministic merge logic
- Load-control tables
- Explicit batch identifiers

Transactions provide atomicity, but **transactions do not automatically make a process idempotent**.

---

# 20. Performance: Set-Based First

The most important performance principle is:

```text
Set-based SQL
    >
row-by-row procedural processing
```

for most bulk data operations.

Bad pattern:

```text
fetch row
update row
fetch row
update row
...
```

Better pattern:

```sql
UPDATE orders
SET status = 'ARCHIVED'
WHERE order_date < '2025-01-01';
```

If a procedure processes a large dataset, inspect the SQL statements inside it individually. The procedure itself is not a performance optimization.

---

# 21. Common Mistakes

> [!WARNING]
> These are the mistakes worth remembering for interviews and production work.

1. Forgetting `DELIMITER` while defining multi-statement procedures in the MySQL client.
2. Declaring variables after executable statements.
3. Confusing procedure parameters with local variables.
4. Using a cursor for a problem that can be solved set-wise.
5. Swallowing exceptions instead of propagating them.
6. Assuming a transaction automatically makes a retry safe.
7. Putting complex application orchestration inside the database.
8. Ignoring permissions and the procedure's security context.
9. Deploying procedures manually without version control.
10. Writing procedures that depend on undocumented table structures.
11. Creating extremely large procedures that are difficult to test and maintain.
12. Assuming procedure execution is automatically faster than sending well-designed SQL from the application.

---

# 22. Interview Questions

> [!QUESTION]
>
> ## Interview Follow-up Questions

### Q1. What is a stored procedure?

<details>
<summary><strong>Answer</strong></summary>

A stored procedure is a named database-side program containing SQL statements and optional procedural logic. It can accept parameters and can return result sets or output values.
</details>

### Q2. What is the difference between IN, OUT, and INOUT?

<details>
<summary><strong>Answer</strong></summary>

`IN` passes a value into the procedure, `OUT` returns a value to the caller, and `INOUT` allows the caller's value to be read and then modified.
</details>

### Q3. Why do we use DELIMITER?

<details>
<summary><strong>Answer</strong></summary>

The MySQL client uses `;` to terminate statements. A procedure contains many statements ending in `;`, so a different client delimiter lets the complete procedure definition be submitted as one statement.
</details>

### Q4. Why are cursors usually avoided for large transformations?

<details>
<summary><strong>Answer</strong></summary>

Cursors process rows procedurally. Set-based SQL can usually process a whole set more efficiently and with simpler execution plans.
</details>

### Q5. How would you handle an error after a procedure has started a transaction?

<details>
<summary><strong>Answer</strong></summary>

Use an appropriate exception handler to roll back the transaction and propagate the error rather than silently continuing.
</details>

### Q6. Does a transaction make a stored procedure idempotent?

<details>
<summary><strong>Answer</strong></summary>

No. A transaction provides atomicity for the transaction's work, but executing the same procedure twice can still duplicate or otherwise repeat business effects. Idempotency requires separate design.
</details>

### Q7. When would you choose a stored procedure over Python/Airflow/ETL code?

<details>
<summary><strong>Answer</strong></summary>

When the operation is tightly coupled to the database, benefits from set-based execution and transactional consistency, and is useful as a controlled reusable database operation. Cross-system orchestration generally belongs outside the database.
</details>

### Q8. What is the difference between a procedure and a function?

<details>
<summary><strong>Answer</strong></summary>

A procedure is invoked with `CALL` and can return result sets and output parameters. A function returns a single value and is designed to be used as part of SQL expressions, subject to MySQL routine restrictions.
</details>

### Q9. What should you check before using a cursor?

<details>
<summary><strong>Answer</strong></summary>

First determine whether a set-based `INSERT`, `UPDATE`, `DELETE`, join, aggregation, or other SQL operation can express the requirement. Use a cursor only when row-by-row logic is genuinely necessary.
</details>

### Q10. How should stored procedures be deployed in a production Data Engineering environment?

<details>
<summary><strong>Answer</strong></summary>

Treat them as version-controlled code, review changes, test them in lower environments, manage dependencies and permissions, and deploy through a controlled migration/CI/CD process.
</details>

### Q11. A pipeline calls a procedure and times out. It retries. What risk do you investigate first?

<details>
<summary><strong>Answer</strong></summary>

Investigate whether the procedure is idempotent. The first execution may have committed successfully even though the caller timed out, so a retry could repeat the business operation.
</details>

### Q12. A procedure updates 10 million rows one at a time. How would you improve it?

<details>
<summary><strong>Answer</strong></summary>

Look for a set-based statement that expresses the same transformation. Also inspect indexing, transaction size, locking, and execution plans. The first optimization target is usually eliminating unnecessary row-by-row processing.
</details>

---

# 23. Quick Revision

| Concept | Remember |
|---|---|
| Procedure | Named database-side program |
| `CALL` | Executes a procedure |
| `IN` | Input parameter |
| `OUT` | Output parameter |
| `INOUT` | Input + output |
| `DECLARE` | Declares local variables/conditions/cursors |
| `SET` | Assigns an expression/value |
| `SELECT ... INTO` | Retrieves query values into variables |
| `IF` | Procedural branching |
| `CASE` | Value/conditional expression or procedural case |
| Cursor | Row-by-row result-set processing |
| Handler | Handles conditions/errors |
| `COMMIT` | Makes transaction changes permanent |
| `ROLLBACK` | Undoes transaction changes |
| `DEFINER` | Routine executes with definer security context |
| `INVOKER` | Routine executes with caller's privileges |
| Idempotency | Safe/repeatable effect under retry |
| Set-based SQL | Preferred for bulk transformations |

---

# 24. The Mental Model to Remember

When you see a stored-procedure problem, think in this order:

```text
1. Does this really belong in the database?
             ↓
2. Can it be expressed with set-based SQL?
             ↓
3. What are the transaction boundaries?
             ↓
4. What happens if an error occurs?
             ↓
5. What happens if the caller retries?
             ↓
6. What permissions should the procedure have?
             ↓
7. How will the procedure be tested and deployed?
```

That reasoning is more valuable than memorizing procedural syntax.

---

# 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — practical stored procedure examples
- [`practice.sql`](./practice.sql) — exercises and interview scenarios without solutions
