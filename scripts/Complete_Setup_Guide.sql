-- ============================================================================
-- Complete Data Warehouse Setup Script
-- Purpose: Execute all scripts in the correct order to set up a functional data warehouse
-- ============================================================================

PRINT '🏗️  Starting Complete Data Warehouse Setup...';
PRINT '=============================================';
PRINT '';

-- Track execution time
DECLARE @StartTime DATETIME = GETDATE();

-- Step 1: Initialize Database and Schemas
PRINT '📋 Step 1: Initializing Database and Schemas...';
EXEC('
    -- This script content should be run separately due to USE statements
    -- Please run: scripts/DW_Init_Script_CreateDB_Schemas.sql first
');

-- Ensure we're in the right database
USE [DataWarehouse];

-- Step 2: Create Bronze Tables  
PRINT '📋 Step 2: Creating Bronze Staging Tables...';
BEGIN TRY
    -- Include bronze table creation here (simplified for demo)
    IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'bronze')
        EXEC('CREATE SCHEMA bronze');
    
    PRINT '   ✅ Bronze schema verified';
    PRINT '   ℹ️  Please ensure bronze tables are created using: scripts/bronze/Create_Bronze_Staging_Tables.sql';
END TRY
BEGIN CATCH
    PRINT '   ❌ Error in bronze setup: ' + ERROR_MESSAGE();
END CATCH

-- Step 3: Create Silver Dimension Tables
PRINT '📋 Step 3: Creating Silver Dimension Tables...';
BEGIN TRY
    -- Include basic silver schema creation
    IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver')
        EXEC('CREATE SCHEMA silver');
    
    PRINT '   ✅ Silver schema verified';
    PRINT '   ℹ️  Please run: scripts/silver/Create_Silver_Dimension_Tables.sql';
END TRY
BEGIN CATCH
    PRINT '   ❌ Error in silver setup: ' + ERROR_MESSAGE();
END CATCH

-- Step 4: Create Gold Data Marts
PRINT '📋 Step 4: Creating Gold Data Marts...';
BEGIN TRY
    -- Include basic gold schema creation
    IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'gold')
        EXEC('CREATE SCHEMA gold');
    
    PRINT '   ✅ Gold schema verified';
    PRINT '   ℹ️  Please run: scripts/gold/Create_Gold_Data_Marts.sql';
END TRY
BEGIN CATCH
    PRINT '   ❌ Error in gold setup: ' + ERROR_MESSAGE();
END CATCH

-- Summary and Next Steps
PRINT '';
PRINT '📝 Setup Summary:';
PRINT '================';
PRINT 'Database schemas have been verified/created.';
PRINT '';
PRINT '🎯 Manual Steps Required:';
PRINT '========================';
PRINT '1. Run: scripts/DW_Init_Script_CreateDB_Schemas.sql (if not done already)';
PRINT '2. Run: scripts/bronze/Create_Bronze_Staging_Tables.sql';
PRINT '3. Run: scripts/silver/Create_Silver_Dimension_Tables.sql';
PRINT '4. Run: scripts/gold/Create_Gold_Data_Marts.sql';
PRINT '5. Run: scripts/Load_Sample_Data.sql (for testing)';
PRINT '6. Run: scripts/silver/Populate_Silver_Dimensions.sql';
PRINT '7. Run: scripts/gold/Populate_Gold_Data_Marts.sql';
PRINT '8. Run: scripts/Test_Data_Warehouse.sql (validation)';
PRINT '';

-- Display execution time
DECLARE @EndTime DATETIME = GETDATE();
DECLARE @Duration INT = DATEDIFF(SECOND, @StartTime, @EndTime);
PRINT 'Setup completed in ' + CAST(@Duration AS NVARCHAR(10)) + ' seconds.';
PRINT '';
PRINT '🎉 Data warehouse setup framework is ready!';
PRINT '   Follow the manual steps above to complete the setup.';

-- Quick validation of what exists
PRINT '';
PRINT '🔍 Current Schema Status:';
PRINT '========================';
SELECT 
    s.name AS schema_name,
    COUNT(t.name) AS table_count
FROM sys.schemas s
LEFT JOIN sys.tables t ON s.schema_id = t.schema_id
WHERE s.name IN ('bronze', 'silver', 'gold')
GROUP BY s.name
ORDER BY s.name;