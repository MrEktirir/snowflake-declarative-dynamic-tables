-- ============================================================
-- Snowflake Declarative Dynamic Tables Pipeline
-- 03 - Staging Dynamic Tables
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE ANALYTICS_DB;
USE SCHEMA PUBLIC;


-- ------------------------------------------------------------
-- Customer Staging Dynamic Table
-- ------------------------------------------------------------

CREATE OR REPLACE DYNAMIC TABLE STG_CUSTOMERS_DT
    TARGET_LAG = DOWNSTREAM
    WAREHOUSE = COMPUTE_WH
AS
SELECT
    custid::NUMBER AS customer_id,
    cname::VARCHAR AS customer_name,
    spendlimit::NUMBER(10,2) AS spend_limit
FROM RAW_DB.PUBLIC.CUSTOMERS;


-- ------------------------------------------------------------
-- Order Staging Dynamic Table
-- ------------------------------------------------------------

CREATE OR REPLACE DYNAMIC TABLE STG_ORDERS_DT
    TARGET_LAG = DOWNSTREAM
    WAREHOUSE = COMPUTE_WH
AS
SELECT
    custid::NUMBER AS customer_id,
    purchase:prodid::NUMBER AS product_id,
    purchase:purchase_amount::FLOAT AS order_price,
    purchase:quantity::NUMBER AS quantity,
    purchase:purchase_date::DATE AS order_date
FROM RAW_DB.PUBLIC.ORDERS;


-- ------------------------------------------------------------
-- Verification
-- ------------------------------------------------------------

SELECT *
FROM STG_CUSTOMERS_DT
LIMIT 10;

SELECT *
FROM STG_ORDERS_DT
LIMIT 10;

SELECT COUNT(*) AS staging_customer_count
FROM STG_CUSTOMERS_DT;

SELECT COUNT(*) AS staging_order_count
FROM STG_ORDERS_DT;