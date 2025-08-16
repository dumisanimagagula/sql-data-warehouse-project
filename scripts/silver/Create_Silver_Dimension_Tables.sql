-- ============================================================================
-- DDL Script: Create Silver Dimension Tables
-- Purpose: Create cleaned and standardized dimension tables from bronze layer
-- ============================================================================

-- Set database context
USE [DataWarehouse];

-- Ensure schema exists
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver')
    EXEC('CREATE SCHEMA silver');

-- Begin transaction block for atomic execution
BEGIN TRY
    BEGIN TRANSACTION;

    ----------------------------------------------------------------------------
    -- Silver Customer Dimension Table (SCD Type 1)
    ----------------------------------------------------------------------------
    IF OBJECT_ID('silver.dim_customer', 'U') IS NOT NULL
        DROP TABLE silver.dim_customer;

    CREATE TABLE silver.dim_customer (
        customer_sk         INT IDENTITY(1,1) PRIMARY KEY,
        customer_id         INT NOT NULL,
        customer_key        NVARCHAR(50),
        first_name          NVARCHAR(100),
        last_name           NVARCHAR(100),
        full_name           NVARCHAR(201), -- Computed: first_name + last_name
        marital_status      NVARCHAR(20),
        gender              NVARCHAR(10),
        birth_date          DATE,
        country             NVARCHAR(100),
        age_group           NVARCHAR(20), -- Computed based on birth_date
        create_date         DATE,
        load_timestamp      DATETIME DEFAULT GETDATE(),
        source_system       NVARCHAR(20) DEFAULT 'CRM'
    );

    ----------------------------------------------------------------------------
    -- Silver Product Dimension Table (SCD Type 1)
    ----------------------------------------------------------------------------
    IF OBJECT_ID('silver.dim_product', 'U') IS NOT NULL
        DROP TABLE silver.dim_product;

    CREATE TABLE silver.dim_product (
        product_sk          INT IDENTITY(1,1) PRIMARY KEY,
        product_id          INT NOT NULL,
        product_key         NVARCHAR(50),
        product_name        NVARCHAR(100),
        product_cost        DECIMAL(10,2),
        product_line        NVARCHAR(50),
        category_id         NVARCHAR(50),
        category_name       NVARCHAR(50),
        subcategory_name    NVARCHAR(50),
        maintenance_flag    NVARCHAR(20),
        start_date          DATETIME,
        end_date            DATETIME,
        is_active           BIT, -- Computed: end_date IS NULL OR end_date > GETDATE()
        load_timestamp      DATETIME DEFAULT GETDATE(),
        source_system       NVARCHAR(20) DEFAULT 'CRM'
    );

    ----------------------------------------------------------------------------
    -- Silver Date Dimension Table
    ----------------------------------------------------------------------------
    IF OBJECT_ID('silver.dim_date', 'U') IS NOT NULL
        DROP TABLE silver.dim_date;

    CREATE TABLE silver.dim_date (
        date_sk             INT IDENTITY(1,1) PRIMARY KEY,
        date_key            INT NOT NULL, -- YYYYMMDD format
        full_date           DATE NOT NULL,
        day_of_week         TINYINT,
        day_name            NVARCHAR(10),
        day_of_month        TINYINT,
        day_of_year         SMALLINT,
        week_of_year        TINYINT,
        month_number        TINYINT,
        month_name          NVARCHAR(10),
        quarter_number      TINYINT,
        quarter_name        NVARCHAR(2),
        year_number         SMALLINT,
        is_weekend          BIT,
        load_timestamp      DATETIME DEFAULT GETDATE()
    );

    -- Commit if everything succeeds
    COMMIT TRANSACTION;
    PRINT '✅ Silver dimension tables created successfully.';

END TRY
BEGIN CATCH
    -- Rollback and report error if any part fails
    ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;