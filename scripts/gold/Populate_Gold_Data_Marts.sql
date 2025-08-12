-- ============================================================================
-- DML Script: Populate Gold Data Marts
-- Purpose: Load aggregated, reporting-ready data into gold layer
-- ============================================================================

-- Set database context
USE [DataWarehouse];

-- Begin transaction block for atomic execution
BEGIN TRY
    BEGIN TRANSACTION;

    ----------------------------------------------------------------------------
    -- Populate Gold Sales Fact Table
    ----------------------------------------------------------------------------
    -- Clear existing data
    TRUNCATE TABLE gold.fact_sales;

    -- Insert sales fact data with dimension keys
    INSERT INTO gold.fact_sales (
        customer_sk,
        product_sk,
        order_date_sk,
        ship_date_sk,
        due_date_sk,
        sales_order_number,
        quantity_sold,
        unit_price,
        total_sales
    )
    SELECT 
        dc.customer_sk,
        dp.product_sk,
        dd_order.date_sk AS order_date_sk,
        dd_ship.date_sk AS ship_date_sk,
        dd_due.date_sk AS due_date_sk,
        s.sales_order_number,
        s.quantity_sold,
        s.unit_price,
        s.total_sales
    FROM bronze.crm_sales_details s
    INNER JOIN silver.dim_customer dc ON s.customer_id = dc.customer_id
    INNER JOIN silver.dim_product dp ON s.product_key = dp.product_key
    LEFT JOIN silver.dim_date dd_order ON YEAR(s.order_date) * 10000 + MONTH(s.order_date) * 100 + DAY(s.order_date) = dd_order.date_key
    LEFT JOIN silver.dim_date dd_ship ON YEAR(s.ship_date) * 10000 + MONTH(s.ship_date) * 100 + DAY(s.ship_date) = dd_ship.date_key
    LEFT JOIN silver.dim_date dd_due ON YEAR(s.due_date) * 10000 + MONTH(s.due_date) * 100 + DAY(s.due_date) = dd_due.date_key
    WHERE s.sales_order_number IS NOT NULL;

    ----------------------------------------------------------------------------
    -- Populate Customer Sales Summary
    ----------------------------------------------------------------------------
    -- Clear existing data
    TRUNCATE TABLE gold.customer_sales_summary;

    -- Insert aggregated customer sales data
    INSERT INTO gold.customer_sales_summary (
        customer_sk,
        customer_name,
        country,
        age_group,
        total_orders,
        total_quantity,
        total_sales_amount,
        avg_order_value,
        first_order_date,
        last_order_date
    )
    SELECT 
        c.customer_sk,
        c.full_name AS customer_name,
        c.country,
        c.age_group,
        COUNT(DISTINCT f.sales_order_number) AS total_orders,
        SUM(f.quantity_sold) AS total_quantity,
        SUM(f.total_sales) AS total_sales_amount,
        AVG(f.total_sales) AS avg_order_value,
        MIN(d.full_date) AS first_order_date,
        MAX(d.full_date) AS last_order_date
    FROM silver.dim_customer c
    INNER JOIN gold.fact_sales f ON c.customer_sk = f.customer_sk
    INNER JOIN silver.dim_date d ON f.order_date_sk = d.date_sk
    GROUP BY 
        c.customer_sk,
        c.full_name,
        c.country,
        c.age_group;

    ----------------------------------------------------------------------------
    -- Populate Product Sales Summary
    ----------------------------------------------------------------------------
    -- Clear existing data
    TRUNCATE TABLE gold.product_sales_summary;

    -- Insert aggregated product sales data
    INSERT INTO gold.product_sales_summary (
        product_sk,
        product_name,
        product_line,
        category_name,
        total_orders,
        total_quantity,
        total_sales_amount,
        avg_unit_price
    )
    SELECT 
        p.product_sk,
        p.product_name,
        p.product_line,
        p.category_name,
        COUNT(DISTINCT f.sales_order_number) AS total_orders,
        SUM(f.quantity_sold) AS total_quantity,
        SUM(f.total_sales) AS total_sales_amount,
        AVG(f.unit_price) AS avg_unit_price
    FROM silver.dim_product p
    INNER JOIN gold.fact_sales f ON p.product_sk = f.product_sk
    GROUP BY 
        p.product_sk,
        p.product_name,
        p.product_line,
        p.category_name;

    -- Commit if everything succeeds
    COMMIT TRANSACTION;
    PRINT '✅ Gold data marts populated successfully.';

    -- Display row counts for verification
    SELECT 'fact_sales' AS table_name, COUNT(*) AS row_count FROM gold.fact_sales
    UNION ALL
    SELECT 'customer_sales_summary' AS table_name, COUNT(*) AS row_count FROM gold.customer_sales_summary
    UNION ALL
    SELECT 'product_sales_summary' AS table_name, COUNT(*) AS row_count FROM gold.product_sales_summary;

    -- Display sample data for verification
    PRINT 'Sample Customer Sales Summary:';
    SELECT TOP 5 
        customer_name,
        country,
        total_orders,
        total_sales_amount,
        avg_order_value
    FROM gold.customer_sales_summary
    ORDER BY total_sales_amount DESC;

    PRINT 'Sample Product Sales Summary:';
    SELECT TOP 5 
        product_name,
        product_line,
        total_orders,
        total_sales_amount
    FROM gold.product_sales_summary
    ORDER BY total_sales_amount DESC;

END TRY
BEGIN CATCH
    -- Rollback and report error if any part fails
    ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH;