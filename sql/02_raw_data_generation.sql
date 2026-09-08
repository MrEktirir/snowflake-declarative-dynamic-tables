-- ============================================================
-- Snowflake Declarative Dynamic Tables Pipeline
-- 02 - Raw Data Generation
-- ============================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE RAW_DB;
USE SCHEMA PUBLIC;


-- ------------------------------------------------------------
-- Customer Data Generator
-- ------------------------------------------------------------

CREATE OR REPLACE FUNCTION gen_cust_info(num_records NUMBER)
RETURNS TABLE (
    custid NUMBER(10),
    cname VARCHAR(100),
    spendlimit NUMBER(10,2)
)
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
HANDLER = 'CustTab'
PACKAGES = ('Faker')
AS
$$
from faker import Faker
import random

fake = Faker()

class CustTab:
    def process(self, num_records):
        customer_id = 1000

        for _ in range(num_records):
            custid = customer_id + 1
            cname = fake.name()
            spendlimit = round(random.uniform(1000, 10000), 2)

            customer_id += 1

            yield (custid, cname, spendlimit)
$$;


-- ------------------------------------------------------------
-- Product Data Generator
-- ------------------------------------------------------------

CREATE OR REPLACE FUNCTION gen_prod_inv(num_records NUMBER)
RETURNS TABLE (
    pid NUMBER(10),
    pname VARCHAR(100),
    stock NUMBER(10,2),
    stockdate DATE
)
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
HANDLER = 'ProdTab'
PACKAGES = ('Faker')
AS
$$
from faker import Faker
import random
from datetime import datetime, timedelta

fake = Faker()

class ProdTab:
    def process(self, num_records):
        product_id = 100

        for _ in range(num_records):
            pid = product_id + 1
            pname = fake.catch_phrase()
            stock = round(random.uniform(500, 1000), 0)

            current_date = datetime.now()
            min_date = current_date - timedelta(days=90)

            stockdate = fake.date_between_dates(
                date_start=min_date,
                date_end=current_date
            )

            product_id += 1

            yield (pid, pname, stock, stockdate)
$$;


-- ------------------------------------------------------------
-- Customer Order Data Generator
-- ------------------------------------------------------------

CREATE OR REPLACE FUNCTION gen_cust_purchase(
    num_records NUMBER,
    ndays NUMBER
)
RETURNS TABLE (
    custid NUMBER(10),
    purchase VARIANT
)
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
HANDLER = 'genCustPurchase'
PACKAGES = ('Faker')
AS
$$
from faker import Faker
import random
from datetime import datetime, timedelta

fake = Faker()

class genCustPurchase:
    def process(self, num_records, ndays):
        for _ in range(num_records):

            c_id = fake.random_int(min=1001, max=1999)

            current_date = datetime.now()
            min_date = current_date - timedelta(days=ndays)

            pdate = fake.date_between_dates(
                date_start=min_date,
                date_end=current_date
            )

            purchase = {
                'prodid': fake.random_int(min=101, max=199),
                'quantity': fake.random_int(min=1, max=5),
                'purchase_amount': round(random.uniform(10, 1000), 2),
                'purchase_date': pdate
            }

            yield (c_id, purchase)
$$;


-- ------------------------------------------------------------
-- Generate Raw Tables
-- ------------------------------------------------------------

CREATE OR REPLACE TABLE CUSTOMERS AS
SELECT *
FROM TABLE(gen_cust_info(1000))
ORDER BY 1;

CREATE OR REPLACE TABLE PRODUCTS AS
SELECT *
FROM TABLE(gen_prod_inv(100))
ORDER BY 1;

CREATE OR REPLACE TABLE ORDERS AS
SELECT *
FROM TABLE(gen_cust_purchase(10000, 10));


-- ------------------------------------------------------------
-- Verification
-- ------------------------------------------------------------

SELECT COUNT(*) AS customer_count
FROM CUSTOMERS;

SELECT COUNT(*) AS product_count
FROM PRODUCTS;

SELECT COUNT(*) AS order_count
FROM ORDERS;

SELECT *
FROM CUSTOMERS
LIMIT 10;

SELECT *
FROM PRODUCTS
LIMIT 10;

SELECT *
FROM ORDERS
LIMIT 10;