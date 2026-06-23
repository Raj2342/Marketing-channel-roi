{{ config(
    materialized='table',
    format='parquet'
) }}

SELECT 
    msno,
    num_25,
    num_50,
    num_75,
    num_985,
    num_100,
    num_unq,
    total_secs,
    -- Wrapped in quotes to bypass AWS reserved keyword rule, converted to DATE
    CAST(date_parse(CAST(date AS VARCHAR), '%Y%m%d') AS DATE) AS "date"
FROM {{ source('marketing_raw', 'user_logs') }}