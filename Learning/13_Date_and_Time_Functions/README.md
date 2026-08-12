# 📅 13 — Date and Time Functions

## 📌 Overview

Date and time logic is fundamental to SQL and Data Engineering. It is used for incremental loads, event-time processing, partition filtering, SLA calculations, retention, reporting periods, late-arriving data, and data-quality checks.

The important skill is not memorizing functions. It is knowing **which temporal data type and comparison pattern correctly represent the business requirement**.

> [!IMPORTANT]
> For timestamp filtering, prefer **half-open ranges**: `>= start` and `< end`. This is safer than trying to construct an artificial `23:59:59` end-of-day value.

---

## 🎯 Learning Objectives

By the end of this topic, you should be able to:

- Choose between `DATE`, `DATETIME`, `TIMESTAMP`, `TIME`, and `YEAR`.
- Retrieve the current date/time and UTC date/time.
- Extract date and time components.
- Add and subtract temporal intervals.
- Calculate elapsed time correctly.
- Build day, week, month, quarter, and year boundaries.
- Format dates for presentation and parse source strings.
- Write index-friendly timestamp filters.
- Handle time zones deliberately.
- Build incremental-load watermark logic.
- Detect late-arriving and stale records.
- Calculate durations, ages, and retention periods.
- Avoid common date/time bugs in production SQL.

---

# 1. 🧱 MySQL Date and Time Data Types

Choosing the correct data type is more important than the function used later.

| Type | Stores | Example | Typical use |
|---|---|---|---|
| `DATE` | Date only | `2026-08-13` | Birth date, business date |
| `DATETIME` | Date + time | `2026-08-13 14:30:00` | Event/business timestamp |
| `TIMESTAMP` | Date + time | `2026-08-13 14:30:00` | System timestamps, audit columns |
| `TIME` | Time/duration-like value | `14:30:00` | Time of day or elapsed time |
| `YEAR` | Year | `2026` | Year-only attributes |

### `DATE`

Use when the time component has no business meaning.

```sql
birth_date DATE
```

Do not store a date as `VARCHAR` simply because it is displayed as `YYYY-MM-DD`.

### `DATETIME`

Use when the application needs a date and time without MySQL automatically converting the value between session time zones.

```sql
created_at DATETIME
```

### `TIMESTAMP`

`TIMESTAMP` values are stored in UTC internally and converted between UTC and the current session time zone when retrieved. This makes time-zone behavior important when using it.

```sql
created_at TIMESTAMP
```

### Practical rule

For event data, first decide whether the timestamp represents:

1. An **absolute instant** in time → use a timestamp design with an explicit UTC convention.
2. A **local business date/time** whose wall-clock value must remain unchanged → `DATETIME` may be appropriate.
3. A **calendar date** with no time → `DATE`.

---

# 2. 🕐 Current Date and Time

```sql
SELECT CURDATE();
```

Returns the current date.

```sql
SELECT CURTIME();
```

Returns the current time.

```sql
SELECT NOW();
```

Returns the current date and time.

Equivalent commonly used forms:

```sql
SELECT CURRENT_DATE();
SELECT CURRENT_TIME();
SELECT CURRENT_TIMESTAMP();
```

For UTC:

```sql
SELECT UTC_DATE();
SELECT UTC_TIMESTAMP();
```

### Important distinction

```sql
CURDATE()   -- date only
NOW()       -- date + time
```

Do not use `NOW()` when the business requirement is only a calendar date unless the time portion is intentionally needed.

---

# 3. 🔍 Extracting Date Components

MySQL provides functions for extracting individual components.

```sql
SELECT
    YEAR(order_date)        AS order_year,
    MONTH(order_date)       AS order_month,
    DAY(order_date)         AS order_day,
    HOUR(order_datetime)    AS order_hour,
    MINUTE(order_datetime)  AS order_minute,
    SECOND(order_datetime)  AS order_second
FROM orders;
```

Other useful functions:

```sql
SELECT
    QUARTER(order_date),
    DAYOFYEAR(order_date),
    DAYOFWEEK(order_date),
    WEEKDAY(order_date)
FROM orders;
```

### `DAYOFWEEK()` vs `WEEKDAY()`

They use different numbering conventions.

