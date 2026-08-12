# 19 — Set Operators

## 📌 Overview

Set operators combine the results of two or more `SELECT` statements into one result set. They are useful when data comes from different sources or when you need to compare, append, or subtract datasets.

For MySQL and Data Engineering, the important patterns are:

- `UNION`
- `UNION ALL`
- `INTERSECT`
- `EXCEPT`
- `DISTINCT` behavior
- Column compatibility and data types
- Ordering the final combined result
- Duplicate handling
- Set operations for reconciliation and data-quality checks
- Alternatives using `JOIN` or `EXISTS`

> **Core rule:** the participating queries must return the same number of columns, and corresponding columns must be type-compatible.

---

## 🎯 Learning Objectives

By the end of this topic, you should be able to:

- Explain what a set operator does.
- Distinguish `UNION` from `UNION ALL`.
- Use `INTERSECT` to find common rows.
- Use `EXCEPT` to find rows present in one result but not another.
- Understand duplicate elimination.
- Compare schemas before combining result sets.
- Use set operators for source-to-target reconciliation.
- Choose between a set operator, `JOIN`, and `EXISTS`.
- Apply `ORDER BY` and `LIMIT` correctly to combined results.
- Understand practical performance considerations.

---

## 1. UNION

`UNION` combines result sets and removes duplicate rows from the final result.

```sql
SELECT customer_id FROM online_customers
UNION
SELECT customer_id FROM store_customers;
```

Conceptually:

```text
online customers
       +
store customers
       ↓
combined set
       ↓
duplicate rows removed
```

Use `UNION` when the business requirement is a distinct combined set.

---

## 2. UNION ALL

`UNION ALL` appends the result sets without removing duplicates.

```sql
SELECT customer_id FROM online_customers
UNION ALL
SELECT customer_id FROM store_customers;
```

If customer `101` appears in both inputs, it appears twice in the result.

### Why UNION ALL matters

`UNION ALL` is usually preferable when duplicates are meaningful or when you know the inputs are already mutually exclusive. It avoids the duplicate-elimination work performed by `UNION`.

For ETL pipelines, this distinction can materially affect both correctness and performance.

---

## 3. UNION vs UNION ALL

| Feature | `UNION` | `UNION ALL` |
|---|---|---|
| Combines results | Yes | Yes |
| Removes duplicates | Yes | No |
| Preserves duplicate occurrences | No | Yes |
| Usually more work | Yes | Usually less |
| Good for append-only staging | Sometimes | Often |
| Good for distinct entity lists | Yes | No, unless deduplication is done separately |

Do not use `UNION` merely because it is familiar. Decide whether duplicate rows are part of the business meaning.

---

## 4. INTERSECT

`INTERSECT` returns rows present in both result sets.

```sql
SELECT customer_id FROM january_customers
INTERSECT
SELECT customer_id FROM premium_customers;
```

The result represents the common set.

Conceptually:

```text
A ∩ B
```

In current MySQL versions that support these set operations, `INTERSECT` has set semantics and removes duplicate rows from the result.

---

## 5. EXCEPT

`EXCEPT` returns rows from the first query that are not present in the second query.

```sql
SELECT customer_id FROM all_customers
EXCEPT
SELECT customer_id FROM inactive_customers;
```

Conceptually:

```text
A − B
```

This is useful for finding records that exist in a source population but not in another population.

---

## 6. Column Count Must Match

This is invalid:

```sql
SELECT customer_id, customer_name
FROM customers
UNION
SELECT customer_id
FROM archived_customers;
```

The two queries return different numbers of columns.

Correct:

```sql
SELECT customer_id, customer_name
FROM customers
UNION
SELECT customer_id, customer_name
FROM archived_customers;
```

The columns do not need identical names, but their positions must represent compatible values.

---

## 7. Column Order Matters

Set operators combine columns by position, not by column name.

```sql
SELECT customer_id, customer_name
FROM current_customers
UNION ALL
SELECT customer_name, customer_id
FROM archived_customers;
```

