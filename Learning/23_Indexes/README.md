# 23 — Indexes

> [!NOTE]
> Indexes are one of the most important MySQL performance topics for a Data Engineer. The goal is not to memorize index syntax; it is to understand **what an index helps, when it does not help, how composite indexes work, and how to verify the optimizer's choice**.

## What You Should Be Able to Recall

After revisiting this topic months later, you should be able to explain:

- Why indexes exist
- How a B-tree index changes data access
- Clustered vs secondary indexes in InnoDB
- Primary-key and secondary-index behavior
- Single-column vs composite indexes
- Composite index column order
- The leftmost-prefix idea
- Equality, range, and sorting patterns
- Covering indexes
- Selectivity/cardinality
- Why `SELECT *` can make an index less useful
- Why functions on indexed columns can prevent efficient index access
- Why leading-wildcard `LIKE` searches are problematic
- How indexes affect `INSERT`, `UPDATE`, and `DELETE`
- How to inspect indexes
- How to use `EXPLAIN`
- How to reason about `EXPLAIN` output
- Why an optimizer may choose a table scan
- Index design for joins, filters, and ordering
- Common Data Engineering index patterns
- When not to add an index

---

# 1. What Is an Index?

An index is a data structure that helps MySQL locate rows without examining every row in the table.

Without a useful index, a query may need to inspect many rows:

```text
Table
 ↓
read many/all rows
 ↓
check condition
 ↓
return matches
```

With a useful index:

```text
Query predicate
      ↓
   Index
      ↓
locate relevant entries
      ↓
fetch required rows
```

The important idea is **fewer rows/pages examined**, not simply "indexes make queries fast."

---

# 2. Why Indexes Exist

Suppose a table contains 10 million orders:

```sql
SELECT *
FROM orders
WHERE customer_id = 501;
```

If `customer_id` has no suitable index, MySQL may need to inspect a large portion of the table.

With:

```sql
CREATE INDEX idx_orders_customer
ON orders(customer_id);
```

MySQL can use the index to find entries for customer `501` and then access the corresponding rows.

The actual plan must still be verified with `EXPLAIN`.

---

# 3. The Trade-off

Indexes are not free.

They can improve reads but increase write and storage costs:

```text
             Index
               ↓
        ┌──────┴──────┐
        ↓             ↓
   faster reads    write/storage cost
```

When a row is inserted or an indexed value changes, the relevant index structures must also be maintained.

Therefore:

> Do not create an index just because a column appears in a query.

Create indexes based on real access patterns and verify their usefulness.

---

# 4. InnoDB and the Primary Key

For InnoDB, the primary key is the clustered index.

Conceptually:

```text
Primary-key index
      ↓
contains the row data
```

Secondary indexes contain their indexed columns plus the primary-key value used to locate the row in the clustered index.

This is important when thinking about the cost of a secondary-index lookup that is not covering.

### Practical consequence

A large primary key can increase the size of secondary indexes because the primary-key value is stored with secondary-index entries.

For transactional tables, choose primary keys carefully.

---

# 5. Primary Key vs Secondary Index

```sql
CREATE TABLE customers (
    customer_id BIGINT PRIMARY KEY,
    email VARCHAR(255),
    status VARCHAR(20)
);
```

The primary key already has an index.

If you frequently search by email:

```sql
CREATE INDEX idx_customers_email
ON customers(email);
```

You do **not** need to create another index on `customer_id` just because you query it; the primary key already provides one.

---

# 6. Unique Index

A unique index provides an indexing structure plus a uniqueness rule.

```sql
CREATE UNIQUE INDEX ux_customers_email
ON customers(email);
```

A unique index is useful when the business rule is:

```text
one email → one customer
```

If the column can contain `NULL`, remember that MySQL's handling of multiple `NULL` values is different from ordinary duplicate non-NULL values.

---

# 7. Composite Index

A composite index contains multiple columns:

```sql
CREATE INDEX idx_orders_customer_date
ON orders(customer_id, order_date);
```

This is **not** equivalent to two unrelated indexes.

The order matters.

Think of it approximately as:

```text
(customer_id, order_date)
       ↓
customer 501
   ├── date 2026-01-01
   ├── date 2026-01-05
   └── date 2026-02-01
customer 502
   ├── date 2026-01-02
   └── date 2026-02-10
```

The first column organizes the primary search path; the following column helps within that organization.

---

# 8. Leftmost Prefix

For:

```sql
CREATE INDEX idx_orders_customer_date
ON orders(customer_id, order_date);
```

