CREATE OR REPLACE WAREHOUSE fintech_wh
WITH WAREHOUSE_SIZE = 'XSMALL'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE;

CREATE OR REPLACE DATABASE fintech_db;

CREATE OR REPLACE SCHEMA fintech_db.bronze;
CREATE OR REPLACE SCHEMA fintech_db.silver;
CREATE OR REPLACE SCHEMA fintech_db.gold;

USE WAREHOUSE fintech_wh;
USE DATABASE fintech_db;
USE SCHEMA bronze;

SHOW WAREHOUSES;
SHOW DATABASES;
SHOW SCHEMAS;


CREATE OR REPLACE STAGE s3_raw_stage
  URL = 's3://fintech-lakehouse-raw-dhananjay/raw/'
  CREDENTIALS = (
    AWS_KEY_ID = '' 
    AWS_SECRET_KEY = ''
  );

LIST @s3_raw_stage;





CREATE OR REPLACE TABLE bronze_sec_filings(
    file_name STRING,
    file_size NUMBER,
    last_modified TIMESTAMP_NTZ,
    scoped_file_url STRING,
    ingested_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);



CREATE OR REPLACE TABLE bronze_nasdaq_list (
    raw_data VARIANT,
    file_name STRING,
    ingested_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE bronze_historical_prices (
    raw_data VARIANT,
    file_name STRING,
    ingested_at TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

COPY INTO bronze_nasdaq_list (raw_data, file_name)
FROM (
  SELECT ARRAY_CONSTRUCT($1, $2, $3, $4, $5), METADATA$FILENAME 
  FROM @s3_raw_stage/market_data/nasdaq_list.csv
)
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"')
FORCE = TRUE;




COPY INTO bronze_historical_prices (raw_data, file_name)
FROM (
  SELECT ARRAY_CONSTRUCT($1, $2, $3, $4, $5, $6, $7), METADATA$FILENAME 
  FROM @s3_raw_stage/market_data/nasdaq_historical_prices_daily.csv
)
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"')
FORCE = TRUE;



COPY INTO bronze_nasdaq_list (raw_data, file_name)
FROM (
  SELECT ARRAY_CONSTRUCT($1, $2, $3, $4, $5), METADATA$FILENAME 
  FROM @s3_raw_stage/market_data/nasdaq_list.csv
)
FILE_FORMAT = (
  TYPE = 'CSV' 
  SKIP_HEADER = 1 
  FIELD_OPTIONALLY_ENCLOSED_BY = '"'
  ENCODING = 'ISO-8859-1' -- ◄ Relaxes the byte checker for special characters
)
ON_ERROR = 'CONTINUE';



USE SCHEMA fintech_db.silver;

-- Populate Company Table
CREATE OR REPLACE TABLE silver_nasdaq_companies AS
SELECT
    REPLACE(raw_data[0]::STRING, '"', '') AS ticker,
    REPLACE(raw_data[1]::STRING, '"', '') AS company_name,
    raw_data[2]::NUMBER AS market_cap,
    REPLACE(raw_data[3]::STRING, '"', '') AS market_cap_group,
    REPLACE(raw_data[4]::STRING, '"', '') AS sector,
    file_name,
    processed_at
FROM (
  SELECT raw_data, file_name, CURRENT_TIMESTAMP() AS processed_at 
  FROM fintech_db.bronze.bronze_nasdaq_list
);

-- Populate Historical Prices Table
CREATE OR REPLACE TABLE silver_market_prices AS
SELECT
    REPLACE(raw_data[0]::STRING, '"', '') AS ticker,
    TO_DATE(raw_data[1]::STRING, 'YYYY-MM-DD') AS trade_date,
    raw_data[2]::FLOAT AS open_price,
    raw_data[3]::FLOAT AS high_price,
    raw_data[4]::FLOAT AS low_price,
    raw_data[5]::FLOAT AS close_price,
    raw_data[6]::NUMBER AS volume,
    file_name,
    processed_at
FROM (
  SELECT raw_data, file_name, CURRENT_TIMESTAMP() AS processed_at 
  FROM fintech_db.bronze.bronze_historical_prices
);


SELECT COUNT(*) FROM fintech_db.silver.silver_nasdaq_companies;
SELECT COUNT(*) FROM fintech_db.silver.silver_market_prices;

-- Preview the clean historical data
SELECT * FROM fintech_db.silver.silver_market_prices LIMIT 10;

