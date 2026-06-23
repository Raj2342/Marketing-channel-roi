{{ config(
    materialized='table',
    format='parquet',
    description='Cleans raw members data: fixes null channels and formats integer dates'
) }}

WITH raw_data AS (
    -- DHYAAN DEIN: Agar tumhara source table kuch aur hai, toh yahan update kar lena
    SELECT * FROM {{ ref('stg_members') }} 
)

SELECT 
    msno,
    city,
    bd,
    gender,
    
   -- FIX 1: The "Ghost User" Patch
    -- Integer ko String banaya taaki 'Missing Info' likh sakein null aane par
    COALESCE(CAST(registered_via AS VARCHAR), 'Missing Info') AS registered_via,
    
    -- FIX 2: The Date Formatter
    -- INT64 ko String banaya, aur phir %Y%m%d format padh kar DATE banaya
    --  -- FIX: Convert INT64 -> STRING -> DATE (The Bulletproof Method)
    TRY(CAST(date_parse(CAST(registration_init_time AS VARCHAR), '%Y%m%d') AS DATE)) AS registration_init_time

FROM raw_data