This may be syntactically valid if the types are compatible, but the data is semantically wrong because the positions do not represent the same attributes.

Always align the meaning of columns explicitly.

---

## 8. Data Type Compatibility

Corresponding columns should contain compatible data types.

For example:

```sql
SELECT customer_id
FROM current_customers
UNION ALL
SELECT customer_id
FROM archived_customers;
```

is preferable when both IDs use compatible numeric definitions.

Do not rely on implicit conversion between unrelated business types simply because MySQL can evaluate the expression.

---

## 9. Adding a Source Column

A common ETL pattern is to preserve where each record came from.

```sql
SELECT
    customer_id,
    customer_name,
    'ONLINE' AS source_system
FROM online_customers

UNION ALL

SELECT
    customer_id,
    customer_name,
    'STORE' AS source_system
FROM store_customers;
```

Both queries now return the same three-column structure.

This is useful in staging and consolidation pipelines.

---

## 10. ORDER BY with Set Operators

The final ordering normally belongs to the combined result.

```sql
SELECT customer_id, customer_name
FROM online_customers
UNION ALL
SELECT customer_id, customer_name
FROM store_customers
ORDER BY customer_id;
```

Do not assume that each input query's physical order will be preserved in the final result.

If you need a specific order, define it on the final result.

---

## 11. LIMIT with Set Operators

You can limit the final combined result:

```sql
SELECT customer_id FROM online_customers
UNION ALL
SELECT customer_id FROM store_customers
ORDER BY customer_id
LIMIT 100;
```

The important question is whether the limit is intended for:

- Each input query, or
- The final combined set.

If you need to limit each input independently, use derived tables or CTEs so the scope is explicit.

---

## 12. Parentheses and Query Scope

When individual branches contain their own ordering, limiting, or other query clauses, use parentheses/derived queries as required to make the intended scope clear.

For example, if the requirement is:

> Take the top 10 records from each source, then combine them.

Use a structure such as:

```sql
SELECT *
FROM (
    SELECT *
    FROM online_orders
    ORDER BY amount DESC
    LIMIT 10
) online_top

UNION ALL

SELECT *
FROM (
    SELECT *
    FROM store_orders
    ORDER BY amount DESC
    LIMIT 10
) store_top;
```

This is different from applying one `LIMIT 10` after the `UNION ALL`.

---

## 13. Set Operators vs JOIN

These solve different problems.

### Set operator

Use when you want to **stack or compare result sets vertically**.

```text
A
↓
rows
+
B
↓
rows
```

### JOIN

Use when you want to **combine columns horizontally based on a relationship**.

```text
A row + matching B columns
```

Example:

```sql
SELECT c.customer_id, c.customer_name, o.order_id
FROM customers c
JOIN orders o
  ON o.customer_id = c.customer_id;
```

Do not replace a vertical append with a JOIN merely because both tables contain related data.

---

## 14. Set Operators vs EXISTS

`EXISTS` answers an existence question:

> Does a matching row exist?

```sql
SELECT c.customer_id
FROM customers c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
);
```

`INTERSECT` can express a common-set operation:

```sql
SELECT customer_id FROM customers
INTERSECT
SELECT customer_id FROM orders;
```

The choice depends on whether the requirement is naturally row-set comparison or existence filtering.

---

## 15. Data Engineering — Source Consolidation

Suppose two operational systems produce customer records with the same logical structure.

```sql
SELECT customer_id, name, email, 'CRM_A' AS source
FROM crm_a_customers

UNION ALL

SELECT customer_id, name, email, 'CRM_B' AS source
FROM crm_b_customers;
```

This creates a consolidated staging result while retaining source lineage.

Before using this pattern, confirm whether duplicate customers across systems should remain separate, be reconciled, or be deduplicated later.

---

## 16. Source-to-Target Reconciliation with EXCEPT

A powerful validation pattern is to compare business keys.

Source-only records:

