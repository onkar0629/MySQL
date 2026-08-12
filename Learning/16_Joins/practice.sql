-- 16_Joins: practice
-- Solve each exercise before writing a solution.

CREATE DATABASE IF NOT EXISTS sql_practice_16;
USE sql_practice_16;

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(50),
    city VARCHAR(30),
    segment VARCHAR(20)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    status VARCHAR(20),
    amount DECIMAL(10,2)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(50),
    category VARCHAR(30),
    price DECIMAL(10,2)
);

CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT,
    PRIMARY KEY (order_id, product_id)
);

INSERT INTO customers VALUES
(1,'Asha','Mumbai','Premium'),
(2,'Rahul','Pune','Standard'),
(3,'Meera','Delhi','Premium'),
(4,'Vikram','Mumbai','Standard'),
(5,'Neha','Nashik','Standard'),
(6,'Arjun','Pune','Premium');

INSERT INTO orders VALUES
(101,1,'2026-08-01','COMPLETED',1200),
(102,1,'2026-08-05','CANCELLED',800),
(103,2,'2026-08-03','COMPLETED',1500),
(104,4,'2026-08-07','COMPLETED',500),
(105,7,'2026-08-08','COMPLETED',700),
(106,2,'2026-08-09','COMPLETED',900);

INSERT INTO products VALUES
(1,'Laptop','Electronics',70000),
(2,'Keyboard','Electronics',2500),
(3,'Chair','Furniture',6000),
(4,'Desk','Furniture',12000),
(5,'Mouse','Electronics',1200);

INSERT INTO order_items VALUES
(101,1,1),
(101,2,1),
(103,3,2),
(104,4,1),
(106,5,2);

-- SECTION A: INNER JOIN

-- 1. Join customers with orders.
-- 2. Return customer name, order ID, order date, and amount.
-- 3. Find orders belonging to Premium customers.
-- 4. Find orders placed by customers from Mumbai.
-- 5. Join orders with order_items.
-- 6. Join order_items with products to display product names.
-- 7. Build a customer-order-product dataset using three joins.
-- 8. Calculate item-level extended value as quantity * product price.
-- 9. Find customers who have at least one completed order.
-- 10. Find completed orders and their customer segment.

-- SECTION B: LEFT JOIN

-- 11. List every customer and any matching orders.
-- 12. Find customers with no orders.
-- 13. Count orders for every customer, including customers with zero orders.
-- 14. Calculate total completed spend for every customer.
-- 15. Find Premium customers who have never ordered.
-- 16. Return every product and matching order-item rows.
-- 17. Find products that have never been ordered.
-- 18. Find every city and its customers with no orders.
-- 19. Find customers who have orders but no completed orders.
-- 20. Show all customers and their latest order date.

-- SECTION C: RIGHT JOIN / REWRITING JOINS

-- 21. Use RIGHT JOIN to return every order and matching customer.
-- 22. Rewrite question 21 using LEFT JOIN.
-- 23. Explain why teams often prefer LEFT JOIN over RIGHT JOIN.
-- 24. Find orphan orders using LEFT JOIN.
-- 25. Find orphan orders using NOT EXISTS.

-- SECTION D: ON vs WHERE

-- 26. Return all customers but only completed orders in the joined rows.
-- 27. Repeat question 26 using a WHERE filter and compare the result.
-- 28. Find the reason the two queries return different row counts.
-- 29. Return all customers and orders above 1000 without removing customers with no qualifying orders.
-- 30. Filter a right-side date range while preserving unmatched customers.

-- SECTION E: JOIN GRAIN AND DUPLICATES

-- 31. Determine the grain of customers, orders, and order_items.
-- 32. Explain why joining customers to order_items can duplicate customer rows.
-- 33. Calculate total customer spend without double-counting.
-- 34. Calculate total quantity purchased per product.
-- 35. Calculate total revenue per product.
-- 36. Find customers with more than one order.
-- 37. Find products appearing in more than one order.
-- 38. Demonstrate the row-count difference between orders and order_items after a join.
-- 39. Aggregate order_items to order grain before joining to customers.
-- 40. Explain when pre-aggregation is required before a join.

-- SECTION F: DATA ENGINEERING SCENARIOS

-- 41. Reconcile source orders against the customer dimension.
-- 42. Return matched and orphan order counts.
-- 43. Identify customer IDs present in orders but missing from customers.
-- 44. Identify customers present in the dimension but absent from orders.
-- 45. Build a source-to-target reconciliation report using joins.
-- 46. Find products referenced by order_items but missing from products.
-- 47. Calculate the percentage of orders with a missing customer dimension.
-- 48. Join a fact table to a dimension while preserving all fact rows.
-- 49. Explain why joining two fact tables directly can multiply measures.
-- 50. Design a safe approach for joining two fact tables through shared dimensions.

-- SECTION G: INTERVIEW CHALLENGES

-- 51. Customers whose second order was within 30 days of their first order.
-- 52. Customers who ordered every product in a category.
-- 53. Products never purchased by Premium customers.
-- 54. Customers whose total spend exceeds the average customer spend.
-- 55. Find duplicate customer records using a self-join concept.
-- 56. Find orders whose customer city differs from a shipping city.
-- 57. Find customers who placed an order but never purchased an Electronics product.
-- 58. Find the highest-spending customer in each city.
-- 59. Reconcile order totals against order-item totals.
-- 60. Build a final customer 360 dataset using customers, orders, order_items, and products without double-counting measures.

DROP DATABASE sql_practice_16;
