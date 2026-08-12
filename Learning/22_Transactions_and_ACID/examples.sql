-- 22_Transactions_and_ACID — Examples
-- Run these examples carefully in a test database.

CREATE DATABASE IF NOT EXISTS transactions_demo;
USE transactions_demo;

DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS inventory;
DROP TABLE IF EXISTS pipeline_runs;

CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    account_name VARCHAR(100) NOT NULL,
    balance DECIMAL(12,2) NOT NULL
) ENGINE = InnoDB;

INSERT INTO accounts VALUES
(1, 'Account A', 10000.00),
(2, 'Account B', 5000.00);

CREATE TABLE inventory (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    stock_quantity INT NOT NULL
) ENGINE = InnoDB;

INSERT INTO inventory VALUES
(101, 'Laptop', 10),
(102, 'Monitor', 5);

CREATE TABLE pipeline_runs (
    run_id INT PRIMARY KEY,
    status VARCHAR(20) NOT NULL,
    started_at DATETIME NULL,
    completed_at DATETIME NULL
) ENGINE = InnoDB;

INSERT INTO pipeline_runs VALUES
(5001, 'PENDING', NULL, NULL),
(5002, 'PENDING', NULL, NULL);

-- 1. Atomic transfer.
START TRANSACTION;
UPDATE accounts SET balance = balance - 1000 WHERE account_id = 1;
UPDATE accounts SET balance = balance + 1000 WHERE account_id = 2;
COMMIT;

-- 2. Rollback an uncommitted change.
START TRANSACTION;
UPDATE accounts SET balance = balance - 500 WHERE account_id = 1;
SELECT * FROM accounts WHERE account_id = 1;
ROLLBACK;
SELECT * FROM accounts WHERE account_id = 1;

-- 3. SAVEPOINT and partial rollback.
START TRANSACTION;
UPDATE accounts SET balance = balance - 200 WHERE account_id = 1;
SAVEPOINT after_first_update;
UPDATE accounts SET balance = balance + 200 WHERE account_id = 2;
ROLLBACK TO SAVEPOINT after_first_update;
COMMIT;

-- 4. Autocommit and isolation settings.
SELECT @@autocommit;
SELECT @@transaction_isolation;

-- 5. Safe inventory reservation pattern.
START TRANSACTION;
SELECT stock_quantity
FROM inventory
WHERE product_id = 101
FOR UPDATE;
UPDATE inventory
SET stock_quantity = stock_quantity - 1
WHERE product_id = 101
  AND stock_quantity >= 1;
SELECT ROW_COUNT() AS rows_updated;
COMMIT;

-- 6. Atomic pipeline status claim.
START TRANSACTION;
UPDATE pipeline_runs
SET status = 'RUNNING', started_at = CURRENT_TIMESTAMP
WHERE run_id = 5001
  AND status = 'PENDING';
SELECT ROW_COUNT() AS rows_claimed;
COMMIT;

-- 7. Session isolation level.
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT @@transaction_isolation;

-- 8. Atomic pipeline completion update.
START TRANSACTION;
UPDATE pipeline_runs
SET status = 'SUCCESS', completed_at = CURRENT_TIMESTAMP
WHERE run_id = 5001
  AND status = 'RUNNING';
COMMIT;

SELECT * FROM pipeline_runs WHERE run_id = 5001;

-- 9. Final session settings.
SELECT @@autocommit AS autocommit,
       @@transaction_isolation AS isolation_level;

-- 10. DDL note:
-- MySQL DDL can have implicit-commit behavior. Do not assume a schema change
-- can be rolled back together with ordinary business DML.