```sql
SELECT customer_id
FROM source_customers
EXCEPT
SELECT customer_id
FROM target_customers;
```

Target-only records:

```sql
SELECT customer_id
FROM target_customers
EXCEPT
SELECT customer_id
FROM source_customers;
```

Together, these answer two different questions:

```text
Source − Target → missing in target
Target − Source → unexpected in target
```

For a complete reconciliation, also compare counts and important measures where appropriate.

---

## 17. Comparing Full Rows

Set operators can compare multiple columns at once.

```sql
SELECT customer_id, name, email
FROM source_customers
EXCEPT
SELECT customer_id, name, email
FROM target_customers;
```

This can identify rows where the complete selected tuple exists in the source but not in the target.

Be careful with `NULL` semantics and with columns that should not be compared directly, such as load timestamps or system-generated identifiers.

---

## 18. UNION for Data Quality Exceptions

You can combine different exception populations into one result.

```sql
SELECT customer_id, 'MISSING_EMAIL' AS issue
FROM customers
WHERE email IS NULL

UNION ALL

SELECT customer_id, 'INVALID_STATUS' AS issue
FROM customers
WHERE status NOT IN ('ACTIVE', 'INACTIVE');
```

This produces a single exception stream while preserving multiple issue rows for the same customer when necessary.

---

## 19. Duplicate Semantics Matter

Consider:

```text
A = 101, 101, 102
B = 102, 103
```

Then:

```text
A UNION B
→ 101, 102, 103

A UNION ALL B
→ 101, 101, 102, 102, 103

A INTERSECT B
→ 102

A EXCEPT B
→ 101
```

This illustrates why choosing the operator is a business decision, not just a syntax decision.

---

## 20. Performance Considerations

### Prefer UNION ALL when deduplication is not required

`UNION` must eliminate duplicates. That can require additional sorting or hashing work depending on the execution plan.

### Reduce data before combining

If possible, filter and project only required columns before the set operation.

```sql
SELECT customer_id
FROM orders
WHERE order_date >= '2026-01-01'

UNION ALL

SELECT customer_id
FROM archived_orders
WHERE order_date >= '2026-01-01';
```

### Avoid unnecessary wide rows

Set operations compare/transfer all selected columns. Select only the attributes needed for the operation.

### Use EXPLAIN

For large workloads, inspect the execution plan rather than assuming a set operation is cheap.

---

## 21. Common Mistakes

### Mistake 1 — Using UNION when duplicates are meaningful

Use `UNION ALL` for true append semantics.

### Mistake 2 — Assuming column names are matched

Set operators match columns by position.

### Mistake 3 — Mixing incompatible business meanings

Matching data types do not guarantee matching semantics.

### Mistake 4 — Applying LIMIT at the wrong level

A final limit is different from limiting each input branch.

### Mistake 5 — Using JOIN when the requirement is vertical combination

Choose the operation based on the shape of the required result.

### Mistake 6 — Forgetting source lineage

When consolidating multiple systems, preserve source information when it is needed for auditability.

### Mistake 7 — Treating EXCEPT as a complete reconciliation

A source-only check does not identify target-only records. Perform both directions when required.

---

## 🎤 Interview-Focused Questions

### Q1. What is the difference between UNION and UNION ALL?

<details>
<summary><strong>Answer</strong></summary>

Both combine result sets vertically. `UNION` removes duplicate rows from the final result, while `UNION ALL` preserves every row. `UNION ALL` is generally more efficient when deduplication is not required.

</details>

### Q2. What requirements must two queries satisfy for UNION?

<details>
<summary><strong>Answer</strong></summary>

They must return the same number of columns, and corresponding columns should be type-compatible and represent compatible business meanings. Columns are matched by position, not by name.

</details>

### Q3. When would you use UNION ALL in a Data Engineering pipeline?

<details>
<summary><strong>Answer</strong></summary>

Use it when appending rows from multiple sources or partitions and duplicate occurrences are valid or are handled separately. It avoids unnecessary duplicate elimination.

