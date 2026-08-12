-- ============================================================
-- 14_Numeric_and_Mathematical_Functions / examples.sql
-- Worked examples for MySQL numeric and mathematical functions
-- ============================================================

CREATE DATABASE IF NOT EXISTS numeric_functions_demo;
USE numeric_functions_demo;

DROP TABLE IF EXISTS transactions;

CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    customer_id INT,
    amount DECIMAL(12, 2),
    source_amount DECIMAL(12, 2),
    target_amount DECIMAL(12, 2),
    quantity INT,
    unit_price DECIMAL(10, 2),
    discount_percent DECIMAL(5, 2)
);

INSERT INTO transactions
(transaction_id, customer_id, amount, source_amount, target_amount, quantity, unit_price, discount_percent)
VALUES
(1, 101, 1250.756, 1000.00, 999.95, 3, 250.00, 10.00),
(2, 102, -425.40, 500.00, 512.50, 5, 99.99, 5.00),
(3, 103, 999.999, 750.00, 750.00, 2, 600.00, 15.00),
(4, 104, 75.125, 100.00, 89.75, 7, 15.50, 0.00);

-- 1. Arithmetic operators
SELECT 100 + 25 AS addition,
       100 - 25 AS subtraction,
       100 * 25 AS multiplication,
       100 / 25 AS division,
       100 % 30 AS remainder;

-- 2. ABS(): absolute difference for reconciliation
SELECT
    transaction_id,
    ABS(source_amount - target_amount) AS absolute_difference
FROM transactions;

-- 3. SIGN(): identify positive, zero, and negative values
SELECT
    transaction_id,
    amount,
    SIGN(amount) AS amount_sign
FROM transactions;

-- 4. ROUND(): financial-style presentation
SELECT
    transaction_id,
    amount,
    ROUND(amount, 2) AS rounded_amount
FROM transactions;

-- 5. TRUNCATE(): remove decimal digits without rounding
SELECT
    transaction_id,
    amount,
    TRUNCATE(amount, 2) AS truncated_amount
FROM transactions;

-- 6. CEIL() and FLOOR()
SELECT
    transaction_id,
    amount,
    CEIL(amount) AS rounded_up,
    FLOOR(amount) AS rounded_down
FROM transactions;

-- 7. MOD(): identify quantities divisible by 2
SELECT
    transaction_id,
    quantity,
    MOD(quantity, 2) AS remainder
FROM transactions;

-- 8. POWER() and SQRT()
SELECT
    POWER(2, 5) AS power_result,
    SQRT(144) AS square_root_result;

-- 9. PI()
SELECT PI() AS pi_value;

-- 10. RAND(): generate a random value
SELECT RAND() AS random_value;

-- 11. Deterministic RAND() seed example
SELECT RAND(42) AS seeded_random_value;

-- 12. Calculate line-item gross amount
SELECT
    transaction_id,
    quantity,
    unit_price,
    quantity * unit_price AS gross_amount
FROM transactions;

-- 13. Calculate discounted price
SELECT
    transaction_id,
    unit_price,
    discount_percent,
    ROUND(unit_price * (1 - discount_percent / 100), 2) AS discounted_unit_price
FROM transactions;

-- 14. Calculate total after discount
SELECT
    transaction_id,
    quantity,
    ROUND(quantity * unit_price * (1 - discount_percent / 100), 2) AS final_amount
FROM transactions;

-- 15. Reconciliation tolerance check
SELECT
    transaction_id,
    source_amount,
    target_amount,
    ABS(source_amount - target_amount) AS difference,
    CASE
        WHEN ABS(source_amount - target_amount) <= 10 THEN 'MATCH'
        ELSE 'MISMATCH'
    END AS reconciliation_status
FROM transactions;

-- 16. Create 1,000-unit spend buckets
SELECT
    transaction_id,
    amount,
    FLOOR(ABS(amount) / 1000) * 1000 AS amount_bucket
FROM transactions;

-- 17. Aggregate first, then round
SELECT
    ROUND(SUM(amount), 2) AS total_amount
FROM transactions;

-- 18. Demonstrate NULL propagation
SELECT
    ABS(NULL) AS abs_null,
    ROUND(NULL, 2) AS round_null,
    SQRT(NULL) AS sqrt_null;

-- Cleanup
DROP DATABASE numeric_functions_demo;
