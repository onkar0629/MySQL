# 17 — Subqueries

## 📌 Overview

A **subquery** is a query nested inside another SQL statement. Subqueries are useful when one query needs the result of another query as an input.

For Data Engineering, the important skill is not memorizing subquery syntax. It is knowing **when a subquery is the clearest and safest solution**, understanding its cardinality, NULL behavior, and knowing when a JOIN or CTE is a better design.

---

## 🎯 Learning Objectives

By the end of this topic, you should be able to:

- Write scalar, single-row, multi-row, and correlated subqueries.
- Use subqueries in `WHERE`, `SELECT`, and `FROM`.
- Use `IN`, `NOT IN`, `EXISTS`, and `NOT EXISTS` correctly.
- Understand correlated vs non-correlated subqueries.
- Use derived tables for multi-step transformations.
- Understand subquery cardinality errors.
- Handle NULL safely in subquery predicates.
- Compare subqueries with JOINs and CTEs.
- Recognize performance problems caused by correlated subqueries.
- Apply subqueries to real Data Engineering scenarios.

---

## 🧠 1. Basic Subquery

A subquery is enclosed in parentheses and produces a result consumed by the outer query.

Example: employees earning more than the company average:

```sql
SELECT
    employee_id,
    employee_name,
    salary
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
);
```

The inner query calculates the average salary. The outer query compares each employee against that value.

Conceptually:

```text
Inner query
    ↓
average salary
    ↓
Outer query
    ↓
employees above average
```

---

## 🔹 2. Non-Correlated Subquery

A non-correlated subquery can execute independently of the outer query.

```sql
SELECT *
FROM products
WHERE price > (
    SELECT AVG(price)
    FROM products
);
```

The inner query does not reference a column from the outer query.

This is generally easier for the optimizer to handle than a correlated subquery, although the actual execution strategy depends on MySQL's optimizer.

---

## 🔁 3. Correlated Subquery

A correlated subquery references a value from the outer query.

Example: employees earning more than their own department's average:

```sql
SELECT
    e.employee_id,
    e.employee_name,
    e.department_id,
    e.salary
FROM employees e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id
);
```

The inner query depends on the current outer employee's department.

Conceptually:

```text
Outer employee
      ↓
Find that employee's department average
      ↓
Compare salary
      ↓
Next employee
```

Correlated subqueries are powerful, but they deserve performance scrutiny on large datasets.

---

## 🔢 4. Scalar Subquery

A scalar subquery returns **at most one value** for the context where it is used.

Example:

```sql
SELECT
    employee_name,
    salary,
    salary - (
        SELECT AVG(salary)
        FROM employees
    ) AS difference_from_average
FROM employees;
```

The inner query produces one aggregate value.

### Important rule

If a scalar subquery returns more than one row, MySQL raises an error.

For example, this can fail:

```sql
WHERE salary = (
    SELECT salary
    FROM employees
    WHERE department_id = 10
)
```

if department 10 has multiple employees.

Use `IN`, `EXISTS`, aggregation, or another appropriate strategy when multiple rows are possible.

---

## 📋 5. Single-Row Subquery with Comparison Operators

A subquery returning one value can be compared using:

```text
=
<>
>
<
>=
<=
```

Example:

```sql
SELECT *
FROM products
WHERE price > (
    SELECT AVG(price)
    FROM products
);
```

The important question is always:

> **Can the subquery return exactly one value?**

If not, the operator may be inappropriate.

---

## 📚 6. Multi-Row Subquery with IN

`IN` is appropriate when the subquery returns multiple values.

Example: customers who have placed an order:

```sql
SELECT
    customer_id,
    customer_name
FROM customers
WHERE customer_id IN (
    SELECT customer_id
    FROM orders
);
```

The inner query produces a set of customer IDs, and the outer query checks membership in that set.

---

## 🚫 7. NOT IN and NULL — Critical Interview Concept

Consider:

```sql
SELECT customer_id
FROM customers
WHERE customer_id NOT IN (
    SELECT customer_id
    FROM orders
);
```

If the subquery contains `NULL`, the `NOT IN` predicate can evaluate to UNKNOWN and produce unexpected results.

A safer anti-join pattern is often:

```sql
SELECT c.customer_id
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);
```

This is one of the most important differences between `NOT IN` and `NOT EXISTS`.

---

## ✅ 8. EXISTS

`EXISTS` checks whether the subquery produces at least one row.

Example:

```sql
SELECT
    c.customer_id,
    c.customer_name
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);
```

The actual selected value inside `EXISTS` is irrelevant. This is why:

