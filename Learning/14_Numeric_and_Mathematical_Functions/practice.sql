-- ============================================================
-- 14_Numeric_and_Mathematical_Functions / practice.sql
-- 60 exercises: basic -> practical -> interview -> DE scenarios
-- ============================================================

CREATE DATABASE IF NOT EXISTS numeric_functions_practice;
USE numeric_functions_practice;

DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS measurements;

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    customer_id INT,
    amount DECIMAL(12, 2),
    expected_amount DECIMAL(12, 2),
    quantity INT,
    unit_price DECIMAL(10, 2),
    discount_percent DECIMAL(5, 2)
);

INSERT INTO payments VALUES
(1, 101, 1250.75, 1250.00, 3, 500.00, 10.00),
(2, 102, 499.99, 500.00, 2, 275.00, 5.00),
(3, 103, -75.50, 75.50, 1, 100.00, 0.00),
(4, 104, 2400.40, 2390.00, 8, 350.00, 15.00),
(5, 105, 999.95, 1000.00, 5, 225.00, 12.50),
(6, 106, 50.00, 50.00, 10, 5.00, 0.00);

CREATE TABLE measurements (
    measurement_id INT PRIMARY KEY,
    sensor_id INT,
    reading DECIMAL(12, 4)
);

INSERT INTO measurements VALUES
(1, 1, 10.2567),
(2, 1, 10.9912),
(3, 2, -5.4567),
(4, 2, 0.0000),
(5, 3, 99.9999),
(6, 3, NULL);

-- ============================================================
-- SECTION A: FUNDAMENTALS
-- ============================================================

-- 1. Add two numbers: 125 + 75.

-- 2. Subtract 35 from 100.

-- 3. Multiply 25 by 8.

-- 4. Divide 144 by 12.

-- 5. Find the remainder of 29 divided by 6.

-- 6. Calculate the absolute value of -450.

-- 7. Return the sign of -10, 0, and 25.

-- 8. Round 125.6789 to 2 decimal places.

-- 9. Truncate 125.6789 to 2 decimal places.

-- 10. Find the ceiling of 18.2.

-- 11. Find the floor of 18.9.

-- 12. Calculate 2 raised to the power of 10.

-- 13. Calculate the square root of 625.

-- 14. Return the value of PI().

-- 15. Generate a random number using RAND().

-- ============================================================
-- SECTION B: TABLE-BASED CALCULATIONS
-- ============================================================

-- 16. Display payment amounts rounded to 2 decimal places.

-- 17. Display payment amounts rounded to the nearest whole number.

-- 18. Display payment amounts truncated to 1 decimal place.

-- 19. Find the absolute difference between amount and expected_amount.

-- 20. Return payments where the absolute difference exceeds 5.

-- 21. Return the sign of each payment amount.

-- 22. Calculate gross line amount using quantity * unit_price.

-- 23. Calculate discount amount.

-- 24. Calculate final line amount after discount.

-- 25. Round final line amount to 2 decimals.

-- 26. Create a 100-unit bucket using FLOOR().

-- 27. Identify even payment quantities using MOD().

-- 28. Identify quantities divisible by 5.

-- 29. Find the maximum payment amount and round it to 2 decimals.

-- 30. Find the average payment amount and round it to 2 decimals.

-- ============================================================
-- SECTION C: PRECISION AND NULLS
-- ============================================================

-- 31. Show ROUND(reading, 2) for all measurements.

-- 32. Compare ROUND(reading, 2) with TRUNCATE(reading, 2).

-- 33. Return measurements whose reading is negative.

-- 34. Return measurements whose absolute reading is greater than 50.

-- 35. Demonstrate how numeric functions behave with NULL.

-- 36. Count non-NULL sensor readings.

-- 37. Calculate the average sensor reading rounded to 2 decimals.

-- 38. Explain why DECIMAL is preferred over FLOAT for money.

-- 39. Write a query that checks whether two monetary values differ by more than 0.01.

-- 40. Explain why comparing FLOAT values with = can be unreliable.

-- ============================================================
-- SECTION D: BUSINESS SCENARIOS
-- ============================================================

-- 41. Calculate the final amount for every payment after discount.

-- 42. Find payments whose final amount exceeds 1,000.

-- 43. Categorize payments as LOW (<500), MEDIUM (500-1999.99), HIGH (>=2000).

-- 44. Calculate the percentage difference between amount and expected_amount.

-- 45. Flag records as MATCH when absolute difference <= 5, otherwise MISMATCH.

-- 46. Create amount buckets of 500.

-- 47. Find the total gross merchandise value using quantity and unit_price.

-- 48. Find the total discounted value and round only the final result.

-- 49. Find customers whose payment amount is a multiple of 100.

-- 50. Find the payment with the largest absolute amount.

-- ============================================================
-- SECTION E: DATA ENGINEERING SCENARIOS
-- ============================================================

-- 51. Reconcile source and target amounts using a tolerance of 0.01.

-- 52. Identify records where target amount differs from source amount by more than 1%.

-- 53. Calculate absolute sensor deviation from zero.

-- 54. Flag sensor readings outside the range -10 to 100.

-- 55. Build 10-unit measurement buckets.

-- 56. Calculate a rounded KPI from aggregated payment values.

-- 57. Explain why rounding each row before SUM() can produce a different result from SUM() then ROUND().

-- 58. Find records with a negative amount and calculate the absolute amount.

-- 59. Build a reconciliation report containing source, target, absolute difference, percentage difference, and status.

-- 60. FINAL CHALLENGE:
-- Build a payment-quality report that includes:
--   payment_id
--   customer_id
--   gross amount
--   discount amount
--   final amount
--   source/expected difference
--   percentage difference
--   reconciliation status
--   amount bucket
-- Round financial outputs to 2 decimals only at the appropriate final stage.

DROP DATABASE numeric_functions_practice;