```text
DAYOFWEEK()
Sunday = 1
Monday = 2
...
Saturday = 7
```

```text
WEEKDAY()
Monday = 0
Tuesday = 1
...
Sunday = 6
```

For weekday logic, always verify which convention your application expects.

---

# 4. ➕ Adding and Subtracting Dates

Use `DATE_ADD()` with an `INTERVAL`.

```sql
SELECT
    DATE_ADD(order_date, INTERVAL 7 DAY) AS due_date
FROM orders;
```

Subtract using `DATE_SUB()`:

```sql
SELECT
    DATE_SUB(order_date, INTERVAL 7 DAY) AS previous_date
FROM orders;
```

You can use different units:

```sql
DATE_ADD(order_date, INTERVAL 1 DAY)
DATE_ADD(order_date, INTERVAL 2 WEEK)
DATE_ADD(order_date, INTERVAL 3 MONTH)
DATE_ADD(order_date, INTERVAL 1 YEAR)
DATE_ADD(order_datetime, INTERVAL 90 MINUTE)
```

Alternative syntax exists:

```sql
SELECT order_date + INTERVAL 7 DAY
FROM orders;
```

For readable production SQL, `DATE_ADD()` / `DATE_SUB()` are often clearer when the expression becomes more complex.

---

# 5. 📏 `DATEDIFF()`

`DATEDIFF()` returns the number of days between two dates.

```sql
SELECT
    DATEDIFF(end_date, start_date) AS days_elapsed
FROM jobs;
```

It ignores the time portion.

For example, the difference between:

```text
2026-08-13 23:00:00
2026-08-14 01:00:00
```

is one day when evaluated with `DATEDIFF()`, even though only two hours elapsed.

> [!WARNING]
> Do not use `DATEDIFF()` when the business requirement is elapsed hours, minutes, or seconds.

---

# 6. ⏱️ `TIMESTAMPDIFF()`

Use `TIMESTAMPDIFF()` when the unit of elapsed time matters.

```sql
SELECT
    TIMESTAMPDIFF(HOUR, start_time, end_time) AS hours_elapsed
FROM jobs;
```

Supported units commonly used in Data Engineering include:

```sql
SECOND
MINUTE
HOUR
DAY
WEEK
MONTH
QUARTER
YEAR
```

Examples:

```sql
SELECT TIMESTAMPDIFF(MINUTE, start_time, end_time)
FROM jobs;
```

```sql
SELECT TIMESTAMPDIFF(DAY, created_at, NOW())
FROM orders;
```

```sql
SELECT TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) AS age
FROM customers;
```

### `DATEDIFF()` vs `TIMESTAMPDIFF()`

| Requirement | Use |
|---|---|
| Difference in calendar days | `DATEDIFF()` |
| Difference in hours | `TIMESTAMPDIFF(HOUR, ...)` |
| Difference in minutes | `TIMESTAMPDIFF(MINUTE, ...)` |
| Difference in months | `TIMESTAMPDIFF(MONTH, ...)` |
| Difference in completed years | `TIMESTAMPDIFF(YEAR, ...)` |

---

# 7. 🔢 `TIMESTAMPADD()`

`TIMESTAMPADD()` adds an interval expressed with a unit.

```sql
SELECT
    TIMESTAMPADD(HOUR, 4, created_at) AS expected_completion
FROM jobs;
```

This is useful when the interval unit is supplied dynamically or when you want the unit to be explicit in the expression.

---

# 8. 📆 Start and End of a Day

For a timestamp column, do not write:

```sql
WHERE created_at BETWEEN '2026-08-13 00:00:00'
                      AND '2026-08-13 23:59:59'
```

This can fail when the column contains fractional seconds.

Prefer:

```sql
WHERE created_at >= '2026-08-13 00:00:00'
  AND created_at <  '2026-08-14 00:00:00';
```

This is a **half-open interval**:

```text
[start, end)

includes start
excludes end
```

It is one of the most important date-filtering patterns for production SQL.

---

# 9. 📅 Filtering a Month

To retrieve all records from January 2026:

```sql
SELECT *
FROM orders
WHERE order_time >= '2026-01-01'
  AND order_time <  '2026-02-01';
```

Avoid:

```sql
WHERE MONTH(order_time) = 1
  AND YEAR(order_time) = 2026;
```

The second form applies functions to the column and can make an ordinary index on `order_time` less useful for the filter.

The range form is both precise and generally more index-friendly.

---

# 10. 🗓️ Finding the Start of a Month

A common reporting requirement is to derive the first day of the month.

```sql
SELECT
    DATE_FORMAT(order_date, '%Y-%m-01') AS month_start
FROM orders;
```

If a real date value is required rather than formatted text:

```sql
SELECT
    CAST(DATE_FORMAT(order_date, '%Y-%m-01') AS DATE) AS month_start
FROM orders;
```

For grouping, a month-start date is often more useful than a formatted label because it remains a temporal value.

---

# 11. 📅 Finding the End of a Month

Use `LAST_DAY()`:

```sql
SELECT
    LAST_DAY(order_date) AS month_end
FROM orders;
```

Example:

```sql
SELECT LAST_DAY('2026-02-10');
```

Result:

```text
2026-02-28
```

For timestamp filtering, however, the next-month boundary is usually safer than constructing the last second of the current month.

```sql
WHERE event_time >= '2026-02-01'
  AND event_time <  '2026-03-01'
```

---

# 12. 📊 Quarter and Year Logic

Extract the quarter:

```sql
SELECT
    QUARTER(order_date) AS order_quarter
FROM orders;
```

Extract the year:

```sql
SELECT
    YEAR(order_date) AS order_year
FROM orders;
```

A useful reporting key is:

```sql
SELECT
    CONCAT(YEAR(order_date), '-Q', QUARTER(order_date)) AS year_quarter
FROM orders;
```

For analytical models, consider storing or deriving a proper calendar dimension instead of repeatedly implementing fiscal-calendar logic in every query.

---

# 13. 🧮 `PERIOD_DIFF()` and Month-Based Logic

When the business requirement is based specifically on calendar months, `PERIOD_DIFF()` can be useful with `YYYYMM` values.

```sql
SELECT
    PERIOD_DIFF(
        EXTRACT(YEAR_MONTH FROM end_date),
        EXTRACT(YEAR_MONTH FROM start_date)
    ) AS month_difference
FROM subscriptions;
```

Do not confuse calendar-month difference with elapsed duration. For exact elapsed time, use `TIMESTAMPDIFF()`.

---

# 14. 🧾 Formatting with `DATE_FORMAT()`

`DATE_FORMAT()` converts a date/time value into text.

```sql
SELECT
    DATE_FORMAT(order_time, '%Y-%m-%d') AS order_date
FROM orders;
```

Common format specifiers:

| Specifier | Meaning |
|---|---|
| `%Y` | Four-digit year |
| `%y` | Two-digit year |
| `%m` | Month number |
| `%M` | Month name |
| `%d` | Day of month |
| `%H` | Hour, 00–23 |
| `%i` | Minute |
| `%s` | Second |
| `%W` | Weekday name |

Example:

```sql
SELECT
    DATE_FORMAT(order_time, '%Y-%m-%d %H:%i:%s') AS formatted_time
FROM orders;
```

> [!IMPORTANT]
> `DATE_FORMAT()` produces **text**. Do not use formatted strings as a substitute for real date/time values in the data model.

---

# 15. 🔄 Parsing Text with `STR_TO_DATE()`

External systems sometimes provide dates as strings.

```sql
SELECT
    STR_TO_DATE('13-08-2026', '%d-%m-%Y') AS parsed_date;
```

Example during staging:

```sql
INSERT INTO orders (order_date)
SELECT
    STR_TO_DATE(source_order_date, '%d/%m/%Y')
FROM staging_orders;
```

The goal should be to convert external strings into proper temporal types at the ingestion/staging boundary rather than carrying date strings through the warehouse.

---

# 16. 🧠 `EXTRACT()`

`EXTRACT()` provides SQL-standard-style component extraction.

```sql
SELECT
    EXTRACT(YEAR FROM order_date)  AS order_year,
    EXTRACT(MONTH FROM order_date) AS order_month,
    EXTRACT(DAY FROM order_date)   AS order_day
FROM orders;
```

It is useful when you want extraction syntax that is explicit about the requested temporal component.