```sql
SELECT 1
```

is commonly used.

The question is simply:

> Does a matching row exist?

---

## ❌ 9. NOT EXISTS

`NOT EXISTS` checks that no matching row exists.

Example: customers without orders:

```sql
SELECT
    c.customer_id,
    c.customer_name
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);
```

This is a reliable anti-join pattern and avoids the NULL trap associated with `NOT IN`.

---

## ⚖️ 10. EXISTS vs IN

Both can express membership, but they communicate different intent.

### IN

```sql
WHERE customer_id IN (
    SELECT customer_id
    FROM orders
)
```

Think:

> Is this value present in the returned set?

### EXISTS

```sql
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
)
```

Think:

> Does at least one related row exist?

For correlated existence checks, `EXISTS` is often the clearer expression of the requirement.

Do not assume one is universally faster. MySQL can transform subqueries, and actual performance depends on data distribution, indexes, and the execution plan.

---

## 🏗️ 11. Subquery in FROM — Derived Table

A subquery in `FROM` is a **derived table** and must have an alias.

Example: calculate customer totals first, then filter them:

```sql
SELECT
    customer_id,
    total_spend
FROM (
    SELECT
        customer_id,
        SUM(amount) AS total_spend
    FROM orders
    GROUP BY customer_id
) AS customer_totals
WHERE total_spend > 100000;
```

This is useful when a transformation needs to happen in stages.

Conceptually:

```text
orders
  ↓
aggregate by customer
  ↓
customer_totals
  ↓
filter totals
```

---

## 🧮 12. Subquery in SELECT

A scalar subquery can appear in the `SELECT` list.

```sql
SELECT
    e.employee_id,
    e.employee_name,
    (
        SELECT AVG(e2.salary)
        FROM employees e2
    ) AS company_avg_salary
FROM employees e;
```

This can be useful for a single shared scalar value, but repeated row-dependent scalar subqueries should be reviewed carefully for performance and readability.

---

## 🧠 13. Subquery Cardinality

**Cardinality** means how many rows a subquery can return.

| Subquery type | Expected result |
|---|---|
| Scalar | One value |
| Single-row | One row |
| Multi-row | Multiple rows possible |
| `EXISTS` | Only existence matters |
| Derived table | A relation/table result |

Always choose the operator based on the expected cardinality.

For example:

```sql
WHERE department_id = (
    SELECT department_id
    FROM employees
    WHERE employee_id = 101
)
```

is valid if `employee_id` uniquely identifies one employee.

If the inner query can return several department IDs, use an appropriate multi-row operator such as `IN`.

---

## 🔗 14. Subquery vs JOIN

Many subqueries can be rewritten as joins.

Subquery:

```sql
SELECT c.customer_id
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);
```

Equivalent inner join for this existence requirement:

```sql
SELECT DISTINCT c.customer_id
FROM customers c
JOIN orders o
    ON o.customer_id = c.customer_id;
```

But the two queries express different concepts:

```text
EXISTS → Does a related row exist?
JOIN   → Combine rows from relations
```

A JOIN can multiply rows, while `EXISTS` does not multiply the outer result merely because several matching rows exist.

---

## 🧠 15. Subquery vs CTE

A CTE can make a multi-step query easier to read.

Subquery:

```sql
SELECT *
FROM (
    SELECT customer_id, SUM(amount) AS total_spend
    FROM orders
    GROUP BY customer_id
) AS x
WHERE total_spend > 100000;
```

CTE:

```sql
WITH customer_totals AS (
    SELECT
        customer_id,
        SUM(amount) AS total_spend
    FROM orders
    GROUP BY customer_id
)
SELECT *
FROM customer_totals
WHERE total_spend > 100000;
```

The CTE often communicates the intermediate result more clearly, especially when several stages are involved.

Do not assume CTEs are automatically faster or slower; evaluate the actual query plan and MySQL version/optimizer behavior.

---

## 🎯 16. Finding Above-Group-Average Records

A common interview problem is:

> Find employees whose salary is above their department average.

Using a correlated subquery:

```sql
SELECT
    e.employee_id,
    e.employee_name,
    e.department_id,
    e.salary
FROM employees e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id
);
```

This is a valid solution and demonstrates correlated subqueries clearly.

For large datasets, a pre-aggregation approach may be easier to optimize:

```sql
SELECT
    e.employee_id,
    e.employee_name,
    e.department_id,
    e.salary
FROM employees e
JOIN (
    SELECT
        department_id,
        AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
) d
    ON d.department_id = e.department_id
WHERE e.salary > d.avg_salary;
```

