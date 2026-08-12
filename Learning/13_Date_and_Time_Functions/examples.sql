-- ============================================================
-- 13_Date_and_Time_Functions | Worked Examples
-- ============================================================

CREATE DATABASE IF NOT EXISTS de_datetime_demo;
USE de_datetime_demo;

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL,
    shipped_at DATETIME NULL,
    amount DECIMAL(10,2) NOT NULL
);

INSERT INTO orders VALUES
(1, 101, '2026-01-05 09:15:00', '2026-01-06 14:30:00', 1250.00),
(2, 102, '2026-01-15 18:20:00', '2026-01-18 10:00:00', 800.00),
(3, 101, '2026-02-01 11:05:00', NULL, 450.00),
(4, 103, '2026-02-20 16:40:00', '2026-02-21 09:10:00', 2100.00);

-- Current date/time
SELECT CURDATE() AS current_date,
       CURTIME() AS current_time,
       NOW() AS current_datetime,
       UTC_TIMESTAMP() AS utc_datetime;

-- Extract components
SELECT order_id,
       YEAR(order_date) AS order_year,
       MONTH(order_date) AS order_month,
       DAY(order_date) AS order_day,
       HOUR(order_date) AS order_hour,
       QUARTER(order_date) AS order_quarter
FROM orders;

-- Add/subtract intervals
SELECT order_id,
       order_date,
       DATE_ADD(order_date, INTERVAL 7 DAY) AS seven_days_later,
       DATE_SUB(order_date, INTERVAL 1 MONTH) AS one_month_earlier
FROM orders;

-- Difference in days
SELECT order_id,
       DATEDIFF(shipped_at, order_date) AS shipping_days
FROM orders
WHERE shipped_at IS NOT NULL;

-- Difference in hours/minutes
SELECT order_id,
       TIMESTAMPDIFF(HOUR, order_date, shipped_at) AS shipping_hours,
       TIMESTAMPDIFF(MINUTE, order_date, shipped_at) AS shipping_minutes
FROM orders
WHERE shipped_at IS NOT NULL;

-- Format dates for presentation
SELECT order_id,
       DATE_FORMAT(order_date, '%Y-%m-%d') AS order_day,
       DATE_FORMAT(order_date, '%Y-%m') AS order_month,
       DATE_FORMAT(order_date, '%W, %d %M %Y') AS formatted_date
FROM orders;

-- Parse text into a date
SELECT STR_TO_DATE('2026-03-15 14:30:00', '%Y-%m-%d %H:%i:%s') AS parsed_datetime;

-- Safe half-open month filter
SELECT *
FROM orders
WHERE order_date >= '2026-01-01'
  AND order_date <  '2026-02-01';

-- Avoid DATE(order_date) in the indexed filter when a range can be used
SELECT *
FROM orders
WHERE order_date >= '2026-01-15'
  AND order_date <  '2026-01-16';

-- Month-start reporting key
SELECT order_id,
       DATE_FORMAT(order_date, '%Y-%m-01') AS month_start_text
FROM orders;

-- Records older than 90 days relative to current time
SELECT *
FROM orders
WHERE order_date < NOW() - INTERVAL 90 DAY;

-- Incremental-load style watermark
SET @last_watermark = '2026-01-15 00:00:00';
SELECT *
FROM orders
WHERE order_date > @last_watermark
ORDER BY order_date;

-- Handle NULL timestamps
SELECT order_id,
       CASE
           WHEN shipped_at IS NULL THEN 'NOT SHIPPED'
           ELSE 'SHIPPED'
       END AS shipping_status
FROM orders;

-- Cleanup
DROP DATABASE IF EXISTS de_datetime_demo;
