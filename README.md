# SQL Data Warehouse Project
A comprehensive guide to building a modern data warehouse with SQL Server, featuring a medallion architecture (Bronze, Silver, Gold layers) with ETL processes, data modeling, and analytics.

## 🏗️ Architecture Overview
This project implements a modern data warehouse using the medallion architecture pattern:
- **Bronze Layer**: Raw data from source systems (CRM, ERP)
- **Silver Layer**: Cleaned, standardized dimension tables
- **Gold Layer**: Aggregated, business-ready fact tables and data marts

## 🚀 Quick Start

### Prerequisites
- SQL Server 2016+ or SQL Server Express
- SQL Server Management Studio (SSMS) or Azure Data Studio

### Setup Instructions
1. **Initialize the Database**:
   ```sql
   -- Run this script first to create the DataWarehouse database and schemas
   scripts/DW_Init_Script_CreateDB_Schemas.sql
   ```

2. **Create Bronze Layer**:
   ```sql
   -- Create staging tables for raw data
   scripts/bronze/Create_Bronze_Staging_Tables.sql
   ```

3. **Create Silver Layer**:
   ```sql
   -- Create dimension tables
   scripts/silver/Create_Silver_Dimension_Tables.sql
   ```

4. **Create Gold Layer**:
   ```sql
   -- Create fact tables and data marts
   scripts/gold/Create_Gold_Data_Marts.sql
   ```

5. **Load Sample Data** (for testing):
   ```sql
   -- Insert sample data into bronze tables
   scripts/Load_Sample_Data.sql
   ```

6. **Transform to Silver**:
   ```sql
   -- Populate dimension tables with cleaned data
   scripts/silver/Populate_Silver_Dimensions.sql
   ```

7. **Transform to Gold**:
   ```sql
   -- Create aggregated data marts
   scripts/gold/Populate_Gold_Data_Marts.sql
   ```

8. **Validate Setup**:
   ```sql
   -- Run comprehensive testing script
   scripts/Test_Data_Warehouse.sql
   ```

## 📊 What's Included

### Database Objects
- **6 Bronze Tables**: Raw staging tables for CRM and ERP data
- **3 Silver Dimensions**: Customer, Product, and Date dimensions
- **3 Gold Data Marts**: Sales fact table and pre-aggregated summaries

### Scripts
- Database initialization and schema creation
- Table creation scripts for all layers
- Data transformation and loading scripts
- Comprehensive validation and testing framework

### Documentation
- Complete architecture guide (`docs/Architecture_Guide.md`)
- Sample queries and usage examples
- Data lineage and transformation documentation

## 🔧 Features
- **Transaction-based Loading**: Ensures data consistency with rollback capability
- **Data Quality Validation**: Comprehensive testing framework
- **Performance Optimization**: Proper indexing and pre-aggregated summaries
- **Error Handling**: Robust error handling throughout all scripts
- **Referential Integrity**: Foreign key constraints ensure data quality

## 📈 Sample Use Cases
- Customer segmentation analysis
- Product performance tracking
- Sales trend analysis
- Revenue reporting and dashboards

## 🧪 Testing
The project includes a comprehensive testing script that validates:
- Schema and table existence
- Data quality and referential integrity  
- Business logic implementation
- Performance optimization (indexes)

Run `scripts/Test_Data_Warehouse.sql` to validate your setup.

## 📝 Next Steps
1. Load your actual data into the bronze staging tables
2. Customize transformations in silver layer scripts for your business rules
3. Add additional aggregations to gold layer as needed
4. Set up automated ETL processes using SQL Server Agent or Azure Data Factory

## 🤝 Contributing
Feel free to submit issues, fork the repository, and create pull requests for improvements.

## 📄 License
This project is licensed under the MIT License - see the LICENSE file for details.