The important interview skill is being able to explain both approaches and their trade-offs.

---

## 🔍 17. Finding Duplicate Business Keys

A grouped subquery can identify duplicate keys and then return the actual records.

```sql
SELECT *
FROM customers c
WHERE c.email IN (
    SELECT email
    FROM customers
    WHERE email IS NOT NULL
    GROUP BY email
    HAVING COUNT(*) > 1
);
```

This is useful when the requirement is:

1. Identify duplicate values.
2. Retrieve the full records belonging to those duplicate values.

For large tables, other approaches such as window functions may be clearer and more flexible.

---

## 🧪 18. Data Engineering — Source/Target Existence Checks

Suppose a pipeline loads source orders into a warehouse.

Find source records missing from the target:

```sql
SELECT s.order_id
FROM source_orders s
WHERE NOT EXISTS (
    SELECT 1
    FROM target_orders t
    WHERE t.order_id = s.order_id
);
```

This is a practical reconciliation pattern.

The same pattern can be used for:

- Missing records
- Referential checks
- CDC validation
- Migration validation
- Incremental-load verification

---

## 🧱 19. Nested Subqueries

Subqueries can be nested, although excessive nesting can reduce readability.

Example:

```sql
SELECT *
FROM employees
WHERE salary > (
    SELECT AVG(salary)
    FROM employees
    WHERE department_id IN (
        SELECT department_id
        FROM departments
        WHERE region = 'WEST'
    )
);
```

If a query becomes difficult to understand, consider a CTE or staged transformation instead.

The goal is not to minimize the number of SQL clauses; the goal is to make the data logic correct and maintainable.

---

## ⚠️ 20. Correlated Subquery Performance

A correlated subquery can be conceptually evaluated for each outer row, although the optimizer may transform it into another execution strategy.

For a large dataset:

```text
Millions of outer rows
        ↓
correlated calculation
        ↓
potentially expensive workload
```

Before using a correlated subquery in production:

- Check indexes on correlation columns.
- Inspect `EXPLAIN`.
- Compare with a pre-aggregated JOIN or CTE.
- Test using realistic data volume.

Never claim that a correlated subquery always executes literally once per outer row; MySQL's optimizer can rewrite queries.

---

## ⚡ 21. Performance and Indexing

Subquery performance depends on the query shape and execution plan.

Useful considerations:

- Index correlated lookup columns.
- Index primary/unique keys used for existence checks.
- Avoid returning unnecessary columns from derived tables.
- Pre-aggregate large many-side datasets before joining when appropriate.
- Use `EXPLAIN` to inspect access paths.
- Check whether MySQL transforms `IN`, `EXISTS`, or other subqueries into semijoin/antijoin strategies.
- Test with production-like cardinality and data distribution.

Example correlation:

```sql
WHERE o.customer_id = c.customer_id
```

An index on `orders.customer_id` can be important for this lookup pattern.

---

## 🧠 22. Practical Decision Guide

Use a **scalar subquery** when:

```text
You need one value
```

Use **IN** when:

```text
You need membership in a set
```

Use **EXISTS** when:

```text
You only care whether a related row exists
```

Use **NOT EXISTS** when:

```text
You need rows with no related match
```

Use a **derived table** when:

```text
You need an intermediate relation in FROM
```

Use a **CTE** when:

```text
A multi-step transformation benefits from named stages
```

Use a **JOIN** when:

```text
You need to combine columns/rows from related relations
```

The best solution depends on semantics, readability, cardinality, and performance.

---

## ⚠️ 23. Common Mistakes

- Using `=` when a subquery can return multiple rows.
- Using `NOT IN` when the subquery can contain NULL.
- Correlating on the wrong column.
- Forgetting that a JOIN can multiply rows while `EXISTS` does not.
- Assuming a correlated subquery always executes once per outer row.
- Assuming `IN` or `EXISTS` is universally faster.
- Returning unnecessary columns from a derived table.
- Ignoring indexes on correlation keys.
- Using deeply nested subqueries when a CTE is clearer.
- Failing to verify the execution plan on large data.

---

## 🎤 24. Interview-Focused Questions

### Q1. What is a subquery?

<details>
<summary><strong>Answer</strong></summary>

A subquery is a query nested inside another SQL statement. Its result is used by the outer query as a value, set of values, derived table, or existence condition.

</details>

### Q2. What is the difference between correlated and non-correlated subqueries?

<details>
<summary><strong>Answer</strong></summary>

A non-correlated subquery can execute independently of the outer query. A correlated subquery references columns from the outer query and therefore depends on the current outer row or context.

