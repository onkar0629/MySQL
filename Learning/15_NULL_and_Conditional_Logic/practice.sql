-- 15_NULL_and_Conditional_Logic: practice
-- Try each exercise before checking a solution.

CREATE DATABASE IF NOT EXISTS sql_practice_15;
USE sql_practice_15;

DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    email VARCHAR(100),
    phone VARCHAR(20),
    city VARCHAR(30),
    status VARCHAR(20),
    credit_limit DECIMAL(10,2),
    balance DECIMAL(10,2),
    orders_count INT
);

INSERT INTO customers VALUES
(1,'Asha','asha@example.com','9876543210','Mumbai','ACTIVE',100000,25000,8),
(2,'Rahul',NULL,'','Pune','ACTIVE',50000,50000,5),
(3,'Meera','meera@example.com',NULL,'Mumbai',NULL,75000,NULL,0),
(4,'Vikram',NULL,'9123456780',NULL,'INACTIVE',NULL,10000,2),
(5,'Neha','neha@example.com','9000000000','Delhi','ACTIVE',25000,0,1),
(6,'Arjun','','','Pune','ACTIVE',30000,5000,NULL),
(7,'Isha',NULL,NULL,NULL,NULL,NULL,NULL,NULL),
(8,'Rohan','rohan@example.com','8888888888','Delhi','ACTIVE',100000,90000,12);

-- SECTION A: NULL fundamentals

-- 1. Find customers whose email is NULL.
-- 2. Find customers whose email is NOT NULL.
-- 3. Find customers whose city is NULL.
-- 4. Find customers whose credit_limit is NULL.
-- 5. Find customers whose orders_count is NULL.

-- SECTION B: NULL vs empty values

-- 6. Find customers whose phone is an empty string.
-- 7. Find customers whose phone is either NULL or empty.
-- 8. Treat empty email strings as NULL in the output.
-- 9. Return a cleaned phone value where empty strings and NULL both become 'Not Available'.
-- 10. Explain why phone = NULL is incorrect.

-- SECTION C: COALESCE and IFNULL

-- 11. Display 'Unknown' when city is NULL.
-- 12. Display 'No Email' when email is NULL.
-- 13. Use COALESCE to return email, then phone, then customer_name as a fallback.
-- 14. Use IFNULL to replace NULL credit limits with 0.
-- 15. Return a display status where NULL status becomes 'UNKNOWN'.

-- SECTION D: NULLIF and safe calculations

-- 16. Convert empty email strings to NULL using NULLIF.
-- 17. Calculate balance as a percentage of credit_limit without divide-by-zero errors.
-- 18. Return NULL when orders_count is zero before calculating average balance per order.
-- 19. Create a safe utilization ratio using NULLIF(credit_limit, 0).
-- 20. Explain when NULLIF is preferable to a CASE expression for safe division.

-- SECTION E: CASE expressions

-- 21. Classify customers as HIGH, MEDIUM, or LOW based on credit_limit.
-- 22. Classify customers based on balance.
-- 23. Create a data-quality flag when email, city, or credit_limit is NULL.
-- 24. Create an order activity label: 'No Orders', 'Low Activity', 'Active'.
-- 25. Create a customer risk category using balance and credit_limit.
-- 26. Treat NULL credit_limit as 'LIMIT MISSING'.
-- 27. Use a CASE expression to classify NULL and non-NULL statuses.
-- 28. Create a CASE expression that distinguishes NULL, zero, and positive balance.

-- SECTION F: Three-valued logic

-- 29. Find customers where balance > 20000.
-- 30. Explain why customers with NULL balance are not returned by balance > 20000.
-- 31. Find customers where balance <= 20000 OR balance IS NULL.
-- 32. Find customers where status <> 'ACTIVE' and explain how NULL status behaves.
-- 33. Rewrite a NULL-sensitive condition using IS NULL / IS NOT NULL.

-- SECTION G: Conditional aggregation

-- 34. Count total customers by city.
-- 35. Count customers with missing email by city.
-- 36. Count customers with missing phone by city.
-- 37. Count customers with NULL credit limits by status.
-- 38. Count customers with zero orders by city.
-- 39. Calculate active vs inactive customer counts in one query.
-- 40. Calculate valid vs invalid customer counts using CASE.

-- SECTION H: Data Engineering scenarios

-- 41. A source system stores missing phone numbers as ''. Normalize them to NULL.
-- 42. Create a data-quality report showing missing email, phone, city, and credit_limit counts.
-- 43. Calculate the percentage of records with missing email.
-- 44. Find records where both email and phone are missing.
-- 45. Find records where at least one mandatory field is missing.
-- 46. Build a customer completeness score from four nullable fields.
-- 47. Create a normalized status where NULL becomes UNKNOWN and lowercase values become uppercase.
-- 48. Identify customers whose balance cannot safely be compared to credit_limit because credit_limit is NULL or zero.
-- 49. Build a reconciliation metric that counts customers with balance above their credit limit.
-- 50. Create a pipeline-ready flag: VALID, INCOMPLETE, or INVALID based on business rules.

-- SECTION I: Interview challenges

-- 51. Explain NULL = NULL.
-- 52. Explain NULL <> NULL.
-- 53. Explain COUNT(*) vs COUNT(email) for this dataset.
-- 54. Why can NOT IN produce unexpected results when NULL exists?
-- 55. Rewrite an anti-filter using NOT EXISTS.
-- 56. COALESCE vs IFNULL: which is more portable and why?
-- 57. CASE vs IF: when would you prefer CASE?
-- 58. Write a query that safely calculates utilization without errors.
-- 59. Write a query that detects empty strings and NULL as the same missing-value condition.
-- 60. Build a final data-quality summary containing total rows, missing-email rows, missing-phone rows, missing-city rows, and invalid rows.

DROP DATABASE sql_practice_15;
