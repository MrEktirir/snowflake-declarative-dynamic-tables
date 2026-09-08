# Architecture

## Overview

This project demonstrates a declarative data transformation pipeline built with Snowflake Dynamic Tables.

The pipeline separates raw source data, staging transformations, and a final fact model.

## Data Flow

```text
Python UDTFs
    ↓
RAW_DB.PUBLIC.CUSTOMERS
RAW_DB.PUBLIC.ORDERS
    ↓
STG_CUSTOMERS_DT
STG_ORDERS_DT
    ↓
FCT_CUSTOMER_ORDERS_DT