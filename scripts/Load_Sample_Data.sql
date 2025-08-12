-- ============================================================================
-- Sample Data Loading Script
-- Purpose: Insert sample data for testing the complete data warehouse pipeline
-- ============================================================================

-- Set database context
USE [DataWarehouse];

PRINT '📦 Loading Sample Data for Testing...';
PRINT '====================================';

-- Begin transaction block for atomic execution
BEGIN TRY
    BEGIN TRANSACTION;

    ----------------------------------------------------------------------------
    -- Clear existing data (in reverse dependency order)
    ----------------------------------------------------------------------------
    PRINT 'Clearing existing data...';
    
    IF OBJECT_ID('gold.customer_sales_summary', 'U') IS NOT NULL
        TRUNCATE TABLE gold.customer_sales_summary;
    IF OBJECT_ID('gold.product_sales_summary', 'U') IS NOT NULL
        TRUNCATE TABLE gold.product_sales_summary;
    IF OBJECT_ID('gold.fact_sales', 'U') IS NOT NULL
        TRUNCATE TABLE gold.fact_sales;
    
    TRUNCATE TABLE bronze.crm_sales_details;
    TRUNCATE TABLE bronze.erp_location_info;
    TRUNCATE TABLE bronze.erp_customer_demographics;
    TRUNCATE TABLE bronze.erp_product_category;
    TRUNCATE TABLE bronze.crm_product_info;
    TRUNCATE TABLE bronze.crm_customer_info;

    ----------------------------------------------------------------------------
    -- Sample CRM Customer Data
    ----------------------------------------------------------------------------
    PRINT 'Loading CRM customer data...';
    
    INSERT INTO bronze.crm_customer_info (customer_id, customer_key, first_name, last_name, marital_status, gender, create_date)
    VALUES 
        (1, 'CUST001', 'John', 'Smith', 'M', 'M', '2020-01-15'),
        (2, 'CUST002', 'Sarah', 'Johnson', 'S', 'F', '2020-02-20'),
        (3, 'CUST003', 'Michael', 'Brown', 'M', 'M', '2020-03-10'),
        (4, 'CUST004', 'Emma', 'Davis', 'S', 'F', '2020-04-05'),
        (5, 'CUST005', 'James', 'Wilson', 'M', 'M', '2020-05-12'),
        (6, 'CUST006', 'Lisa', 'Miller', 'M', 'F', '2020-06-18'),
        (7, 'CUST007', 'David', 'Garcia', 'S', 'M', '2020-07-22'),
        (8, 'CUST008', 'Maria', 'Rodriguez', 'M', 'F', '2020-08-30'),
        (9, 'CUST009', 'Robert', 'Martinez', 'S', 'M', '2020-09-14'),
        (10, 'CUST010', 'Jennifer', 'Anderson', 'M', 'F', '2020-10-25');

    ----------------------------------------------------------------------------
    -- Sample ERP Customer Demographics
    ----------------------------------------------------------------------------
    PRINT 'Loading ERP customer demographics...';
    
    INSERT INTO bronze.erp_customer_demographics (customer_id, birth_date, gender)
    VALUES 
        ('1', '1985-03-15', 'M'),
        ('2', '1990-07-22', 'F'),
        ('3', '1982-11-08', 'M'),
        ('4', '1995-01-30', 'F'),
        ('5', '1988-09-12', 'M'),
        ('6', '1987-05-18', 'F'),
        ('7', '1992-12-03', 'M'),
        ('8', '1986-04-25', 'F'),
        ('9', '1984-08-17', 'M'),
        ('10', '1991-06-09', 'F');

    ----------------------------------------------------------------------------
    -- Sample ERP Location Data
    ----------------------------------------------------------------------------
    PRINT 'Loading ERP location data...';
    
    INSERT INTO bronze.erp_location_info (customer_id, country)
    VALUES 
        ('1', 'United States'),
        ('2', 'Canada'),
        ('3', 'United States'),
        ('4', 'United Kingdom'),
        ('5', 'Australia'),
        ('6', 'United States'),
        ('7', 'Germany'),
        ('8', 'France'),
        ('9', 'United States'),
        ('10', 'Canada');

    ----------------------------------------------------------------------------
    -- Sample Product Categories
    ----------------------------------------------------------------------------
    PRINT 'Loading ERP product categories...';
    
    INSERT INTO bronze.erp_product_category (category_id, category_name, subcategory_name, maintenance_flag)
    VALUES 
        ('CAT001', 'Electronics', 'Laptops', 'Active'),
        ('CAT002', 'Electronics', 'Smartphones', 'Active'),
        ('CAT003', 'Clothing', 'Shirts', 'Active'),
        ('CAT004', 'Clothing', 'Shoes', 'Active'),
        ('CAT005', 'Sports', 'Bicycles', 'Active');

    ----------------------------------------------------------------------------
    -- Sample CRM Product Data
    ----------------------------------------------------------------------------
    PRINT 'Loading CRM product data...';
    
    INSERT INTO bronze.crm_product_info (product_id, product_key, product_name, product_cost, product_line, start_date, end_date)
    VALUES 
        (101, 'PROD101', 'Business Laptop Pro', 1200.00, 'Electronics', '2020-01-01', NULL),
        (102, 'PROD102', 'Smartphone X1', 800.00, 'Electronics', '2020-01-01', NULL),
        (103, 'PROD103', 'Professional Shirt', 45.00, 'Clothing', '2020-01-01', NULL),
        (104, 'PROD104', 'Running Shoes', 120.00, 'Clothing', '2020-01-01', NULL),
        (105, 'PROD105', 'Mountain Bike', 500.00, 'Sports', '2020-01-01', NULL),
        (106, 'PROD106', 'Gaming Laptop', 1500.00, 'Electronics', '2020-06-01', NULL),
        (107, 'PROD107', 'Casual T-Shirt', 25.00, 'Clothing', '2020-03-01', NULL);

    ----------------------------------------------------------------------------
    -- Sample Sales Data
    ----------------------------------------------------------------------------
    PRINT 'Loading CRM sales data...';
    
    INSERT INTO bronze.crm_sales_details (sales_order_number, product_key, customer_id, order_date, ship_date, due_date, total_sales, quantity_sold, unit_price)
    VALUES 
        -- John Smith orders
        ('SO001', 'PROD101', 1, '2023-01-15', '2023-01-18', '2023-01-20', 1200.00, 1, 1200.00),
        ('SO002', 'PROD103', 1, '2023-02-20', '2023-02-22', '2023-02-25', 90.00, 2, 45.00),
        
        -- Sarah Johnson orders  
        ('SO003', 'PROD102', 2, '2023-01-25', '2023-01-28', '2023-01-30', 800.00, 1, 800.00),
        ('SO004', 'PROD104', 2, '2023-03-10', '2023-03-12', '2023-03-15', 120.00, 1, 120.00),
        
        -- Michael Brown orders
        ('SO005', 'PROD105', 3, '2023-02-14', '2023-02-16', '2023-02-18', 500.00, 1, 500.00),
        ('SO006', 'PROD106', 3, '2023-04-01', '2023-04-03', '2023-04-05', 1500.00, 1, 1500.00),
        
        -- Emma Davis orders
        ('SO007', 'PROD107', 4, '2023-03-20', '2023-03-22', '2023-03-25', 75.00, 3, 25.00),
        ('SO008', 'PROD102', 4, '2023-05-15', '2023-05-17', '2023-05-20', 800.00, 1, 800.00),
        
        -- James Wilson orders
        ('SO009', 'PROD101', 5, '2023-06-10', '2023-06-12', '2023-06-15', 2400.00, 2, 1200.00),
        
        -- Lisa Miller orders
        ('SO010', 'PROD103', 6, '2023-07-05', '2023-07-07', '2023-07-10', 135.00, 3, 45.00),
        ('SO011', 'PROD104', 6, '2023-08-20', '2023-08-22', '2023-08-25', 240.00, 2, 120.00),
        
        -- David Garcia orders
        ('SO012', 'PROD105', 7, '2023-09-12', '2023-09-14', '2023-09-17', 1000.00, 2, 500.00),
        
        -- Maria Rodriguez orders
        ('SO013', 'PROD106', 8, '2023-10-08', '2023-10-10', '2023-10-13', 1500.00, 1, 1500.00),
        ('SO014', 'PROD107', 8, '2023-11-15', '2023-11-17', '2023-11-20', 50.00, 2, 25.00),
        
        -- Robert Martinez orders
        ('SO015', 'PROD102', 9, '2023-12-01', '2023-12-03', '2023-12-06', 1600.00, 2, 800.00);

    -- Commit the sample data
    COMMIT TRANSACTION;
    PRINT '✅ Sample data loaded successfully!';

    -- Display summary
    PRINT '';
    PRINT 'Sample Data Summary:';
    PRINT '===================';
    SELECT 'crm_customer_info' AS table_name, COUNT(*) AS row_count FROM bronze.crm_customer_info
    UNION ALL
    SELECT 'erp_customer_demographics' AS table_name, COUNT(*) AS row_count FROM bronze.erp_customer_demographics
    UNION ALL
    SELECT 'erp_location_info' AS table_name, COUNT(*) AS row_count FROM bronze.erp_location_info
    UNION ALL
    SELECT 'erp_product_category' AS table_name, COUNT(*) AS row_count FROM bronze.erp_product_category
    UNION ALL
    SELECT 'crm_product_info' AS table_name, COUNT(*) AS row_count FROM bronze.crm_product_info
    UNION ALL
    SELECT 'crm_sales_details' AS table_name, COUNT(*) AS row_count FROM bronze.crm_sales_details;

    PRINT '';
    PRINT '🎯 Next Steps:';
    PRINT '1. Run scripts/silver/Populate_Silver_Dimensions.sql';
    PRINT '2. Run scripts/gold/Populate_Gold_Data_Marts.sql';
    PRINT '3. Run scripts/Test_Data_Warehouse.sql to validate everything';

END TRY
BEGIN CATCH
    -- Rollback and report error if any part fails
    ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;