# 📅 Date and Time Functions

## 📌 Overview

MySQL provides date and time functions for storing, extracting, comparing, formatting, and transforming temporal data. These functions are essential for analytics, reporting, ETL pipelines, incremental loads, and time-based business logic.

## 🎯 Learning Objectives

- Understand MySQL date and time data types.
- Extract date/time components.
- Perform date arithmetic and date differences.
- Format and parse dates safely.
- Filter data using reliable date ranges.
- Handle timestamps in Data Engineering workflows.

## 🧠 Core Concepts

### Current Date and Time

- `CURDATE()` / `CURRENT_DATE()` — current date.
- `CURTIME()` / `CURRENT_TIME()` — current time.
- `NOW()` / `CURRENT_TIMESTAMP()` — current date and time.
- `UTC_DATE()` / `UTC_TIMESTAMP()` — UTC values.

### Extracting Components

- `YEAR()`
- `MONTH()`
- `DAY()` / `DAYOFMONTH()`
- `HOUR()` / `MINUTE()` / `SECOND()`
- `DAYOFWEEK()` / `DAYOFYEAR()`
- `WEEK()` / `WEEKDAY()`
- `QUARTER()`

### Date Arithmetic

- `DATE_ADD()` / `ADDDATE()`
- `DATE_SUB()` / `SUBDATE()`
- `INTERVAL`
- `DATEDIFF()`
- `TIMESTAMPDIFF()`
- `TIMESTAMPADD()`

### Formatting and Parsing

- `DATE_FORMAT()` — format a date/time as text.
- `STR_TO_DATE()` — convert text into a date/time value.

### Date Truncation Patterns

MySQL does not have a universal `DATE_TRUNC()` function like some analytical databases. Common patterns use `DATE_FORMAT()`, `CAST()`, or interval arithmetic to derive month, quarter, or year boundaries.

## ⚠️ Important Practices

### Prefer Half-Open Date Ranges

For a timestamp column, prefer:

```sql
WHERE event_time >= '2026-01-01'
  AND event_time <  '2026-02-01';
```

This avoids missing rows because of time components and is safer than `BETWEEN` for timestamp ranges.

### `DATEDIFF()` vs `TIMESTAMPDIFF()`

`DATEDIFF()` returns the difference in days and ignores the time portion. `TIMESTAMPDIFF()` lets you specify a unit such as `SECOND`, `MINUTE`, `HOUR`, `DAY`, `MONTH`, or `YEAR`.

### Time Zones

Keep a clear convention for timestamps in data pipelines. UTC storage plus explicit conversion at presentation boundaries is a common production pattern.

## 🏗️ Data Engineering Use Cases

- Incremental extraction using a watermark timestamp.
- Daily and monthly partition logic.
- SLA and processing-duration calculations.
- Event-time windows.
- Customer age and tenure calculations.
- Late-arriving data detection.
- Daily batch reconciliation.
- Rolling reporting periods.

## ❌ Common Mistakes

- Comparing a timestamp to an incomplete end date with `BETWEEN`.
- Applying a function to an indexed timestamp in a filter unnecessarily.
- Mixing local time and UTC without documenting the convention.
- Treating formatted date strings as dates.
- Confusing `DATEDIFF()` with `TIMESTAMPDIFF()`.
- Ignoring `NULL` timestamps.

## 💼 Interview-Focused Questions

### Q1. What is the difference between `DATEDIFF()` and `TIMESTAMPDIFF()`?

<details>
<summary><strong>Answer</strong></summary>

`DATEDIFF()` returns the difference in days and ignores the time portion. `TIMESTAMPDIFF()` accepts a unit such as `HOUR`, `DAY`, or `MONTH`, making it suitable for more precise duration calculations.

</details>

---

### Q2. Why is a half-open date range preferred for timestamp filtering?

<details>
<summary><strong>Answer</strong></summary>

Using `>= start` and `< end` includes every timestamp in the intended period without depending on the final time value of the day. It also avoids precision-related boundary problems.

</details>

---

### Q3. How would you find records created in January 2026?

<details>
<summary><strong>Answer</strong></summary>

Use a range on the timestamp column:

```sql
WHERE created_at >= '2026-01-01'
  AND created_at < '2026-02-01'
```

</details>

---

### Q4. How would you calculate processing duration in minutes?

<details>
<summary><strong>Answer</strong></summary>

Use `TIMESTAMPDIFF(MINUTE, start_time, end_time)`.

</details>

---

### Q5. What is the difference between `NOW()` and `CURDATE()`?

<details>
<summary><strong>Answer</strong></summary>

`NOW()` returns the current date and time, while `CURDATE()` returns only the current date.

</details>

---

### Q6. How would you extract the month from an order date?

<details>
<summary><strong>Answer</strong></summary>

Use `MONTH(order_date)`. For reporting, you may also derive a month-start value so rows can be grouped consistently.

</details>

---

### Q7. How would you add 7 days to a date?

<details>
<summary><strong>Answer</strong></summary>

Use `DATE_ADD(order_date, INTERVAL 7 DAY)`.

</details>

---

### Q8. Why can wrapping an indexed date column in a function hurt performance?

<details>
<summary><strong>Answer</strong></summary>

A predicate such as `DATE(created_at) = '2026-01-01'` can prevent efficient use of an index on `created_at`. A range predicate is generally more index-friendly.

</details>

---

### Q9. How would you identify records older than 90 days?

<details>
<summary><strong>Answer</strong></summary>

A common pattern is:

```sql
WHERE created_at < NOW() - INTERVAL 90 DAY
```

</details>

---

### Q10. How would you design an incremental load using a timestamp watermark?

<details>
<summary><strong>Answer</strong></summary>

Persist the last successfully processed timestamp and query the source for rows after that watermark. In production, use a deterministic boundary strategy and account for late-arriving records or equal timestamps.

</details>

## 🔄 Quick Revision

| Function | Purpose |
|---|---|
| `CURDATE()` | Current date |
| `NOW()` | Current date and time |
| `YEAR()` | Extract year |
| `MONTH()` | Extract month |
| `DATE_ADD()` | Add an interval |
| `DATE_SUB()` | Subtract an interval |
| `DATEDIFF()` | Difference in days |
| `TIMESTAMPDIFF()` | Difference in chosen unit |
| `DATE_FORMAT()` | Format date/time |
| `STR_TO_DATE()` | Parse text into date/time |

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — worked examples for MySQL date and time functions
- [`practice.sql`](./practice.sql) — hands-on exercises and interview practice
