-- ============================================================================
-- DML Script: Populate Silver Dimension Tables
-- Purpose: Transform and load cleaned data from bronze to silver layer
-- ============================================================================

-- Set database context
USE [DataWarehouse];

-- Begin transaction block for atomic execution
BEGIN TRY
    BEGIN TRANSACTION;

    ----------------------------------------------------------------------------
    -- Populate Silver Customer Dimension
    ----------------------------------------------------------------------------
    -- Clear existing data
    TRUNCATE TABLE silver.dim_customer;

    -- Insert transformed customer data
    INSERT INTO silver.dim_customer (
        customer_id,
        customer_key, 
        first_name,
        last_name,
        full_name,
        marital_status,
        gender,
        birth_date,
        country,
        age_group,
        create_date,
        source_system
    )
    SELECT DISTINCT
        c.customer_id,
        c.customer_key,
        LTRIM(RTRIM(c.first_name)) AS first_name,
        LTRIM(RTRIM(c.last_name)) AS last_name,
        LTRIM(RTRIM(c.first_name)) + ' ' + LTRIM(RTRIM(c.last_name)) AS full_name,
        CASE 
            WHEN UPPER(c.marital_status) IN ('M', 'MARRIED') THEN 'Married'
            WHEN UPPER(c.marital_status) IN ('S', 'SINGLE') THEN 'Single'
            ELSE 'Unknown'
        END AS marital_status,
        CASE 
            WHEN UPPER(c.gender) IN ('M', 'MALE') THEN 'Male'
            WHEN UPPER(c.gender) IN ('F', 'FEMALE') THEN 'Female'
            ELSE 'Unknown'
        END AS gender,
        d.birth_date,
        COALESCE(l.country, 'Unknown') AS country,
        CASE 
            WHEN DATEDIFF(YEAR, d.birth_date, GETDATE()) < 25 THEN '18-24'
            WHEN DATEDIFF(YEAR, d.birth_date, GETDATE()) < 35 THEN '25-34'
            WHEN DATEDIFF(YEAR, d.birth_date, GETDATE()) < 45 THEN '35-44'
            WHEN DATEDIFF(YEAR, d.birth_date, GETDATE()) < 55 THEN '45-54'
            WHEN DATEDIFF(YEAR, d.birth_date, GETDATE()) < 65 THEN '55-64'
            ELSE '65+'
        END AS age_group,
        c.create_date,
        'CRM' AS source_system
    FROM bronze.crm_customer_info c
    LEFT JOIN bronze.erp_customer_demographics d ON CAST(c.customer_id AS NVARCHAR(50)) = d.customer_id
    LEFT JOIN bronze.erp_location_info l ON CAST(c.customer_id AS NVARCHAR(50)) = l.customer_id
    WHERE c.customer_id IS NOT NULL;

    ----------------------------------------------------------------------------
    -- Populate Silver Product Dimension
    ----------------------------------------------------------------------------
    -- Clear existing data
    TRUNCATE TABLE silver.dim_product;

    -- Insert transformed product data
    INSERT INTO silver.dim_product (
        product_id,
        product_key,
        product_name,
        product_cost,
        product_line,
        category_id,
        category_name,
        subcategory_name,
        maintenance_flag,
        start_date,
        end_date,
        is_active,
        source_system
    )
    SELECT DISTINCT
        p.product_id,
        p.product_key,
        LTRIM(RTRIM(p.product_name)) AS product_name,
        p.product_cost,
        LTRIM(RTRIM(p.product_line)) AS product_line,
        c.category_id,
        LTRIM(RTRIM(c.category_name)) AS category_name,
        LTRIM(RTRIM(c.subcategory_name)) AS subcategory_name,
        COALESCE(c.maintenance_flag, 'Unknown') AS maintenance_flag,
        p.start_date,
        p.end_date,
        CASE 
            WHEN p.end_date IS NULL OR p.end_date > GETDATE() THEN 1 
            ELSE 0 
        END AS is_active,
        'CRM' AS source_system
    FROM bronze.crm_product_info p
    LEFT JOIN bronze.erp_product_category c ON p.product_line = c.category_name
    WHERE p.product_id IS NOT NULL;

    ----------------------------------------------------------------------------
    -- Populate Silver Date Dimension (Sample dates for testing)
    ----------------------------------------------------------------------------
    -- Clear existing data
    TRUNCATE TABLE silver.dim_date;

    -- Insert date range (2020-2025 for testing purposes)
    WITH DateRange AS (
        SELECT CAST('2020-01-01' AS DATE) AS DateValue
        UNION ALL
        SELECT DATEADD(DAY, 1, DateValue)
        FROM DateRange
        WHERE DateValue < '2025-12-31'
    )
    INSERT INTO silver.dim_date (
        date_key,
        full_date,
        day_of_week,
        day_name,
        day_of_month,
        day_of_year,
        week_of_year,
        month_number,
        month_name,
        quarter_number,
        quarter_name,
        year_number,
        is_weekend
    )
    SELECT 
        YEAR(DateValue) * 10000 + MONTH(DateValue) * 100 + DAY(DateValue) AS date_key,
        DateValue AS full_date,
        DATEPART(WEEKDAY, DateValue) AS day_of_week,
        DATENAME(WEEKDAY, DateValue) AS day_name,
        DAY(DateValue) AS day_of_month,
        DATEPART(DAYOFYEAR, DateValue) AS day_of_year,
        DATEPART(WEEK, DateValue) AS week_of_year,
        MONTH(DateValue) AS month_number,
        DATENAME(MONTH, DateValue) AS month_name,
        DATEPART(QUARTER, DateValue) AS quarter_number,
        'Q' + CAST(DATEPART(QUARTER, DateValue) AS VARCHAR(1)) AS quarter_name,
        YEAR(DateValue) AS year_number,
        CASE WHEN DATEPART(WEEKDAY, DateValue) IN (1, 7) THEN 1 ELSE 0 END AS is_weekend
    FROM DateRange
    OPTION (MAXRECURSION 0);

    -- Commit if everything succeeds
    COMMIT TRANSACTION;
    PRINT '✅ Silver dimension tables populated successfully.';

    -- Display row counts for verification
    SELECT 'dim_customer' AS table_name, COUNT(*) AS row_count FROM silver.dim_customer
    UNION ALL
    SELECT 'dim_product' AS table_name, COUNT(*) AS row_count FROM silver.dim_product
    UNION ALL
    SELECT 'dim_date' AS table_name, COUNT(*) AS row_count FROM silver.dim_date;

END TRY
BEGIN CATCH
    -- Rollback and report error if any part fails
    ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;