---

# 17. 🕘 Time Zone Handling

Time-zone mistakes are a major source of production data errors.

Inspect the current session time zone:

```sql
SELECT @@session.time_zone;
```

Inspect the global setting:

```sql
SELECT @@global.time_zone;
```

Convert a value between time zones with `CONVERT_TZ()`:

```sql
SELECT
    CONVERT_TZ(
        event_time,
        'UTC',
        'Asia/Kolkata'
    ) AS local_event_time
FROM events;
```

### Recommended pipeline convention

For systems representing absolute instants:

```text
Source
  ↓
Normalize timestamp to UTC
  ↓
Store with explicit UTC convention
  ↓
Transform / aggregate
  ↓
Convert to business/user timezone at presentation boundary
```

The exact design depends on the source system and business requirements, but the timezone convention must be explicit.

---

# 18. 🚚 Incremental Loads with a Watermark

A common Data Engineering pattern is to extract only rows changed after the last successful load.

Suppose the previous successful watermark is:

```text
2026-08-12 23:00:00
```

A simple extraction is:

```sql
SELECT *
FROM source_orders
WHERE updated_at > '2026-08-12 23:00:00';
```

### The real production problem

Multiple records may have the same `updated_at` value.

A timestamp-only watermark can therefore require careful boundary handling.

A stronger design can use a deterministic compound watermark:

```text
(updated_at, order_id)
```

For example, the state might record:

```text
last_updated_at = '2026-08-12 23:00:00'
last_order_id   = 5000
```

Then the extraction logic can account for rows with the same timestamp but a greater key.

Another common strategy is to intentionally re-read a small overlap window and deduplicate downstream.

> [!IMPORTANT]
> A production incremental load must define what happens when records arrive late, timestamps are equal, records are updated after extraction, or a pipeline run fails after partially processing data.

---

# 19. ⏳ Late-Arriving Records

A record can have an old event time but arrive in the system later.

Example:

```text
event_time      = 2026-08-10 10:00:00
ingested_at     = 2026-08-13 02:00:00
```

These are different concepts.

```text
event_time  → when the business event happened
ingested_at → when the pipeline received the record
```

Do not use ingestion time as a replacement for event time when the business logic depends on when the event actually occurred.

A useful data-quality check is:

```sql
SELECT *
FROM events
WHERE ingested_at > event_time + INTERVAL 24 HOUR;
```

This can identify unusually late records, although the acceptable threshold should come from the business requirement.

---

# 20. 🧹 Retention and Aging

Find records older than 90 days:

```sql
SELECT *
FROM events
WHERE created_at < NOW() - INTERVAL 90 DAY;
```

For a retention process:

```sql
DELETE FROM staging_events
WHERE created_at < NOW() - INTERVAL 90 DAY;
```

Before running destructive statements, validate the selection with a `SELECT` first.

```sql
SELECT COUNT(*)
FROM staging_events
WHERE created_at < NOW() - INTERVAL 90 DAY;
```

---

# 21. ⚡ Sargable Date Filters and Indexes

Suppose this index exists:

```sql
CREATE INDEX idx_orders_created_at
ON orders(created_at);
```

Prefer:

```sql
SELECT *
FROM orders
WHERE created_at >= '2026-08-01'
  AND created_at <  '2026-09-01';
```

Avoid when possible:

```sql
SELECT *
FROM orders
WHERE DATE(created_at) = '2026-08-01';
```

The second predicate transforms the indexed column before comparison.

For large tables, inspect the actual plan:

```sql
EXPLAIN
SELECT *
FROM orders
WHERE created_at >= '2026-08-01'
  AND created_at <  '2026-09-01';
```

> [!NOTE]
> The optimizer can sometimes use indexes through more complex strategies, so do not rely on rules alone. Verify important production queries with `EXPLAIN` and actual workload characteristics.

---

# 22. 🧪 NULL Date/Time Values

Date functions return `NULL` when the input is `NULL`.

```sql
SELECT
    TIMESTAMPDIFF(HOUR, started_at, completed_at)
FROM jobs;
```

If `completed_at` is `NULL`, the duration is `NULL`.

For completed jobs only:

```sql
WHERE completed_at IS NOT NULL
```