</details>

### Q3. When would you use a scalar subquery?

<details>
<summary><strong>Answer</strong></summary>

Use it when the subquery is expected to return one value, such as the company-wide average salary. If it returns multiple rows in a scalar context, MySQL raises an error.

</details>

### Q4. What is the difference between IN and EXISTS?

<details>
<summary><strong>Answer</strong></summary>

`IN` checks whether a value belongs to the result set of a subquery. `EXISTS` checks whether at least one matching row exists. `EXISTS` is especially natural for correlated existence checks.

</details>

### Q5. Why is NOT EXISTS often safer than NOT IN?

<details>
<summary><strong>Answer</strong></summary>

`NOT IN` can produce unexpected results when its subquery contains NULL because of SQL's three-valued logic. `NOT EXISTS` evaluates the correlated existence condition without that particular NULL-list problem.

</details>

### Q6. How would you find customers who have never placed an order?

<details>
<summary><strong>Answer</strong></summary>

Use `NOT EXISTS`:

```sql
SELECT c.customer_id
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);
```

</details>

### Q7. What happens if a scalar subquery returns multiple rows?

<details>
<summary><strong>Answer</strong></summary>

MySQL raises an error because the scalar context expects one value. Use an operator appropriate for multiple rows, such as `IN`, or change the subquery so it deterministically returns one value.

</details>

### Q8. How would you find employees earning above their department average?

<details>
<summary><strong>Answer</strong></summary>

A correlated subquery can compare each employee's salary with the average for that employee's department:

```sql
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.department_id = e.department_id
)
```

A pre-aggregated JOIN is another strong solution for large datasets.

</details>

### Q9. How can a subquery be used to find duplicate records?

<details>
<summary><strong>Answer</strong></summary>

First identify duplicate business keys using `GROUP BY ... HAVING COUNT(*) > 1`, then use the resulting keys in an outer query to retrieve the complete duplicate records.

</details>

### Q10. What is a derived table?

<details>
<summary><strong>Answer</strong></summary>

A derived table is a subquery used in the `FROM` clause. It behaves as an intermediate result relation and must have an alias.

</details>

### Q11. When would you prefer a CTE over a subquery?

<details>
<summary><strong>Answer</strong></summary>

Prefer a CTE when naming intermediate stages improves readability, when multiple query stages need to be expressed clearly, or when the same logical intermediate result is referenced in a way that benefits from explicit structure. Performance should be verified rather than assumed.

</details>

### Q12. Can every subquery be replaced by a JOIN?

<details>
<summary><strong>Answer</strong></summary>

Many can, but the semantics may change. A JOIN combines rows and can multiply them, while `EXISTS` only tests whether a match exists. Choose the construct that represents the business requirement and validate the resulting grain.

</details>

### Q13. What is the biggest performance concern with correlated subqueries?

<details>
<summary><strong>Answer</strong></summary>

They can become expensive when the outer result is large and the correlated lookup is costly. Check indexes and `EXPLAIN`, and compare against pre-aggregation plus JOIN or a CTE where appropriate.

</details>

### Q14. How would you validate that every source order exists in the target?

<details>
<summary><strong>Answer</strong></summary>

Use an anti-existence query:

```sql
SELECT s.order_id
FROM source_orders s
WHERE NOT EXISTS (
    SELECT 1
    FROM target_orders t
    WHERE t.order_id = s.order_id
);
```

An empty result means no missing source keys were found under the selected conditions.

</details>

### Q15. Why should you understand subquery cardinality?

<details>
<summary><strong>Answer</strong></summary>

The expected number of rows determines which operator is valid. `=` requires a scalar/single value, `IN` accepts multiple values, and `EXISTS` only cares whether a row exists. Incorrect cardinality assumptions cause errors or incorrect results.

</details>

---

## 🔄 Quick Revision

| Concept | Key Point |
|---|---|
| Scalar subquery | Produces one value |
| Non-correlated | Independent of outer row |
| Correlated | References outer query |
| `IN` | Membership in a set |
| `EXISTS` | At least one match exists |
| `NOT EXISTS` | No matching row exists |
| Derived table | Subquery in `FROM` |
| Cardinality | Expected number of rows/values |
| `NOT IN` + NULL | Potentially unsafe |
| Subquery vs JOIN | Different semantics and row behavior |
| CTE | Named intermediate query stage |
| `EXPLAIN` | Validate execution strategy |

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — practical subquery patterns
- [`practice.sql`](./practice.sql) — hands-on exercises and interview scenarios
