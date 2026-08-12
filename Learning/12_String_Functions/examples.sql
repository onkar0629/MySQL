-- 12_String_Functions/examples.sql
-- Run against a MySQL database with the sample table below.

DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(30),
    customer_code VARCHAR(30)
);

INSERT INTO customers VALUES
(1, ' Onkar ', 'Jadhav', ' ONKAR@EXAMPLE.COM ', '987-654-3210', 'MUM-00123'),
(2, 'Priya', 'Sharma', 'priya@example.com', '998-111-2233', 'DEL-00456'),
(3, 'Rahul', NULL, 'rahul@example.com', NULL, 'BLR-00789'),
(4, ' Sneha', 'Patil ', 'sneha@example.com', '900-555-6677', 'PUN-00042');

-- 1. LENGTH vs CHAR_LENGTH
SELECT first_name,
       LENGTH(first_name) AS bytes,
       CHAR_LENGTH(first_name) AS characters
FROM customers;

-- 2. Case conversion
SELECT UPPER(first_name) AS upper_name,
       LOWER(email) AS lower_email
FROM customers;

-- 3. Trim whitespace
SELECT first_name,
       TRIM(first_name) AS cleaned_first_name
FROM customers;

-- 4. Concatenation
SELECT CONCAT(TRIM(first_name), ' ', COALESCE(TRIM(last_name), '')) AS full_name
FROM customers;

-- 5. CONCAT_WS
SELECT CONCAT_WS(' ', TRIM(first_name), TRIM(last_name)) AS full_name
FROM customers;

-- 6. Extract prefix and suffix
SELECT customer_code,
       LEFT(customer_code, 3) AS source_system,
       RIGHT(customer_code, 3) AS sequence_number
FROM customers;

-- 7. SUBSTRING
SELECT customer_code,
       SUBSTRING(customer_code, 1, 3) AS source_system
FROM customers;

-- 8. Find a substring
SELECT email, LOCATE('@', email) AS at_position
FROM customers;

-- 9. Replace formatting characters
SELECT phone,
       REPLACE(phone, '-', '') AS normalized_phone
FROM customers;

-- 10. Padding
SELECT customer_id,
       LPAD(customer_id, 6, '0') AS formatted_id
FROM customers;

-- 11. Extract email username/domain
SELECT email,
       SUBSTRING_INDEX(TRIM(email), '@', 1) AS username,
       SUBSTRING_INDEX(TRIM(email), '@', -1) AS domain
FROM customers;

-- 12. Normalize an email
SELECT email,
       LOWER(TRIM(email)) AS normalized_email
FROM customers;

-- 13. Detect malformed email values
SELECT customer_id, email
FROM customers
WHERE email IS NOT NULL
  AND TRIM(email) NOT LIKE '%@%';

-- 14. Build a business key
SELECT customer_id,
       CONCAT(LOWER(TRIM(SUBSTRING_INDEX(customer_code, '-', 1))), '-', customer_id) AS business_key
FROM customers;

-- 15. Demonstrate NULL-safe concatenation
SELECT CONCAT('Customer: ', COALESCE(TRIM(first_name), 'Unknown')) AS label
FROM customers;

-- 16. Reverse and repeat
SELECT customer_code,
       REVERSE(customer_code) AS reversed_code,
       REPEAT('*', 5) AS mask
FROM customers;

-- 17. Search after normalizing case
SELECT *
FROM customers
WHERE LOWER(TRIM(email)) LIKE '%@example.com';

-- 18. Practical cleaning pipeline
SELECT customer_id,
       TRIM(first_name) AS first_name,
       TRIM(last_name) AS last_name,
       LOWER(TRIM(email)) AS email,
       REPLACE(REPLACE(REPLACE(phone, '-', ''), ' ', ''), '(', '') AS phone_clean
FROM customers;
