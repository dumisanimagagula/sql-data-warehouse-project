-- ============================================================================
-- DDL Script: Create Bronze Tables
-- Purpose: Drops and recreates bronze staging tables with standard conventions
-- ============================================================================

-- Set database context
USE [DataWarehouse];
-- Ensure schema exists
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'bronze')
    EXEC('CREATE SCHEMA bronze');

-- Begin transaction block for atomic execution
BEGIN TRY
    BEGIN TRANSACTION;

    ----------------------------------------------------------------------------
    -- CRM Customer Info Table
    ----------------------------------------------------------------------------
    IF OBJECT_ID('bronze.crm_customer_info', 'U') IS NOT NULL
        DROP TABLE bronze.crm_customer_info;

    CREATE TABLE bronze.crm_customer_info (
        customer_id         INT,
        customer_key        NVARCHAR(50),
        first_name          NVARCHAR(100),
        last_name           NVARCHAR(100),
        marital_status      NVARCHAR(20),
        gender              NVARCHAR(10),
        create_date         DATE,
        load_timestamp      DATETIME DEFAULT GETDATE()
    );

    ----------------------------------------------------------------------------
    -- CRM Product Info Table
    ----------------------------------------------------------------------------
    IF OBJECT_ID('bronze.crm_product_info', 'U') IS NOT NULL
        DROP TABLE bronze.crm_product_info;

    CREATE TABLE bronze.crm_product_info (
        product_id          INT,
        product_key         NVARCHAR(50),
        product_name        NVARCHAR(100),
        product_cost        DECIMAL(10,2),
        product_line        NVARCHAR(50),
        start_date          DATETIME,
        end_date            DATETIME,
        load_timestamp      DATETIME DEFAULT GETDATE()
    );

    ----------------------------------------------------------------------------
    -- CRM Sales Details Table
    ----------------------------------------------------------------------------
    IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
        DROP TABLE bronze.crm_sales_details;

    CREATE TABLE bronze.crm_sales_details (
        sales_order_number  NVARCHAR(50),
        product_key         NVARCHAR(50),
        customer_id         INT,
        order_date          DATE,
        ship_date           DATE,
        due_date            DATE,
        total_sales         DECIMAL(12,2),
        quantity_sold       INT,
        unit_price          DECIMAL(10,2),
        load_timestamp      DATETIME DEFAULT GETDATE()
    );

    ----------------------------------------------------------------------------
    -- ERP Location Info Table
    ----------------------------------------------------------------------------
    IF OBJECT_ID('bronze.erp_location_info', 'U') IS NOT NULL
        DROP TABLE bronze.erp_location_info;

    CREATE TABLE bronze.erp_location_info (
        customer_id         NVARCHAR(50),
        country             NVARCHAR(100),
        load_timestamp      DATETIME DEFAULT GETDATE()
    );

    ----------------------------------------------------------------------------
    -- ERP Customer Demographics Table
    ----------------------------------------------------------------------------
    IF OBJECT_ID('bronze.erp_customer_demographics', 'U') IS NOT NULL
        DROP TABLE bronze.erp_customer_demographics;

    CREATE TABLE bronze.erp_customer_demographics (
        customer_id         NVARCHAR(50),
        birth_date          DATE,
        gender              NVARCHAR(10),
        load_timestamp      DATETIME DEFAULT GETDATE()
    );

    ----------------------------------------------------------------------------
    -- ERP Product Category Table
    ----------------------------------------------------------------------------
    IF OBJECT_ID('bronze.erp_product_category', 'U') IS NOT NULL
        DROP TABLE bronze.erp_product_category;

    CREATE TABLE bronze.erp_product_category (
        category_id         NVARCHAR(50),
        category_name       NVARCHAR(50),
        subcategory_name    NVARCHAR(50),
        maintenance_flag    NVARCHAR(20),
        load_timestamp      DATETIME DEFAULT GETDATE()
    );

    -- Commit if everything succeeds
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    -- Rollback and report error if any part fails
    ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;