The index is naturally useful for access patterns beginning with `customer_id`.

For example:

```sql
WHERE customer_id = 501
```

and:

```sql
WHERE customer_id = 501
  AND order_date >= '2026-08-01'
```

can use the composite structure effectively.

But an independent query such as:

```sql
WHERE order_date >= '2026-08-01'
```

cannot generally use the same index as efficiently because it skips the leading indexed column.

This is the **leftmost-prefix principle**.

---

# 9. Choosing Composite Index Column Order

There is no universal rule such as "put the most selective column first."

Design the index around the actual query workload.

Suppose the common query is:

```sql
SELECT order_id, order_date, amount
FROM orders
WHERE customer_id = ?
  AND order_date >= ?
ORDER BY order_date;
```

A candidate index is:

```sql
CREATE INDEX idx_orders_customer_date
ON orders(customer_id, order_date);
```

The equality predicate on `customer_id` followed by the range/order column is a natural match for this workload.

For a different workload, the optimal order can be different.

> [!TIP]
> Think in terms of **query shape**, not a memorized index formula.

---

# 10. Equality and Range Predicates

A common pattern is:

```sql
WHERE customer_id = 501
  AND order_date >= '2026-08-01'
```

An index beginning with `customer_id, order_date` can support this access pattern well.

A range condition often changes how later index columns can contribute to efficient range access. Do not assume every later column automatically gives the same benefit after a range predicate.

Use `EXPLAIN` to verify the real plan.

---

# 11. Indexes for JOINs

Suppose:

```sql
SELECT
    o.order_id,
    c.customer_name
FROM orders o
JOIN customers c
    ON c.customer_id = o.customer_id;
```

`customer_id` is already indexed if it is the primary key of `customers`.

If the join/access pattern frequently requires another table's foreign-key column to be searched, an index on that foreign key can be important.

Example:

```sql
CREATE INDEX idx_orders_customer
ON orders(customer_id);
```

Do not index every foreign key automatically; evaluate the actual workload and constraints.

---

# 12. Indexes for ORDER BY

An index can sometimes help avoid an expensive sort when its ordering matches the query and other conditions allow the optimizer to use that order.

Example:

```sql
CREATE INDEX idx_orders_customer_date
ON orders(customer_id, order_date);
```

Query:

```sql
WHERE customer_id = 501
ORDER BY order_date;
```

The index order can align with the requested ordering.

But an index is not automatically a guarantee that MySQL will avoid sorting.

---

# 13. Indexes for GROUP BY

Indexes can sometimes help grouping by reducing the amount of work required to locate or order grouped values.

For example:

```sql
CREATE INDEX idx_orders_customer
ON orders(customer_id);
```

may be relevant to:

```sql
SELECT customer_id, COUNT(*)
FROM orders
GROUP BY customer_id;
```

Whether it actually improves the query depends on table size, distribution, selected columns, optimizer estimates, and the execution plan.

---

# 14. Covering Index

A covering index contains everything the query needs from the indexed table.

Suppose:

```sql
SELECT customer_id, order_date, amount
FROM orders
WHERE customer_id = 501;
```

A candidate covering index could be:

```sql
CREATE INDEX idx_orders_customer_date_amount
ON orders(customer_id, order_date, amount);
```

If the optimizer can satisfy the query from the index alone, it may avoid additional table-row lookups.

This can be useful for read-heavy workloads, but wider indexes consume more storage and increase write cost.

> [!WARNING]
> Do not turn every index into a huge covering index. The additional columns have a cost.

---

# 15. Selectivity and Cardinality

**Selectivity** describes how effectively a predicate narrows the rows.

A unique email usually has high selectivity:

```text
10 million rows
→ perhaps 1 matching row
```

A boolean status such as:

```text
ACTIVE / INACTIVE
```

may have low selectivity:

```text
10 million rows
→ 7 million ACTIVE
```

An index on a low-selectivity column is not automatically useless, but the optimizer may decide that scanning the table is cheaper.

### Important

High cardinality is generally favorable for equality lookups, but **index usefulness depends on the complete query and data distribution**, not cardinality alone.

---

# 16. Why MySQL May Ignore an Index

A common interview question is:

> "I created an index, but MySQL still performs a table scan. Why?"

Possible reasons include:

- The predicate is not selective enough.
- The table is small.
- The optimizer estimates a scan is cheaper.
- Statistics are stale or estimates are inaccurate.
- The query cannot use the index efficiently.
- A function/expression changes the searchable form.
- A leading wildcard prevents normal B-tree lookup.
- The index ordering does not match the query shape.
- Another index is estimated to be better.
- The query needs a large percentage of the table anyway.