Do not automatically replace missing timestamps with arbitrary values such as `'1970-01-01'`. That destroys the distinction between **missing** and **actual historical time**.

---

# 23. 💼 Common Data Engineering Patterns

### Daily batch window

```sql
WHERE processed_at >= '2026-08-13 00:00:00'
  AND processed_at <  '2026-08-14 00:00:00'
```

### Monthly reporting window

```sql
WHERE order_time >= '2026-08-01'
  AND order_time <  '2026-09-01'
```

### Records updated recently

```sql
WHERE updated_at >= NOW() - INTERVAL 1 DAY
```

### Processing duration

```sql
SELECT
    job_id,
    TIMESTAMPDIFF(SECOND, started_at, completed_at) AS duration_seconds
FROM pipeline_runs
WHERE completed_at IS NOT NULL;
```

### Detect future timestamps

```sql
SELECT *
FROM events
WHERE event_time > NOW();
```

### Detect incomplete processing

```sql
SELECT *
FROM pipeline_runs
WHERE started_at IS NOT NULL
  AND completed_at IS NULL;
```

---

# 24. ⚠️ Common Mistakes

### Mistake 1 — Using `BETWEEN` for timestamp day/month filters

Prefer half-open ranges.

### Mistake 2 — Using `DATEDIFF()` for hours/minutes

Use `TIMESTAMPDIFF()` with the required unit.

### Mistake 3 — Applying `DATE()` to an indexed timestamp in a selective filter

Prefer a range predicate.

### Mistake 4 — Treating `DATE_FORMAT()` as a data-conversion function

It formats a temporal value into text. Use `STR_TO_DATE()` for parsing text.

### Mistake 5 — Mixing UTC and local time

Define the timezone convention and convert deliberately.

### Mistake 6 — Using ingestion time as event time

They represent different business concepts.

### Mistake 7 — Ignoring fractional seconds

Do not assume `23:59:59` is the end of a timestamp day.

### Mistake 8 — Replacing missing timestamps with fake dates

Keep `NULL` when the value is genuinely unknown or unavailable.

### Mistake 9 — Assuming month duration is always 30 days

Calendar months have different lengths. Use calendar-aware functions when the requirement is month-based.

### Mistake 10 — Building incremental loads with an ambiguous watermark

Account for equal timestamps, late arrivals, retries, and deterministic ordering.

---

# 25. 🎤 Interview-Focused Questions

### Q1. What is the difference between `DATE`, `DATETIME`, and `TIMESTAMP`?

<details>
<summary><strong>Answer</strong></summary>

`DATE` stores only a calendar date. `DATETIME` stores date and time without the automatic timezone conversion behavior associated with `TIMESTAMP`. `TIMESTAMP` represents date/time values with UTC-based internal storage and session-time-zone conversion on retrieval.

</details>

---

### Q2. Why do you prefer `>= start AND < end` over `BETWEEN` for timestamp ranges?

<details>
<summary><strong>Answer</strong></summary>

The half-open range includes every value from the start boundary up to, but not including, the next boundary. It handles fractional seconds cleanly and avoids constructing an artificial end-of-day timestamp.

</details>

---

### Q3. What is the difference between `DATEDIFF()` and `TIMESTAMPDIFF()`?

<details>
<summary><strong>Answer</strong></summary>

`DATEDIFF()` returns a difference in days and ignores the time portion. `TIMESTAMPDIFF()` allows the caller to specify units such as seconds, minutes, hours, days, months, or years.

</details>

---

### Q4. How would you retrieve all records created during August 2026?

<details>
<summary><strong>Answer</strong></summary>

```sql
WHERE created_at >= '2026-08-01'
  AND created_at <  '2026-09-01'
```

This is preferred over applying `MONTH()` and `YEAR()` to the column.

</details>

---

### Q5. Why can `WHERE DATE(created_at) = '2026-08-13'` be inefficient?

<details>
<summary><strong>Answer</strong></summary>

The expression applies a function to the indexed column, which can prevent efficient use of a normal index on `created_at`. A half-open timestamp range is generally more index-friendly.

</details>

---

### Q6. How would you calculate the duration of a pipeline job in minutes?

<details>
<summary><strong>Answer</strong></summary>

