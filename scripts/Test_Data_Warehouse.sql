-- ============================================================================
-- Data Warehouse Validation and Testing Script
-- Purpose: Comprehensive testing of the entire data warehouse pipeline
-- ============================================================================

-- Set database context
USE [DataWarehouse];

-- Validation results table
IF OBJECT_ID('tempdb..#ValidationResults', 'U') IS NOT NULL
    DROP TABLE #ValidationResults;

CREATE TABLE #ValidationResults (
    test_id         INT IDENTITY(1,1),
    test_category   NVARCHAR(50),
    test_name       NVARCHAR(100),
    expected_result NVARCHAR(100),
    actual_result   NVARCHAR(100),
    status          NVARCHAR(10), -- PASS/FAIL
    error_message   NVARCHAR(500)
);

PRINT '🧪 Starting Data Warehouse Validation Tests...';
PRINT '================================================';

BEGIN TRY

    ----------------------------------------------------------------------------
    -- Test 1: Schema Existence
    ----------------------------------------------------------------------------
    PRINT '1. Testing Schema Existence...';
    
    DECLARE @bronze_exists BIT = 0, @silver_exists BIT = 0, @gold_exists BIT = 0;
    
    IF EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'bronze') SET @bronze_exists = 1;
    IF EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver') SET @silver_exists = 1;
    IF EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'gold') SET @gold_exists = 1;
    
    INSERT INTO #ValidationResults (test_category, test_name, expected_result, actual_result, status)
    VALUES 
        ('Schema', 'Bronze Schema Exists', '1', CAST(@bronze_exists AS NVARCHAR), CASE WHEN @bronze_exists = 1 THEN 'PASS' ELSE 'FAIL' END),
        ('Schema', 'Silver Schema Exists', '1', CAST(@silver_exists AS NVARCHAR), CASE WHEN @silver_exists = 1 THEN 'PASS' ELSE 'FAIL' END),
        ('Schema', 'Gold Schema Exists', '1', CAST(@gold_exists AS NVARCHAR), CASE WHEN @gold_exists = 1 THEN 'PASS' ELSE 'FAIL' END);

    ----------------------------------------------------------------------------
    -- Test 2: Table Existence
    ----------------------------------------------------------------------------
    PRINT '2. Testing Table Existence...';
    
    -- Bronze tables
    DECLARE @bronze_customer BIT = CASE WHEN OBJECT_ID('bronze.crm_customer_info', 'U') IS NOT NULL THEN 1 ELSE 0 END;
    DECLARE @bronze_product BIT = CASE WHEN OBJECT_ID('bronze.crm_product_info', 'U') IS NOT NULL THEN 1 ELSE 0 END;
    DECLARE @bronze_sales BIT = CASE WHEN OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL THEN 1 ELSE 0 END;
    
    -- Silver tables
    DECLARE @silver_customer BIT = CASE WHEN OBJECT_ID('silver.dim_customer', 'U') IS NOT NULL THEN 1 ELSE 0 END;
    DECLARE @silver_product BIT = CASE WHEN OBJECT_ID('silver.dim_product', 'U') IS NOT NULL THEN 1 ELSE 0 END;
    DECLARE @silver_date BIT = CASE WHEN OBJECT_ID('silver.dim_date', 'U') IS NOT NULL THEN 1 ELSE 0 END;
    
    -- Gold tables
    DECLARE @gold_fact BIT = CASE WHEN OBJECT_ID('gold.fact_sales', 'U') IS NOT NULL THEN 1 ELSE 0 END;
    DECLARE @gold_customer_summary BIT = CASE WHEN OBJECT_ID('gold.customer_sales_summary', 'U') IS NOT NULL THEN 1 ELSE 0 END;
    DECLARE @gold_product_summary BIT = CASE WHEN OBJECT_ID('gold.product_sales_summary', 'U') IS NOT NULL THEN 1 ELSE 0 END;
    
    INSERT INTO #ValidationResults (test_category, test_name, expected_result, actual_result, status)
    VALUES 
        ('Table', 'Bronze Customer Table', '1', CAST(@bronze_customer AS NVARCHAR), CASE WHEN @bronze_customer = 1 THEN 'PASS' ELSE 'FAIL' END),
        ('Table', 'Bronze Product Table', '1', CAST(@bronze_product AS NVARCHAR), CASE WHEN @bronze_product = 1 THEN 'PASS' ELSE 'FAIL' END),
        ('Table', 'Bronze Sales Table', '1', CAST(@bronze_sales AS NVARCHAR), CASE WHEN @bronze_sales = 1 THEN 'PASS' ELSE 'FAIL' END),
        ('Table', 'Silver Customer Dimension', '1', CAST(@silver_customer AS NVARCHAR), CASE WHEN @silver_customer = 1 THEN 'PASS' ELSE 'FAIL' END),
        ('Table', 'Silver Product Dimension', '1', CAST(@silver_product AS NVARCHAR), CASE WHEN @silver_product = 1 THEN 'PASS' ELSE 'FAIL' END),
        ('Table', 'Silver Date Dimension', '1', CAST(@silver_date AS NVARCHAR), CASE WHEN @silver_date = 1 THEN 'PASS' ELSE 'FAIL' END),
        ('Table', 'Gold Sales Fact', '1', CAST(@gold_fact AS NVARCHAR), CASE WHEN @gold_fact = 1 THEN 'PASS' ELSE 'FAIL' END),
        ('Table', 'Gold Customer Summary', '1', CAST(@gold_customer_summary AS NVARCHAR), CASE WHEN @gold_customer_summary = 1 THEN 'PASS' ELSE 'FAIL' END),
        ('Table', 'Gold Product Summary', '1', CAST(@gold_product_summary AS NVARCHAR), CASE WHEN @gold_product_summary = 1 THEN 'PASS' ELSE 'FAIL' END);

    ----------------------------------------------------------------------------
    -- Test 3: Data Quality Checks
    ----------------------------------------------------------------------------
    PRINT '3. Testing Data Quality...';
    
    -- Check for date dimension coverage
    DECLARE @date_count INT = (SELECT COUNT(*) FROM silver.dim_date);
    DECLARE @date_range_valid BIT = CASE WHEN @date_count > 1000 THEN 1 ELSE 0 END; -- Should have multiple years
    
    INSERT INTO #ValidationResults (test_category, test_name, expected_result, actual_result, status)
    VALUES 
        ('Data Quality', 'Date Dimension Coverage', '>1000', CAST(@date_count AS NVARCHAR), CASE WHEN @date_range_valid = 1 THEN 'PASS' ELSE 'FAIL' END);

    -- Check for referential integrity if data exists
    IF EXISTS (SELECT 1 FROM gold.fact_sales)
    BEGIN
        DECLARE @orphaned_customers INT = (
            SELECT COUNT(*) 
            FROM gold.fact_sales f 
            LEFT JOIN silver.dim_customer c ON f.customer_sk = c.customer_sk 
            WHERE c.customer_sk IS NULL
        );
        
        DECLARE @orphaned_products INT = (
            SELECT COUNT(*) 
            FROM gold.fact_sales f 
            LEFT JOIN silver.dim_product p ON f.product_sk = p.product_sk 
            WHERE p.product_sk IS NULL
        );
        
        INSERT INTO #ValidationResults (test_category, test_name, expected_result, actual_result, status)
        VALUES 
            ('Data Quality', 'No Orphaned Customers in Facts', '0', CAST(@orphaned_customers AS NVARCHAR), CASE WHEN @orphaned_customers = 0 THEN 'PASS' ELSE 'FAIL' END),
            ('Data Quality', 'No Orphaned Products in Facts', '0', CAST(@orphaned_products AS NVARCHAR), CASE WHEN @orphaned_products = 0 THEN 'PASS' ELSE 'FAIL' END);
    END

    ----------------------------------------------------------------------------
    -- Test 4: Business Logic Validation
    ----------------------------------------------------------------------------
    PRINT '4. Testing Business Logic...';
    
    -- Check for proper age group calculation
    IF EXISTS (SELECT 1 FROM silver.dim_customer WHERE birth_date IS NOT NULL)
    BEGIN
        DECLARE @invalid_age_groups INT = (
            SELECT COUNT(*) 
            FROM silver.dim_customer 
            WHERE birth_date IS NOT NULL 
            AND age_group NOT IN ('18-24', '25-34', '35-44', '45-54', '55-64', '65+')
        );
        
        INSERT INTO #ValidationResults (test_category, test_name, expected_result, actual_result, status)
        VALUES ('Business Logic', 'Valid Age Groups', '0', CAST(@invalid_age_groups AS NVARCHAR), CASE WHEN @invalid_age_groups = 0 THEN 'PASS' ELSE 'FAIL' END);
    END

    -- Check for proper gender standardization
    DECLARE @invalid_genders INT = (
        SELECT COUNT(*) 
        FROM silver.dim_customer 
        WHERE gender NOT IN ('Male', 'Female', 'Unknown')
    );
    
    INSERT INTO #ValidationResults (test_category, test_name, expected_result, actual_result, status)
    VALUES ('Business Logic', 'Standardized Genders', '0', CAST(@invalid_genders AS NVARCHAR), CASE WHEN @invalid_genders = 0 THEN 'PASS' ELSE 'FAIL' END);

    ----------------------------------------------------------------------------
    -- Test 5: Performance Checks
    ----------------------------------------------------------------------------
    PRINT '5. Testing Index Existence...';
    
    DECLARE @fact_indexes INT = (
        SELECT COUNT(*) 
        FROM sys.indexes i
        INNER JOIN sys.objects o ON i.object_id = o.object_id
        INNER JOIN sys.schemas s ON o.schema_id = s.schema_id
        WHERE s.name = 'gold' AND o.name = 'fact_sales' AND i.name IS NOT NULL
    );
    
    INSERT INTO #ValidationResults (test_category, test_name, expected_result, actual_result, status)
    VALUES ('Performance', 'Fact Table Indexes', '>0', CAST(@fact_indexes AS NVARCHAR), CASE WHEN @fact_indexes > 0 THEN 'PASS' ELSE 'FAIL' END);