The answer should be **"check the execution plan," not "force the index."**

---

# 17. EXPLAIN

Start with:

```sql
EXPLAIN
SELECT *
FROM orders
WHERE customer_id = 501;
```

For more detail in modern MySQL:

```sql
EXPLAIN ANALYZE
SELECT *
FROM orders
WHERE customer_id = 501;
```

`EXPLAIN` describes the optimizer's planned execution. `EXPLAIN ANALYZE` executes the statement and provides actual execution information, so use it carefully on production systems.

---

# 18. Important EXPLAIN Columns

Useful columns include:

| Column | Why it matters |
|---|---|
| `table` | Table being accessed |
| `type` | Access method classification |
| `possible_keys` | Candidate indexes considered |
| `key` | Index selected by the optimizer |
| `key_len` | Portion of the index considered |
| `rows` | Estimated rows examined |
| `filtered` | Estimated filtering percentage |
| `Extra` | Additional execution information |

Do not judge a query from one column alone.

---

# 19. `type` in EXPLAIN

Common access types include:

```text
const
ref
range
index
ALL
```

Generally, a selective indexed lookup such as `const`, `ref`, or `range` can be much better than a full scan (`ALL`), but the context matters.

For example, a full scan of a tiny table may be completely reasonable.

> [!TIP]
> `ALL` is not automatically a bug. Always consider table size and the estimated/actual work.

---

# 20. Functions on Indexed Columns

This pattern can make index use difficult:

```sql
WHERE DATE(created_at) = '2026-08-12'
```

A more index-friendly range is often:

```sql
WHERE created_at >= '2026-08-12'
  AND created_at <  '2026-08-13'
```

Why?

The second form compares the stored indexed value directly to a range.

This is called keeping the predicate **sargable**.

---

# 21. Leading Wildcards

This search:

```sql
WHERE email LIKE '%gmail.com'
```

cannot normally use a standard B-tree index to efficiently locate values based on the ending characters.

By contrast:

```sql
WHERE email LIKE 'onkar%'
```

has a searchable prefix and can be more index-friendly.

If substring search is a real requirement, consider an appropriate search strategy rather than blindly adding a normal B-tree index.

---

# 22. Expressions and Implicit Conversions

Be careful with predicates that transform or implicitly convert indexed values.

For example, comparing incompatible data types can cause conversions that make efficient index access harder.

Prefer comparing a column to a value of the correct type:

```sql
WHERE customer_id = 501
```

rather than relying on unnecessary conversions.

---

# 23. Index Prefixes on String Columns

For large string columns, MySQL supports prefix indexes:

```sql
CREATE INDEX idx_email_prefix
ON customers(email(20));
```

This stores only a prefix of the indexed string.

It can reduce index size, but it also reduces how much of the value is available for distinguishing rows and may not support every desired query pattern.

Use it only when the workload and data distribution justify it.

---

# 24. Invisible Indexes

MySQL supports invisible indexes, allowing an index to be hidden from the optimizer without immediately dropping it.

This can be useful when testing whether an index is still needed before permanently removing it.

The operational principle is more important than memorizing syntax:

```text
candidate index
      ↓
make invisible / test plan
      ↓
observe workload
      ↓
remove if safe
```

Always test carefully before changing production indexes.

---

# 25. Redundant and Duplicate Indexes

Avoid overlapping indexes without a reason.

For example:

```text
INDEX (customer_id)
INDEX (customer_id, order_date)
```

The composite index begins with `customer_id` and may already support many queries that the single-column index was intended to support.

That does **not** mean the single-column index is always redundant; query shape, size, covering requirements, and optimizer behavior matter.

Review indexes as a set rather than one at a time.

---

# 26. Indexes and Data Engineering

Indexes are especially relevant for operational/staging workloads involving:

- Incremental extraction
- CDC deduplication
- Batch status lookup
- Watermark queries
- Reconciliation queries
- Dimension lookups
- Foreign-key joins
- Latest-record selection
- Control tables

Example incremental query:

```sql
SELECT *
FROM orders
WHERE updated_at >= ?
  AND updated_at < ?;
```

A suitable index on `updated_at` may be important when the table is large and the time range is selective.

But if almost the entire table falls inside the requested range, the optimizer may reasonably choose a scan.

---

# 27. Indexing a Staging Table for Deduplication

Suppose a CDC table uses:

```text
business_key
updated_at
sequence_id
```

and the pipeline frequently identifies the newest record per key.

