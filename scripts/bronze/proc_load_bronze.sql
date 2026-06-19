/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `COPY` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    CALL bronze.load_bronze();
===============================================================================
*/

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE
    start_time TIMESTAMP;
    end_time TIMESTAMP;
    load_duration INTERVAL;
BEGIN
	start_time := clock_timestamp();
	RAISE NOTICE '=====================================';
	RAISE NOTICE 'START OF BRONZE LAYER';
	RAISE NOTICE '=====================================';
	
	RAISE NOTICE 'Creating CRM Tables';

	DROP TABLE IF EXISTS bronze.crm_cust_info;
	CREATE TABLE bronze.crm_cust_info (
    cst_id              INT,
    cst_key             VARCHAR(50),
    cst_firstname       VARCHAR(50),
    cst_lastname        VARCHAR(50),
    cst_marital_status  VARCHAR(50),
    cst_gndr            VARCHAR(50),
    cst_create_date     DATE
);

	DROP TABLE IF EXISTS bronze.crm_prd_info;
	CREATE TABLE bronze.crm_prd_info (
	    prd_id       INT,
	    prd_key      VARCHAR(50),
	    prd_nm       VARCHAR(50),
	    prd_cost     INT,
	    prd_line     VARCHAR(50),
	    prd_start_dt DATE,
	    prd_end_dt   DATE
);

	DROP TABLE IF EXISTS bronze.crm_sales_details;
	CREATE TABLE bronze.crm_sales_details (
	    sls_ord_num  VARCHAR(50),
	    sls_prd_key  VARCHAR(50),
	    sls_cust_id  INT,
	    sls_order_dt INT,
	    sls_ship_dt  INT,
	    sls_due_dt   INT,
	    sls_sales    INT,
	    sls_quantity INT,
	    sls_price    INT
);

	RAISE NOTICE 'Creating ERP Tables';

	DROP TABLE IF EXISTS bronze.erp_loc_a101;
	CREATE TABLE bronze.erp_loc_a101 (
	    cid    VARCHAR(50),
	    cntry  VARCHAR(50)
);

	DROP TABLE IF EXISTS bronze.erp_cust_az12;
	CREATE TABLE bronze.erp_cust_az12 (
	    cid    VARCHAR(50),
	    bdate  DATE,
	    gen    VARCHAR(50)
);

	DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;
	CREATE TABLE bronze.erp_px_cat_g1v2 (
	    id           VARCHAR(50),
	    cat          VARCHAR(50),
	    subcat       VARCHAR(50),
	    maintenance  VARCHAR(50)
	);

	RAISE NOTICE 'Loading Data into CRM Tables';
	
	TRUNCATE TABLE bronze.crm_cust_info;
	COPY bronze.crm_cust_info
	FROM 'C:\DE Projects\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
	DELIMITER ','
	CSV HEADER;

	TRUNCATE TABLE bronze.crm_prd_info;
	COPY bronze.crm_prd_info
	FROM 'C:\DE Projects\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
	DELIMITER ','
	CSV HEADER;

	TRUNCATE TABLE bronze.crm_sales_details;
	COPY  bronze.crm_sales_details
	FROM 'C:\DE Projects\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
	DELIMITER ','
	CSV HEADER;
	
	RAISE NOTICE 'Loading Data into ERP Tables';

	TRUNCATE TABLE  bronze.erp_loc_a101;
	COPY bronze.erp_loc_a101
	FROM 'C:\DE Projects\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
	DELIMITER ','
	CSV HEADER;

	TRUNCATE TABLE bronze.erp_cust_az12;
	COPY  bronze.erp_cust_az12
	FROM 'C:\DE Projects\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
	DELIMITER ','
	CSV HEADER;

	TRUNCATE TABLE bronze.erp_px_cat_g1v2;
	COPY  bronze.erp_px_cat_g1v2
	FROM 'C:\DE Projects\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
	DELIMITER ','
	CSV HEADER;

	RAISE NOTICE 'Count of Rows of Both CRM & ERP tables';
	
	DECLARE
    row_count INT;
BEGIN
    SELECT COUNT(*)
    INTO row_count
    FROM bronze.crm_cust_info;

    RAISE NOTICE 'bronze.crm_cust_info_row_count: %', row_count;
END;

	DECLARE
    row_count INT;
BEGIN
    SELECT COUNT(*)
    INTO row_count
    FROM bronze.crm_prd_info;

    RAISE NOTICE 'bronze.crm_prd_info_row_count: %', row_count;
END;
	
	DECLARE
    row_count INT;
BEGIN
    SELECT COUNT(*)
    INTO row_count
    FROM bronze.crm_sales_details;

    RAISE NOTICE 'bronze.crm_sales_details_row_count: %', row_count;
END;

RAISE NOTICE '';   -- Blank line

	DECLARE
    row_count INT;
BEGIN
    SELECT COUNT(*)
    INTO row_count
    FROM bronze.erp_loc_a101;

    RAISE NOTICE 'bronze.erp_loc_a101_row_count: %', row_count;
END;

	DECLARE
    row_count INT;
BEGIN
    SELECT COUNT(*)
    INTO row_count
    FROM bronze.erp_cust_az12;

    RAISE NOTICE 'bronze.erp_cust_az12_row_count: %', row_count;
END;

	DECLARE
    row_count INT;
BEGIN
    SELECT COUNT(*)
    INTO row_count
    FROM bronze.erp_px_cat_g1v2;

    RAISE NOTICE 'bronze.erp_px_cat_g1v2_row_count: %', row_count;
END;

end_time := clock_timestamp();
load_duration := end_time - start_time;

RAISE NOTICE '';   -- Blank line

RAISE NOTICE 'Start Time: %', start_time;
RAISE NOTICE 'End Time: %', end_time;
RAISE NOTICE 'Load Duration: %', load_duration;
	RAISE NOTICE '=====================================';
	RAISE NOTICE 'BRONZE LAYER LOADED SUCCESSFULLY';
	RAISE NOTICE '=====================================';

	EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Bronze Load Failed';
        RAISE NOTICE 'Error: %', SQLERRM;
        RAISE NOTICE 'SQL State: %', SQLSTATE;
END;
$$;