```sql
TIMESTAMPDIFF(MINUTE, started_at, completed_at)
```

The correct unit depends on the required precision.

</details>

---

### Q7. How would you calculate a customer's age?

<details>
<summary><strong>Answer</strong></summary>

```sql
TIMESTAMPDIFF(YEAR, birth_date, CURDATE())
```

This calculates completed years rather than simply subtracting the year numbers.

</details>

---

### Q8. What is the difference between event time and ingestion time?

<details>
<summary><strong>Answer</strong></summary>

Event time represents when the business event occurred. Ingestion time represents when the data pipeline received or stored the record. They can differ significantly for late-arriving data and should not be treated as interchangeable.

</details>

---

### Q9. How would you design a timestamp-based incremental load?

<details>
<summary><strong>Answer</strong></summary>

Persist the watermark from the last successful load and extract rows after that boundary. A production design must also handle equal timestamps, late-arriving records, retries, failures, and deterministic ordering. A compound watermark or overlap-and-deduplicate strategy may be appropriate.

</details>

---

### Q10. Why can timezone handling cause duplicate or missing records in daily loads?

<details>
<summary><strong>Answer</strong></summary>

A business day in one timezone does not necessarily align with a UTC day. If the extraction window is defined in local time but applied as if it were UTC, records near midnight can be assigned to the wrong batch. The pipeline must define the timezone of its business boundaries explicitly.

</details>

---

### Q11. What is the purpose of `LAST_DAY()`?

<details>
<summary><strong>Answer</strong></summary>

It returns the last calendar day of the month containing the supplied date. It is useful for reporting and calendar logic. For timestamp filtering, the beginning of the next period is usually a safer exclusive upper bound.

</details>

---

### Q12. When would you use `STR_TO_DATE()`?

<details>
<summary><strong>Answer</strong></summary>

Use it when a source provides a date/time as text and the value must be converted into a proper MySQL temporal value. This is common in staging and ingestion workflows.

</details>

---

### Q13. Why should dates generally not be stored as strings?

<details>
<summary><strong>Answer</strong></summary>

String storage makes date arithmetic, validation, ordering, filtering, indexing, and timezone handling harder and more error-prone. Proper temporal data types preserve the semantic meaning of the value and allow native date/time operations.

</details>

---

### Q14. How would you detect records with timestamps in the future?

<details>
<summary><strong>Answer</strong></summary>

```sql
SELECT *
FROM events
WHERE event_time > NOW();
```

The acceptable rule may need to include a tolerance for clock skew or known future-scheduled events.

</details>

---

### Q15. What is a half-open interval?

<details>
<summary><strong>Answer</strong></summary>

A half-open interval includes its lower boundary and excludes its upper boundary: `[start, end)`. For example, `created_at >= '2026-08-01' AND created_at < '2026-09-01'` includes all of August without needing to define the last possible timestamp in August.

</details>

---

## 🔄 Quick Revision

| Concept | Key Point |
|---|---|
| `DATE` | Date only |
| `DATETIME` | Date + time without automatic timezone conversion |
| `TIMESTAMP` | UTC-based internal storage with session timezone conversion |
| `CURDATE()` | Current date |
| `NOW()` | Current date and time |
| `UTC_TIMESTAMP()` | Current UTC timestamp |
| `YEAR()` / `MONTH()` | Extract components |
| `QUARTER()` | Extract quarter |
| `DATE_ADD()` | Add interval |
| `DATE_SUB()` | Subtract interval |
| `DATEDIFF()` | Difference in days |
| `TIMESTAMPDIFF()` | Difference in selected unit |
| `LAST_DAY()` | Last calendar day of month |
| `DATE_FORMAT()` | Temporal value → text |
| `STR_TO_DATE()` | Text → temporal value |
| `CONVERT_TZ()` | Convert between time zones |
| Half-open range | `>= start AND < end` |
| Watermark | Tracks incremental extraction boundary |
| Event time | When event happened |
| Ingestion time | When pipeline received it |
| Sargable filter | Keeps indexed column directly comparable when possible |

## 📂 Files in This Topic

- [`examples.sql`](./examples.sql) — worked MySQL date/time examples
- [`practice.sql`](./practice.sql) — hands-on date/time and Data Engineering exercises
