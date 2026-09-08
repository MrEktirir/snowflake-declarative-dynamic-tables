# Snowflake Declarative Data Pipeline with Dynamic Tables

A hands-on data engineering project demonstrating how to build a **declarative data transformation pipeline in Snowflake using Dynamic Tables**.

The project implements a layered **Raw → Staging → Fact** architecture, transforms semi-structured data into relational models, manages dependencies through Dynamic Tables, applies a basic data-quality rule, and explores pipeline freshness and refresh monitoring.

## Project Overview

Traditional data pipelines often require engineers to explicitly manage transformation order, scheduling, and dependencies.

Snowflake Dynamic Tables provide a declarative alternative: transformations are defined using SQL, while Snowflake derives dependencies between Dynamic Tables and manages refresh coordination based on configured freshness targets.

This project demonstrates that approach with a small customer-order analytics pipeline.

## Architecture

```text
Python UDTFs
     │
     ▼
RAW_DB
├── CUSTOMERS
├── PRODUCTS
└── ORDERS
     │
     ▼
ANALYTICS_DB
├── STG_CUSTOMERS_DT
├── STG_ORDERS_DT
│        │
│        ▼
└── FCT_CUSTOMER_ORDERS_DT
```

The pipeline follows three logical layers:

### Raw Layer

Synthetic source data is generated using Python User-Defined Table Functions (UDTFs) and stored in:

* `RAW_DB.PUBLIC.CUSTOMERS`
* `RAW_DB.PUBLIC.PRODUCTS`
* `RAW_DB.PUBLIC.ORDERS`

The `ORDERS` table contains purchase information in a Snowflake `VARIANT` column.

### Staging Layer

Two Dynamic Tables transform the raw data:

* `STG_CUSTOMERS_DT`
* `STG_ORDERS_DT`

The staging transformations perform operations such as:

* column renaming,
* data type conversion,
* extraction of fields from semi-structured `VARIANT` data.

For example, purchase information is transformed into relational fields such as:

```text
PRODUCT_ID
ORDER_PRICE
QUANTITY
ORDER_DATE
```

### Fact Layer

`FCT_CUSTOMER_ORDERS_DT` combines customer and order information from the two staging Dynamic Tables.

```text
STG_CUSTOMERS_DT ──┐
                   ├── FCT_CUSTOMER_ORDERS_DT
STG_ORDERS_DT ─────┘
```

Snowflake derives this dependency graph from the SQL definitions rather than requiring the execution order to be manually orchestrated.

## Data Flow

```text
Synthetic Data Generation
        ↓
Raw Snowflake Tables
        ↓
Staging Dynamic Tables
        ↓
Semi-structured Data Transformation
        ↓
Customer + Order Join
        ↓
Fact Dynamic Table
        ↓
Analytics-ready Data
```

## Technologies Used

* **Snowflake**
* **Snowflake Dynamic Tables**
* **SQL**
* **Python UDTFs**
* **Snowflake VARIANT**
* **Faker**
* **Snowsight**
* **Snowflake Information Schema**

## Repository Structure

```text
.
├── README.md
├── .gitignore
├── docs/
│   └── architecture.md
└── sql/
    ├── 01_environment_setup.sql
    ├── 02_raw_data_generation.sql
    ├── 03_staging_dynamic_tables.sql
    ├── 04_fact_dynamic_table.sql
    ├── 05_data_quality.sql
    ├── 06_monitoring.sql
    └── 07_cleanup.sql
```

## Implementation

### 1. Environment Setup

The project creates:

* `COMPUTE_WH`
* `RAW_DB`
* `ANALYTICS_DB`

The warehouse provides compute resources for data generation, SQL transformations, and Dynamic Table refresh operations.

### 2. Synthetic Raw Data

Python UDTFs using the `Faker` package generate sample:

* customers,
* products,
* customer orders.

The generated records are materialized into regular Snowflake tables inside `RAW_DB.PUBLIC`.

### 3. Staging Dynamic Tables

The raw customer and order datasets are transformed into:

```text
STG_CUSTOMERS_DT
STG_ORDERS_DT
```

The order staging transformation also converts semi-structured purchase data from a `VARIANT` column into relational columns.

### 4. Fact Dynamic Table

The staging models are joined to create:

```text
FCT_CUSTOMER_ORDERS_DT
```

Because the fact model references the staging Dynamic Tables, Snowflake can derive the transformation dependencies automatically.

### 5. Data Quality

A simple data-quality rule is applied to the fact model:

```sql
WHERE o.product_id IS NOT NULL
```

This excludes records without a valid product identifier from the final result.

Additional SQL checks can be used to inspect null values across the resulting fact model.

## Dynamic Table Freshness

Dynamic Tables support `TARGET_LAG` to describe the desired freshness of their data.

Intermediate Dynamic Tables can use:

```sql
TARGET_LAG = DOWNSTREAM
```

A specific freshness target can also be configured:

```sql
TARGET_LAG = '5 minutes'
```

`TARGET_LAG` represents a **data freshness target**, not a strict instruction to execute the transformation every five minutes.

Snowflake manages refresh scheduling based on the Dynamic Table dependency graph and configured freshness requirements.

## Monitoring

Dynamic Table configuration can be inspected with:

```sql
SHOW DYNAMIC TABLES IN SCHEMA ANALYTICS_DB.PUBLIC;
```

Refresh history can be queried through:

```sql
INFORMATION_SCHEMA.DYNAMIC_TABLE_REFRESH_HISTORY()
```

This provides visibility into information such as:

* refresh state,
* refresh action,
* refresh trigger,
* refresh start and end times,
* target lag,
* state or error messages.

## How to Run

Run the SQL files sequentially:

```text
01_environment_setup.sql
        ↓
02_raw_data_generation.sql
        ↓
03_staging_dynamic_tables.sql
        ↓
04_fact_dynamic_table.sql
        ↓
05_data_quality.sql
        ↓
06_monitoring.sql
```

The cleanup script should only be executed when the Snowflake resources created for the project are no longer required.

```text
07_cleanup.sql
```

## Cleanup

The project includes:

```text
sql/07_cleanup.sql
```

which removes the tutorial resources:

* `ANALYTICS_DB`
* `RAW_DB`
* `COMPUTE_WH`

Run this script only when the project resources are no longer needed.

## What I Learned

This project demonstrates several transferable data engineering concepts:

* how declarative data pipelines differ from explicitly orchestrated pipelines,
* how Snowflake Dynamic Tables derive dependencies from SQL transformations,
* how to design a simple Raw → Staging → Fact architecture,
* how semi-structured `VARIANT` data can be transformed into relational columns,
* how Dynamic Tables can be chained into a dependency graph,
* how `TARGET_LAG` represents a freshness objective rather than a fixed execution interval,
* how downstream-driven refresh behavior can be used for intermediate transformations,
* how Dynamic Table refresh activity can be monitored through Snowflake metadata,
* how basic data-quality rules can be incorporated into transformation logic.

## Acknowledgements

This project was developed as a hands-on implementation based on the Snowflake developer guide **Create Declarative Data Pipelines with Dynamic Tables**, with the implementation organized and documented as a reproducible data engineering portfolio project.