A candidate composite index may involve the business key and ordering columns:

```sql
CREATE INDEX idx_cdc_key_time_sequence
ON cdc_events(business_key, updated_at, sequence_id);
```

However, a window-function query may still require sorting or additional work. Index design should be validated against the actual execution plan.

---

# 28. Indexes and Writes

Every additional index has maintenance cost.

For an insert:

```text
INSERT row
   ↓
update table storage
   ↓
update index 1
   ↓
update index 2
   ↓
update index 3
```

Therefore excessive indexing can hurt:

- Insert throughput
- Update throughput
- Delete throughput
- Storage consumption
- Buffer-pool usage

This is especially important for high-volume ingestion tables.

---

# 29. When NOT to Add an Index

Do not add an index merely because:

- A column is mentioned in a query once.
- A column has a name such as `status`.
- Someone says "indexes always make queries faster."
- An `EXPLAIN` plan looks unfamiliar.

Avoid unnecessary indexes when:

- The table is tiny.
- The workload is write-heavy and the read benefit is negligible.
- The index duplicates another useful index.
- The predicate has poor selectivity and the optimizer correctly prefers a scan.
- The index is never used by meaningful workloads.

---

# 30. A Practical Index-Debugging Workflow

When a query is slow:

```text
1. Understand the business query
        ↓
2. Understand table grain and row counts
        ↓
3. Run EXPLAIN / EXPLAIN ANALYZE
        ↓
4. Identify filters, joins, ordering, grouping
        ↓
5. Check existing indexes
        ↓
6. Check whether predicates are sargable
        ↓
7. Design the smallest useful index
        ↓
8. Test again
        ↓
9. Compare actual performance
        ↓
10. Monitor write/storage impact
```

This is much better than randomly adding indexes.

---

# 31. Common Mistakes

> [!WARNING]
> These are common interview and production mistakes.

1. Creating an index on every column.
2. Assuming an index is always used.
3. Ignoring composite-index column order.
4. Forgetting the leftmost-prefix principle.
5. Using a function on an indexed column unnecessarily.
6. Ignoring leading-wildcard searches.
7. Creating overlapping/redundant indexes.
8. Making indexes extremely wide without a reason.
9. Forgetting index maintenance cost on writes.
10. Judging performance without `EXPLAIN`.
11. Treating `EXPLAIN type = ALL` as automatically wrong.
12. Adding indexes without understanding the query's data distribution.

---

# 32. Interview-Focused Questions

> [!QUESTION]
>
> ## Interview Follow-up Questions

### Q1. Why do indexes improve read performance?

<details>
<summary><strong>Answer</strong></summary>

An index provides an organized access path that can let MySQL locate relevant rows without scanning the entire table. The benefit depends on the query, selectivity, data size, and optimizer plan.
</details>

### Q2. Why aren't indexes free?

<details>
<summary><strong>Answer</strong></summary>

Indexes consume storage and must be maintained during inserts, updates, and deletes. Too many indexes can therefore reduce write throughput and increase memory/storage pressure.
</details>

### Q3. What is a composite index?

<details>
<summary><strong>Answer</strong></summary>

An index containing multiple columns in a defined order, such as `(customer_id, order_date)`. The column order determines which query predicates can use the index efficiently.
</details>

### Q4. Explain the leftmost-prefix principle.

<details>
<summary><strong>Answer</strong></summary>

For `(customer_id, order_date)`, queries beginning with the leading `customer_id` column can generally use the index more effectively. A query filtering only on `order_date` cannot normally use the composite index in the same direct way.
</details>

### Q5. Why does composite-index column order matter?

<details>
<summary><strong>Answer</strong></summary>

The index is physically organized according to the specified column order. Changing `(customer_id, order_date)` to `(order_date, customer_id)` changes which query patterns can efficiently use the leading portion of the index.
</details>

### Q6. What is a covering index?

<details>
<summary><strong>Answer</strong></summary>

A covering index contains all columns needed by a query, allowing the engine to potentially satisfy the query from the index without additional row lookups.
</details>

### Q7. Why might MySQL ignore an index?

<details>
<summary><strong>Answer</strong></summary>

The table may be small, the predicate may be poorly selective, another plan may be cheaper, the query may not match the index structure, or the optimizer may estimate a scan as less expensive. Check `EXPLAIN` rather than assuming the index should be used.
</details>

### Q8. Why is `WHERE DATE(created_at) = ...` potentially problematic for an index?

<details>
<summary><strong>Answer</strong></summary>

