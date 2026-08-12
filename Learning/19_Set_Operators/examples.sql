-- 19_Set_Operators — Examples
-- MySQL set operators: UNION, UNION ALL, INTERSECT, EXCEPT

DROP TABLE IF EXISTS store_customers;
DROP TABLE IF EXISTS online_customers;
DROP TABLE IF EXISTS source_customers;
DROP TABLE IF EXISTS target_customers;

CREATE TABLE online_customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL
);

CREATE TABLE store_customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL
);

CREATE TABLE source_customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150)
);

CREATE TABLE target_customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(150)
);

INSERT INTO online_customers VALUES
(101, 'Amit'),
(102, 'Neha'),
(103, 'Rahul');

INSERT INTO store_customers VALUES
(102, 'Neha'),
(103, 'Rahul'),
(104, 'Priya');

INSERT INTO source_customers VALUES
(101, 'Amit', 'amit@example.com'),
(102, 'Neha', 'neha@example.com'),
(103, 'Rahul', 'rahul@example.com'),
(104, 'Priya', 'priya@example.com');

INSERT INTO target_customers VALUES
(101, 'Amit', 'amit@example.com'),
(102, 'Neha', 'neha@example.com'),
(104, 'Priya', 'old@example.com'),
(105, 'Karan', 'karan@example.com');

-- 1. UNION removes duplicate customer IDs.
SELECT customer_id
FROM online_customers
UNION
SELECT customer_id
FROM store_customers;

-- 2. UNION ALL preserves duplicate occurrences.
SELECT customer_id
FROM online_customers
UNION ALL
SELECT customer_id
FROM store_customers;

-- 3. INTERSECT returns customer IDs present in both datasets.
SELECT customer_id
FROM online_customers
INTERSECT
SELECT customer_id
FROM store_customers;

-- 4. EXCEPT returns online-only customers.
SELECT customer_id
FROM online_customers
EXCEPT
SELECT customer_id
FROM store_customers;

-- 5. Reverse EXCEPT returns store-only customers.
SELECT customer_id
FROM store_customers
EXCEPT
SELECT customer_id
FROM online_customers;

-- 6. Preserve source lineage while consolidating systems.
SELECT customer_id, customer_name, 'ONLINE' AS source_system
FROM online_customers
UNION ALL
SELECT customer_id, customer_name, 'STORE' AS source_system
FROM store_customers;

-- 7. Final ordering applies to the combined result.
SELECT customer_id, customer_name
FROM online_customers
UNION ALL
SELECT customer_id, customer_name
FROM store_customers
ORDER BY customer_id;

-- 8. Source-only records for reconciliation.
SELECT customer_id, customer_name, email
FROM source_customers
EXCEPT
SELECT customer_id, customer_name, email
FROM target_customers;

-- 9. Target-only records for reconciliation.
SELECT customer_id, customer_name, email
FROM target_customers
EXCEPT
SELECT customer_id, customer_name, email
FROM source_customers;

-- 10. Combine data-quality exceptions into one stream.
SELECT customer_id, 'MISSING_EMAIL' AS issue
FROM source_customers
WHERE email IS NULL
UNION ALL
SELECT customer_id, 'INVALID_EMAIL' AS issue
FROM source_customers
WHERE email NOT LIKE '%@%';

-- Key lessons:
-- * UNION removes duplicates; UNION ALL does not.
-- * INTERSECT finds common rows.
-- * EXCEPT finds rows unique to the first result.
-- * Columns are matched by position, not by name.
-- * Use both directions of EXCEPT for source/target key reconciliation.
-- * Preserve source lineage when consolidating systems.