END TRY
BEGIN CATCH
    INSERT INTO #ValidationResults (test_category, test_name, expected_result, actual_result, status, error_message)
    VALUES ('Error', 'Test Execution', 'No Errors', 'Error Occurred', 'FAIL', ERROR_MESSAGE());
END CATCH

----------------------------------------------------------------------------
-- Display Results
----------------------------------------------------------------------------
PRINT '📊 Test Results Summary:';
PRINT '========================';

SELECT 
    test_category,
    test_name,
    expected_result,
    actual_result,
    status,
    ISNULL(error_message, '') AS error_message
FROM #ValidationResults
ORDER BY test_id;

-- Summary statistics
SELECT 
    status,
    COUNT(*) AS test_count
FROM #ValidationResults
GROUP BY status;

-- Overall result
DECLARE @total_tests INT = (SELECT COUNT(*) FROM #ValidationResults);
DECLARE @passed_tests INT = (SELECT COUNT(*) FROM #ValidationResults WHERE status = 'PASS');
DECLARE @failed_tests INT = (SELECT COUNT(*) FROM #ValidationResults WHERE status = 'FAIL');

PRINT '';
PRINT 'Overall Results:';
PRINT '===============';
PRINT 'Total Tests: ' + CAST(@total_tests AS NVARCHAR(10));
PRINT 'Passed: ' + CAST(@passed_tests AS NVARCHAR(10));
PRINT 'Failed: ' + CAST(@failed_tests AS NVARCHAR(10));
PRINT 'Success Rate: ' + CAST(ROUND((@passed_tests * 100.0) / @total_tests, 1) AS NVARCHAR(10)) + '%';

IF @failed_tests = 0
    PRINT '✅ All tests passed! Data warehouse is ready for use.';
ELSE
    PRINT '⚠️  Some tests failed. Please review the results above.';

-- Clean up
DROP TABLE #ValidationResults;