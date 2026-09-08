-- ============================================================
-- Snowflake Declarative Dynamic Tables Pipeline
-- 04 - Fact Dynamic Table
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE ANALYTICS_DB;
USE SCHEMA PUBLIC;


-- ------------------------------------------------------------
-- Customer Orders Fact Dynamic Table
-- ------------------------------------------------------------

CREATE OR REPLACE DYNAMIC TABLE FCT_CUSTOMER_ORDERS_DT
    TARGET_LAG = DOWNSTREAM
    WAREHOUSE = COMPUTE_WH
AS
SELECT
    c.customer_id,
    c.customer_name,
    o.product_id,
    o.order_price,
    o.quantity,
    o.order_date
FROM STG_CUSTOMERS_DT AS c
LEFT JOIN STG_ORDERS_DT AS o
    ON c.customer_id = o.customer_id;


-- ------------------------------------------------------------
-- Verification
-- ------------------------------------------------------------

SELECT *
FROM FCT_CUSTOMER_ORDERS_DT
LIMIT 20;

SELECT COUNT(*) AS fact_row_count
FROM FCT_CUSTOMER_ORDERS_DT;