-- ============================================================
-- 05 — Constraints and Keys
-- Worked Examples
-- ============================================================

CREATE DATABASE IF NOT EXISTS constraints_lab;
USE constraints_lab;

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

-- 1. PRIMARY KEY, NOT NULL, DEFAULT, CHECK, AUTO_INCREMENT
CREATE TABLE customers (
    customer_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    age INT CHECK (age >= 18),
    CONSTRAINT uq_customers_email UNIQUE (email)
);

INSERT INTO customers (customer_name, email, age)
VALUES
    ('Amit Sharma', 'amit@example.com', 25),
    ('Priya Patil', 'priya@example.com', 29);

SELECT * FROM customers;

-- 2. UNIQUE constraint prevents duplicate business identifiers.
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    sku VARCHAR(50) NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    CONSTRAINT uq_products_sku UNIQUE (sku)
);

INSERT INTO products VALUES
    (101, 'SKU-101', 'Keyboard', 1200.00),
    (102, 'SKU-102', 'Mouse', 700.00);

-- 3. FOREIGN KEY creates a parent-child relationship.
CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    order_date DATE NOT NULL,
    CONSTRAINT fk_orders_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);

INSERT INTO orders VALUES
    (1001, 1, '2026-08-01'),
    (1002, 2, '2026-08-02');

SELECT * FROM orders;

-- This would fail because customer_id 999 does not exist.
-- INSERT INTO orders VALUES (1003, 999, '2026-08-03');

-- 4. Composite primary key.
CREATE TABLE order_items (
    order_id BIGINT,
    product_id INT,
    quantity INT NOT NULL CHECK (quantity > 0),
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

INSERT INTO order_items VALUES
    (1001, 101, 2),
    (1001, 102, 1),
    (1002, 102, 3);

-- 5. Composite UNIQUE constraint.
CREATE TABLE warehouse_stock (
    warehouse_id INT,
    product_id INT,
    quantity INT NOT NULL DEFAULT 0,
    PRIMARY KEY (warehouse_id, product_id),
    CONSTRAINT chk_stock_quantity CHECK (quantity >= 0)
);

-- 6. Foreign-key actions.
CREATE TABLE cascade_orders (
    order_id INT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

INSERT INTO cascade_orders VALUES (2001, 1);

-- Deleting customer 1 also deletes matching cascade_orders rows.
-- DELETE FROM customers WHERE customer_id = 1;

-- 7. Optional relationship using SET NULL.
CREATE TABLE customer_accounts (
    account_id INT PRIMARY KEY,
    customer_id BIGINT NULL,
    account_type VARCHAR(30),
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE SET NULL
);

-- 8. Add constraints after table creation.
CREATE TABLE staging_products (
    product_id INT,
    sku VARCHAR(50),
    price DECIMAL(10,2)
);

ALTER TABLE staging_products
ADD PRIMARY KEY (product_id);

ALTER TABLE staging_products
ADD CONSTRAINT uq_staging_products_sku UNIQUE (sku);

ALTER TABLE staging_products
ADD CONSTRAINT chk_staging_products_price CHECK (price >= 0);

-- 9. Inspect constraints and table definitions.
SHOW CREATE TABLE customers;
SHOW CREATE TABLE orders;
SHOW CREATE TABLE order_items;

-- 10. Practical relational model.
CREATE TABLE departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE employees (
    employee_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    department_id INT,
    salary DECIMAL(12,2) CHECK (salary >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
        ON DELETE SET NULL
);

INSERT INTO departments VALUES
    (10, 'Data Engineering'),
    (20, 'Analytics');

INSERT INTO employees (employee_name, email, department_id, salary)
VALUES
    ('Rahul Mehta', 'rahul@example.com', 10, 85000.00),
    ('Neha Joshi', 'neha@example.com', 20, 78000.00);

SELECT
    e.employee_id,
    e.employee_name,
    d.department_name,
    e.salary
FROM employees e
LEFT JOIN departments d
    ON e.department_id = d.department_id;

-- Key takeaway:
-- Constraints should encode important data-integrity rules close to the data.
