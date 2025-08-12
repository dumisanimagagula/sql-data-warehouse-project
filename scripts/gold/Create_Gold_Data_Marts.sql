-- ============================================================================
-- DDL Script: Create Gold Data Marts
-- Purpose: Create reporting-ready fact tables and aggregated views
-- ============================================================================

-- Set database context
USE [DataWarehouse];

-- Ensure schema exists
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'gold')
    EXEC('CREATE SCHEMA gold');

-- Begin transaction block for atomic execution
BEGIN TRY
    BEGIN TRANSACTION;

    ----------------------------------------------------------------------------
    -- Gold Sales Fact Table
    ----------------------------------------------------------------------------
    IF OBJECT_ID('gold.fact_sales', 'U') IS NOT NULL
        DROP TABLE gold.fact_sales;

    CREATE TABLE gold.fact_sales (
        sales_fact_sk       BIGINT IDENTITY(1,1) PRIMARY KEY,
        customer_sk         INT,
        product_sk          INT,
        order_date_sk       INT,
        ship_date_sk        INT,
        due_date_sk         INT,
        sales_order_number  NVARCHAR(50),
        quantity_sold       INT,
        unit_price          DECIMAL(10,2),
        total_sales         DECIMAL(12,2),
        load_timestamp      DATETIME DEFAULT GETDATE(),
        
        -- Foreign key constraints (optional, for referential integrity)
        CONSTRAINT FK_fact_sales_customer FOREIGN KEY (customer_sk) 
            REFERENCES silver.dim_customer(customer_sk),
        CONSTRAINT FK_fact_sales_product FOREIGN KEY (product_sk) 
            REFERENCES silver.dim_product(product_sk),
        CONSTRAINT FK_fact_sales_order_date FOREIGN KEY (order_date_sk) 
            REFERENCES silver.dim_date(date_sk),
        CONSTRAINT FK_fact_sales_ship_date FOREIGN KEY (ship_date_sk) 
            REFERENCES silver.dim_date(date_sk),
        CONSTRAINT FK_fact_sales_due_date FOREIGN KEY (due_date_sk) 
            REFERENCES silver.dim_date(date_sk)
    );

    -- Create indexes for better query performance
    CREATE NONCLUSTERED INDEX IX_fact_sales_customer ON gold.fact_sales(customer_sk);
    CREATE NONCLUSTERED INDEX IX_fact_sales_product ON gold.fact_sales(product_sk);
    CREATE NONCLUSTERED INDEX IX_fact_sales_order_date ON gold.fact_sales(order_date_sk);

    ----------------------------------------------------------------------------
    -- Gold Customer Sales Summary (Aggregated Table)
    ----------------------------------------------------------------------------
    IF OBJECT_ID('gold.customer_sales_summary', 'U') IS NOT NULL
        DROP TABLE gold.customer_sales_summary;

    CREATE TABLE gold.customer_sales_summary (
        customer_sk         INT PRIMARY KEY,
        customer_name       NVARCHAR(201),
        country             NVARCHAR(100),
        age_group           NVARCHAR(20),
        total_orders        INT,
        total_quantity      INT,
        total_sales_amount  DECIMAL(15,2),
        avg_order_value     DECIMAL(10,2),
        first_order_date    DATE,
        last_order_date     DATE,
        load_timestamp      DATETIME DEFAULT GETDATE(),
        
        CONSTRAINT FK_customer_summary_customer FOREIGN KEY (customer_sk) 
            REFERENCES silver.dim_customer(customer_sk)
    );

    ----------------------------------------------------------------------------
    -- Gold Product Sales Summary (Aggregated Table)
    ----------------------------------------------------------------------------
    IF OBJECT_ID('gold.product_sales_summary', 'U') IS NOT NULL
        DROP TABLE gold.product_sales_summary;

    CREATE TABLE gold.product_sales_summary (
        product_sk          INT PRIMARY KEY,
        product_name        NVARCHAR(100),
        product_line        NVARCHAR(50),
        category_name       NVARCHAR(50),
        total_orders        INT,
        total_quantity      INT,
        total_sales_amount  DECIMAL(15,2),
        avg_unit_price      DECIMAL(10,2),
        load_timestamp      DATETIME DEFAULT GETDATE(),
        
        CONSTRAINT FK_product_summary_product FOREIGN KEY (product_sk) 
            REFERENCES silver.dim_product(product_sk)
    );

    -- Commit if everything succeeds
    COMMIT TRANSACTION;
    PRINT '✅ Gold data mart tables created successfully.';

END TRY
BEGIN CATCH
    -- Rollback and report error if any part fails
    ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;