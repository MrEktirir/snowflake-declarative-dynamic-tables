-- ============================================================
-- Snowflake Declarative Dynamic Tables Pipeline
-- 05 - Data Quality
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE ANALYTICS_DB;
USE SCHEMA PUBLIC;


-- ------------------------------------------------------------
-- Recreate Fact Table with Product ID Quality Filter
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
    ON c.customer_id = o.customer_id
WHERE o.product_id IS NOT NULL;


-- ------------------------------------------------------------
-- Data Quality Verification
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS total_rows,
    COUNT_IF(customer_id IS NULL) AS null_customer_id,
    COUNT_IF(product_id IS NULL) AS null_product_id,
    COUNT_IF(order_price IS NULL) AS null_order_price,
    COUNT_IF(quantity IS NULL) AS null_quantity,
    COUNT_IF(order_date IS NULL) AS null_order_date
FROM FCT_CUSTOMER_ORDERS_DT;