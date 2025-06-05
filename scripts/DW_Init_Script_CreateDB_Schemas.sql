/*
================================================================================
Script Name   : DW_Init_Script_CreateDB_Schemas.sql
Purpose       : Recreate the 'DataWarehouse' database and initialize bronze, silver, and gold schemas
Author        : Dumisani Magagula
Created Date  : 2025/05/07
Version       : 1.1
================================================================================

Description:
This script connects to the 'master' database, drops the 'DataWarehouse' if it exists, 
and recreates it. Then it creates the 'bronze', 'silver', and 'gold' schemas 
in the new database, assigning all ownership to 'dbo'.

WARNING:
⚠ This script will permanently delete the existing 'DataWarehouse' database.
Ensure appropriate backups and approvals are in place before executing.
================================================================================
*/

--=============================
-- Connect to master
--=============================
USE master;
GO

--=============================
-- Parameters
--=============================
DECLARE @DatabaseName SYSNAME = 'DataWarehouse';

--=============================
-- Check & Drop Existing Database (if exists)
--=============================
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = @DatabaseName)
BEGIN
    PRINT 'Database exists. Dropping: ' + @DatabaseName;

    -- Force disconnect users and drop
    EXEC('ALTER DATABASE [' + @DatabaseName + '] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;');
    EXEC('DROP DATABASE [' + @DatabaseName + '];');

    PRINT 'Dropped database: ' + @DatabaseName;
END
ELSE
BEGIN
    PRINT 'No existing database found. Proceeding to create a new one.';
END
GO

--=============================
-- Create New Database
--=============================
PRINT 'Creating database: DataWarehouse';
CREATE DATABASE [DataWarehouse];
GO

--=============================
-- Switch to the new database
--=============================
USE [DataWarehouse];
GO

--=============================
-- Create Schemas with 'dbo' Owner
--=============================

-- Bronze Layer - Raw/Ingested Data
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'bronze')
BEGIN
    PRINT 'Creating schema: bronze with owner dbo';
    EXEC('CREATE SCHEMA bronze AUTHORIZATION dbo;');
END
GO

-- Silver Layer - Cleaned/Transformed Data
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver')
BEGIN
    PRINT 'Creating schema: silver with owner dbo';
    EXEC('CREATE SCHEMA silver AUTHORIZATION dbo;');
END
GO

-- Gold Layer - Curated/Reporting-Ready Data
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'gold')
BEGIN
    PRINT 'Creating schema: gold with owner dbo';
    EXEC('CREATE SCHEMA gold AUTHORIZATION dbo;');
END
GO

--=============================
-- Verification Step
--=============================
PRINT 'Verifying schema ownership...';
SELECT 
    s.name AS SchemaName, 
    u.name AS Owner
FROM sys.schemas s
JOIN sys.database_principals u ON s.principal_id = u.principal_id
WHERE s.name IN ('bronze', 'silver', 'gold');
GO

PRINT '✅ DataWarehouse initialization complete.';