The expression transforms the indexed column. A range predicate directly on `created_at` is often more index-friendly and preserves sargability.
</details>

### Q9. Why is `LIKE '%abc'` problematic for a normal B-tree index?

<details>
<summary><strong>Answer</strong></summary>

The search begins with an unknown prefix, so the B-tree cannot efficiently narrow the search based on the beginning of the indexed value.
</details>

### Q10. Should every foreign key have an index?

<details>
<summary><strong>Answer</strong></summary>

Foreign-key columns are common candidates for indexes because they participate in joins and parent/child access patterns, but index design should still consider the actual workload and existing composite indexes.
</details>

### Q11. Why can a low-cardinality column be a poor standalone index?

<details>
<summary><strong>Answer</strong></summary>

If a value matches a large percentage of the table, using the index may require many row accesses and can be more expensive than a scan. The optimizer decides based on estimated cost.
</details>

### Q12. What is the difference between `EXPLAIN` and `EXPLAIN ANALYZE`?

<details>
<summary><strong>Answer</strong></summary>

`EXPLAIN` shows the planned execution. `EXPLAIN ANALYZE` executes the statement and provides actual execution information that can be compared with estimates.
</details>

### Q13. Why can a large primary key affect secondary indexes in InnoDB?

<details>
<summary><strong>Answer</strong></summary>

Secondary-index entries include the primary-key value used to locate the clustered row. A wider primary key can therefore increase secondary-index size.
</details>

### Q14. Why shouldn't you create an index for every WHERE column independently?

<details>
<summary><strong>Answer</strong></summary>

The workload may benefit more from a carefully ordered composite index, while multiple single-column indexes increase storage and write-maintenance cost. The optimizer may also combine indexes in some cases, but that should not replace deliberate index design.
</details>

### Q15. How would you investigate a slow query before creating an index?

<details>
<summary><strong>Answer</strong></summary>

Understand the query and data distribution, inspect existing indexes, run `EXPLAIN` or `EXPLAIN ANALYZE`, identify filters/joins/order/group requirements, check predicate sargability, then test a candidate index and measure the result.
</details>

### Q16. A query uses an index but is still slow. What would you investigate?

<details>
<summary><strong>Answer</strong></summary>

Check how many rows are actually being examined, selectivity, row lookups, whether the index is covering, join cardinality, sorting/grouping work, stale estimates, and the actual execution plan. "Using an index" does not automatically mean the query is efficient.
</details>

### Q17. Why can an index hurt a high-volume ETL load?

<details>
<summary><strong>Answer</strong></summary>

Every inserted or changed row may require updates to multiple index structures. Excessive indexes therefore increase write amplification and can reduce ingestion throughput.
</details>

### Q18. When would you consider a covering index?

<details>
<summary><strong>Answer</strong></summary>

When a frequent read query is performance-sensitive and can be satisfied entirely from a reasonably sized index. The benefit should be weighed against the additional storage and write cost.
</details>

### Q19. Is `type = ALL` in EXPLAIN always bad?

<details>
<summary><strong>Answer</strong></summary>

No. A full scan of a small table can be cheaper than an index lookup. The important question is whether the amount of work is appropriate for the table size and workload.
</details>

### Q20. How would you design an index for `WHERE customer_id = ? AND order_date >= ? ORDER BY order_date`?

<details>
<summary><strong>Answer</strong></summary>

A natural candidate is `(customer_id, order_date)` because the query first identifies a customer and then ranges/orders by date. Verify the plan and actual workload before treating it as the final design.
</details>

---

# 33. Quick Revision

| Concept | Remember |
|---|---|
| Index | Alternative access path to locate rows |
| Primary key | Clustered index in InnoDB |
| Secondary index | Separate index that includes the primary key for row lookup |
| Composite index | Multiple columns in a defined order |
| Leftmost prefix | Leading columns determine direct usability |
| Covering index | Index contains everything needed by the query |
| Selectivity | How much a predicate narrows rows |
| `EXPLAIN` | Inspect optimizer plan |
| `EXPLAIN ANALYZE` | Execute and inspect actual behavior |
| Sargable predicate | Predicate that preserves efficient index access |
| Write cost | Indexes must be maintained on data changes |
| Redundant index | Overlapping index that may add cost without benefit |

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — practical index creation, query, and `EXPLAIN` examples
- [`practice.sql`](./practice.sql) — index-design and query-optimization exercises without solutions

> [!TIP]
> The most important habit is: **do not guess about indexes — inspect the query, inspect the existing indexes, inspect the execution plan, make one targeted change, and measure again.**