</details>

### Q4. How would you find records present in source but missing from target?

<details>
<summary><strong>Answer</strong></summary>

Select the business key from the source and subtract the target set:

```sql
SELECT customer_id FROM source_customers
EXCEPT
SELECT customer_id FROM target_customers;
```

</details>

### Q5. How would you find target-only records?

<details>
<summary><strong>Answer</strong></summary>

Reverse the operation:

```sql
SELECT customer_id FROM target_customers
EXCEPT
SELECT customer_id FROM source_customers;
```

</details>

### Q6. What is the difference between a JOIN and UNION?

<details>
<summary><strong>Answer</strong></summary>

A JOIN combines related rows horizontally and adds columns. UNION combines compatible result sets vertically and adds rows.

</details>

### Q7. Why might UNION be slower than UNION ALL?

<details>
<summary><strong>Answer</strong></summary>

`UNION` must remove duplicate rows from the combined result. That requires additional processing that `UNION ALL` does not need.

</details>

### Q8. Can two UNION queries have different column names?

<details>
<summary><strong>Answer</strong></summary>

Yes, but the columns are combined by position. The final column names generally come from the first SELECT, so both queries should still use matching business meanings by position.

</details>

### Q9. How would you combine customer data from two source systems while preserving lineage?

<details>
<summary><strong>Answer</strong></summary>

Use `UNION ALL` and add a literal source column in each branch:

```sql
SELECT customer_id, name, 'CRM_A' AS source
FROM crm_a_customers
UNION ALL
SELECT customer_id, name, 'CRM_B' AS source
FROM crm_b_customers;
```

</details>

### Q10. How would you find common customers between two datasets?

<details>
<summary><strong>Answer</strong></summary>

Use `INTERSECT` when set intersection expresses the requirement directly:

```sql
SELECT customer_id FROM source_a
INTERSECT
SELECT customer_id FROM source_b;
```

A JOIN or EXISTS can also express the requirement, depending on the broader query.

</details>

### Q11. How can UNION be used for data-quality exceptions?

<details>
<summary><strong>Answer</strong></summary>

Create separate exception queries with a common schema and combine them with `UNION ALL`, for example missing email records plus invalid-status records. This creates a single exception stream while retaining the issue type.

</details>

### Q12. How do you limit each branch before UNION ALL?

<details>
<summary><strong>Answer</strong></summary>

Put each branch in a derived table or CTE and apply its own `ORDER BY` and `LIMIT`. A single `LIMIT` after the set operator applies to the combined result, not independently to each branch.

</details>

### Q13. Is a source-minus-target comparison enough for reconciliation?

<details>
<summary><strong>Answer</strong></summary>

No. It identifies source-only records but misses target-only records. A stronger reconciliation checks both directions and may also compare counts, totals, and other business metrics.

</details>

### Q14. What happens to duplicates with INTERSECT and EXCEPT?

<details>
<summary><strong>Answer</strong></summary>

These set operations use set semantics, so duplicate occurrences are not preserved in the ordinary result. If duplicate-level comparison is required, another strategy may be necessary.

</details>

### Q15. What should you consider before using a set operator for large datasets?

<details>
<summary><strong>Answer</strong></summary>

Consider row volume, duplicate elimination, selected column width, filtering before the operation, indexes and execution plans, and whether `UNION ALL` can satisfy the requirement without unnecessary deduplication.

</details>

---

## 🔄 Quick Revision

| Operator | Purpose |
|---|---|
| `UNION` | Combine results and remove duplicates |
| `UNION ALL` | Combine results and preserve duplicates |
| `INTERSECT` | Rows common to both sets |
| `EXCEPT` | Rows in first set but not second |
| `JOIN` | Combine columns horizontally |
| `EXISTS` | Test whether a matching row exists |

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — practical set-operator examples and reconciliation patterns
- [`practice.sql`](./practice.sql) — interview-focused exercises without answers
