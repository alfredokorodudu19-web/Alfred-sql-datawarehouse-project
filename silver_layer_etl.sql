

CREATE OR ALTER PROCEDURE silver.load_silver 
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RowsInserted INT;

    PRINT '==============================';
    PRINT 'Silver Layer ETL Started';
    PRINT '==============================';

    ---------------------------------------------------
    -- CUSTOMERS
    ---------------------------------------------------
    PRINT 'Step 1: Loading Customers Table';

    TRUNCATE TABLE silver.crm_customers_info;
    PRINT 'Customers table truncated';

    INSERT INTO silver.crm_customers_info(
        customer_id,
        FirstName,
        LastName,
        clean_date,
        clean_region,
        clean_email
    )
    SELECT
        customer_id,
        UPPER(SUBSTRING(first_name,1,1)) + LOWER(SUBSTRING(first_name,2,LEN(first_name))) AS FirstName,
        UPPER(SUBSTRING(last_name,1,1)) + LOWER(SUBSTRING(last_name,2,LEN(last_name))) AS LastName,
        COALESCE(
            TRY_CONVERT(DATE,signup_date,23),
            TRY_CONVERT(DATE,signup_date,103),
            TRY_CONVERT(DATE,signup_date,110),
            TRY_CONVERT(DATE,signup_date,111)
        ) AS clean_date,
        CASE 
            WHEN TRIM(region) = '' OR region IS NULL THEN NULL
            ELSE UPPER(SUBSTRING(TRIM(region),1,1)) + LOWER(SUBSTRING(TRIM(region),2,LEN(TRIM(region))))
        END AS clean_region,
        NULLIF(TRIM(email), '') AS clean_email
    FROM
    (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY customer_id 
                   ORDER BY COALESCE(
                       TRY_CONVERT(DATE,signup_date,23),
                       TRY_CONVERT(DATE,signup_date,103),
                       TRY_CONVERT(DATE,signup_date,110),
                       TRY_CONVERT(DATE,signup_date,111)
                   ) DESC
               ) AS Ranking
        FROM customers_plain
    ) t
    WHERE Ranking = 1;

    SET @RowsInserted = @@ROWCOUNT;
    PRINT 'Customers loaded: ' + CAST(@RowsInserted AS VARCHAR(20));

    ---------------------------------------------------
    -- ORDERS
    ---------------------------------------------------
    PRINT 'Step 2: Loading Orders Table';

    TRUNCATE TABLE silver.crm_orders_info;
    PRINT 'Orders table truncated';

    INSERT INTO silver.crm_orders_info(  
        order_id,
        customer_id,
        product_id,
        clean_quantity,
        clean_order_date,
        clean_payment_method,
        clean_rating
    )
    SELECT
        order_id,
        customer_id,
        product_id,
        CASE
            WHEN LOWER(TRIM(quantity)) = 'two' THEN 2
            WHEN LOWER(TRIM(quantity)) = 'three' THEN 3
            ELSE TRY_CAST(quantity AS INT)
        END AS clean_quantity,
        COALESCE(
            TRY_CONVERT(DATE,order_date,23),
            TRY_CONVERT(DATE,order_date,103),
            TRY_CONVERT(DATE,order_date,110),
            TRY_CONVERT(DATE,order_date,111)
        ) AS clean_order_date,
        CASE
            WHEN TRIM(payment_method) = '' OR payment_method IS NULL THEN NULL
            ELSE UPPER(SUBSTRING(TRIM(payment_method),1,1)) + 
                 LOWER(SUBSTRING(TRIM(payment_method),2,LEN(TRIM(payment_method))))
        END AS clean_payment_method,
        CASE
            WHEN TRIM(rating) = '' OR rating IS NULL THEN NULL
            WHEN TRY_CAST(rating AS INT) BETWEEN 1 AND 5 THEN TRY_CAST(rating AS INT)
            ELSE NULL
        END AS clean_rating
    FROM
    (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY order_id 
                   ORDER BY COALESCE(
                       TRY_CONVERT(DATE,order_date,23),
                       TRY_CONVERT(DATE,order_date,103),
                       TRY_CONVERT(DATE,order_date,110),
                       TRY_CONVERT(DATE,order_date,111)
                   ) DESC
               ) AS Ranking
        FROM orders_plain
    ) t
    WHERE Ranking = 1;

    SET @RowsInserted = @@ROWCOUNT;
    PRINT 'Orders loaded: ' + CAST(@RowsInserted AS VARCHAR(20));

    ---------------------------------------------------
    -- PRODUCTS
    ---------------------------------------------------
    PRINT 'Step 3: Loading Products Table';

    TRUNCATE TABLE silver.crm_products_info;
    PRINT 'Products table truncated';

    INSERT INTO silver.crm_products_info(
        product_id,
        product_name,
        clean_category,
        clean_price
    )
    SELECT
        TRIM(product_id),
        TRIM(product_name),
        CASE
            WHEN TRIM(category) = '' OR category IS NULL THEN NULL
            ELSE UPPER(SUBSTRING(TRIM(category),1,1)) +
                 LOWER(SUBSTRING(TRIM(category),2,LEN(TRIM(category))))
        END AS clean_category,
        CASE
            WHEN TRIM(price) = '' OR TRY_CAST(price AS DECIMAL(10,2)) < 0 THEN NULL
            ELSE TRY_CAST(price AS DECIMAL(10,2))
        END AS clean_price
    FROM products_plain;

    SET @RowsInserted = @@ROWCOUNT;
    PRINT 'Products loaded: ' + CAST(@RowsInserted AS VARCHAR(20));

    ---------------------------------------------------
    PRINT '==============================';
    PRINT 'Silver Layer ETL Completed';
    PRINT '==============================';

END;
GO
