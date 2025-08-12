# Data Warehouse Architecture Guide

## Overview
This SQL Server data warehouse follows a medallion architecture with Bronze, Silver, and Gold layers for progressive data refinement and optimization.

## Layer Descriptions

### Bronze Layer (Raw Data)
- **Purpose**: Store raw, unprocessed data from source systems
- **Characteristics**: Minimal transformation, preserve source format
- **Tables**:
  - `crm_customer_info` - Customer master data from CRM
  - `crm_product_info` - Product master data from CRM  
  - `crm_sales_details` - Sales transaction data from CRM
  - `erp_location_info` - Customer location data from ERP
  - `erp_customer_demographics` - Customer demographic data from ERP
  - `erp_product_category` - Product category data from ERP

### Silver Layer (Cleaned Data)
- **Purpose**: Store cleaned, standardized, and enriched data
- **Characteristics**: Data quality improvements, standardization, business rules applied
- **Tables**:
  - `dim_customer` - Customer dimension with standardized attributes
  - `dim_product` - Product dimension with category enrichment
  - `dim_date` - Date dimension for time-based analysis

### Gold Layer (Business-Ready Data)
- **Purpose**: Store aggregated, business-ready data for reporting and analytics
- **Characteristics**: Optimized for query performance, pre-calculated metrics
- **Tables**:
  - `fact_sales` - Sales fact table with dimension keys
  - `customer_sales_summary` - Pre-aggregated customer metrics
  - `product_sales_summary` - Pre-aggregated product metrics

## Data Transformations

### Bronze to Silver
- **Data Cleaning**: Trim whitespace, standardize case
- **Standardization**: Gender (Male/Female/Unknown), Marital Status (Married/Single/Unknown)
- **Enrichment**: Full name concatenation, age group calculation
- **Data Integration**: Join CRM and ERP data for complete customer profiles

### Silver to Gold
- **Fact Table Creation**: Star schema with dimension key lookups
- **Aggregation**: Pre-calculate summary metrics for performance
- **Business Metrics**: Total sales, order counts, averages

## Key Features

### Data Quality
- Transaction-based loading ensures data consistency
- Comprehensive error handling with rollback capabilities
- Referential integrity constraints between fact and dimension tables

### Performance Optimization
- Surrogate keys for dimension tables
- Indexes on fact table foreign keys
- Pre-aggregated summary tables for common queries

### Testing & Validation
- Comprehensive test script validates entire pipeline
- Schema, table, data quality, and business logic checks
- Automated success/failure reporting

## Usage Instructions

1. **Initialize Database**: Run `DW_Init_Script_CreateDB_Schemas.sql`
2. **Create Bronze Tables**: Run `bronze/Create_Bronze_Staging_Tables.sql`
3. **Create Silver Tables**: Run `silver/Create_Silver_Dimension_Tables.sql`
4. **Create Gold Tables**: Run `gold/Create_Gold_Data_Marts.sql`
5. **Load Sample Data**: (Insert your data loading process here)
6. **Transform to Silver**: Run `silver/Populate_Silver_Dimensions.sql`
7. **Transform to Gold**: Run `gold/Populate_Gold_Data_Marts.sql`
8. **Validate**: Run `Test_Data_Warehouse.sql`

## Sample Queries

### Customer Analysis
```sql
-- Top customers by sales volume
SELECT TOP 10 
    customer_name,
    country,
    total_sales_amount,
    total_orders
FROM gold.customer_sales_summary
ORDER BY total_sales_amount DESC;
```

### Product Performance
```sql
-- Best performing product lines
SELECT 
    product_line,
    SUM(total_sales_amount) AS line_total_sales,
    COUNT(*) AS product_count
FROM gold.product_sales_summary
GROUP BY product_line
ORDER BY line_total_sales DESC;
```

### Time-based Analysis
```sql
-- Monthly sales trends
SELECT 
    d.year_number,
    d.month_name,
    SUM(f.total_sales) AS monthly_sales,
    COUNT(DISTINCT f.sales_order_number) AS order_count
FROM gold.fact_sales f
JOIN silver.dim_date d ON f.order_date_sk = d.date_sk
GROUP BY d.year_number, d.month_number, d.month_name
ORDER BY d.year_number, d.month_number;
```