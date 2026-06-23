

SELECT 
    msno,
    city,
    bd,
    gender,
    registered_via,
    -- Converted from BIGINT to DATE
    CAST(date_parse(CAST(registration_init_time AS VARCHAR), '%Y%m%d') AS DATE) AS registration_init_time
FROM "awsdatacatalog"."raw_marketing_data"."members"