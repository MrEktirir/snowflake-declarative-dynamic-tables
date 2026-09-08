-- ============================================================
-- Snowflake Declarative Dynamic Tables Pipeline
-- 01 - Environment Setup
-- ============================================================

USE ROLE ACCOUNTADMIN;

-- Compute resource used by the Dynamic Tables pipeline.
CREATE WAREHOUSE IF NOT EXISTS COMPUTE_WH
    WITH WAREHOUSE_SIZE = 'LARGE'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE;

-- RAW_DB stores source/raw data.
CREATE DATABASE IF NOT EXISTS RAW_DB;

-- ANALYTICS_DB stores transformed Dynamic Tables.
CREATE DATABASE IF NOT EXISTS ANALYTICS_DB;

USE DATABASE RAW_DB;
USE SCHEMA PUBLIC;