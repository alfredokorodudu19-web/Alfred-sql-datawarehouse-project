# Alfred-sql-datawarehouse-project
Welcome to Alfred's world of Data Engineering. 
I'm building a datawarehouse with SQL server, including ETL process, data modelling and analytics.
# SQL Data Warehouse ETL Pipeline

## Overview

This project demonstrates a complete **ETL (Extract, Transform, Load) pipeline** built using SQL Server.

The pipeline processes raw CSV data and transforms it into clean, structured datasets using the **Medallion Architecture (Bronze → Silver → Gold)**.

The focus of this project is on **data cleaning, transformation, and data quality handling**, which are core responsibilities of a data engineer.

---

## Architecture

The pipeline follows a three-layer architecture:

```
Bronze Layer → Silver Layer → Gold Layer
Raw Data        Clean Data       Business Data
```

### Bronze Layer
- Raw data loaded directly from CSV files
- No transformations applied
- Tables:
  - `customers_plain`
  - `orders_plain`
  - `products_plain`

---

### Silver Layer
- Data cleaning and standardization
- Duplicate removal
- Handling missing and invalid values

Tables:
- `silver.crm_customers_info`
- `silver.crm_orders_info`
- `silver.crm_products_info`

---

### Gold Layer (Planned / Next Step)
- Aggregated datasets for analytics
- Business-ready tables

Examples:
- `gold.sales_summary`
- `gold.customer_metrics`
- `gold.product_performance`

---

## ETL Process

The ETL pipeline is implemented using a stored procedure:

```sql
EXEC silver.load_silver;
```

### Steps performed:

1. Truncate existing Silver tables
2. Clean raw data from Bronze layer
3. Remove duplicates using `ROW_NUMBER()`
4. Standardize text fields (names, categories, regions)
5. Convert inconsistent date formats
6. Handle missing and invalid values
7. Load cleaned data into Silver tables

---

## Data Cleaning Techniques Used

This project applies several important SQL data cleaning techniques:

- `TRIM()` → remove unwanted spaces  
- `UPPER()` / `LOWER()` → standardize text  
- `SUBSTRING()` → proper casing  
- `TRY_CAST()` / `TRY_CONVERT()` → handle invalid data types  
- `COALESCE()` → handle multiple date formats  
- `NULLIF()` → convert empty values to NULL  
- `CASE` statements → conditional transformations  
- `ROW_NUMBER()` → deduplication  

---

## Example Transformations

### Name Standardization
```
mARY → Mary
DAVID → David
```

### Date Cleaning
Handles multiple formats:
- `YYYY-MM-DD`
- `DD/MM/YYYY`
- `MM-DD-YYYY`
- `YYYY/MM/DD`

### Quantity Cleaning
```
two → 2
three → 3
```

### Price Cleaning
- Negative values → NULL  
- Invalid values → NULL  
- Converted to `DECIMAL(10,2)`

---

## Data Quality Handling

The pipeline ensures:

- No duplicate `customer_id`, `order_id`, or `product_id`
- Valid numeric conversions
- Standardized text values
- Proper handling of NULL and missing data
- Clean and consistent datasets for downstream use

---

## Logging & Monitoring

The ETL process includes `PRINT` statements to track execution:

- Step-by-step process visibility
- Row counts inserted into each table
- Easy debugging and monitoring

---

## Tools & Technologies

- SQL Server
- T-SQL
- CSV datasets
- GitHub (project documentation)

---

## Project Structure

```
sql-data-warehouse-project/

datasets/
    customers.csv
    orders.csv
    products.csv

sql/
    load_silver.sql
    silver_customers.sql
    silver_orders.sql
    silver_products.sql

README.md
```

---

## Key Skills Demonstrated

- SQL Data Cleaning
- ETL Pipeline Design
- Data Transformation
- Window Functions (`ROW_NUMBER`)
- Handling Dirty Data
- Data Modeling Basics
- Stored Procedures

---

## Next Improvements

- Build Gold layer analytical tables
- Add error handling (`TRY...CATCH`)
- Implement logging tables
- Add scheduling (SQL Agent / Airflow)
- Create dashboards (Power BI / Tableau)

---

## Author
My name is Okorodudu Alfred,I'm an aspiring Data Engineer.
This project is part of my journey into **Data Engineering**, focusing on building real-world ETL pipelines and mastering SQL-based data transformations.
