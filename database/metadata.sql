
SET search_path TO airbnb, public;


-- 1. general info
SELECT
    current_database() AS database_name,
    current_user AS database_user,
    version() AS postgresql_version;


-- 2. number of tables (expected 20)
SELECT COUNT(*) AS table_count
FROM information_schema.tables
WHERE table_schema = 'airbnb' AND table_type = 'BASE TABLE';


-- 3. list of tables
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'airbnb' AND table_type = 'BASE TABLE'
ORDER BY table_name;


-- 4. number of columns
SELECT
    table_name,
    COUNT(*) AS column_count
FROM information_schema.columns
WHERE table_schema = 'airbnb'
GROUP BY table_name
ORDER BY table_name;


-- 5. constraints by type
SELECT
    constraint_type,
    COUNT(*) AS constraint_count
FROM information_schema.table_constraints
WHERE table_schema = 'airbnb'
GROUP BY constraint_type
ORDER BY constraint_type;


-- 6. primary keys
SELECT
    tc.table_name,
    tc.constraint_name,
    kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON kcu.constraint_name = tc.constraint_name
    AND kcu.constraint_schema = tc.constraint_schema
    AND kcu.table_name = tc.table_name
WHERE tc.table_schema = 'airbnb' AND tc.constraint_type = 'PRIMARY KEY'
ORDER BY
    tc.table_name,
    kcu.ordinal_position;


-- 7. foreign keys
SELECT
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS referenced_table,
    ccu.column_name AS referenced_column
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON kcu.constraint_name = tc.constraint_name
    AND kcu.constraint_schema = tc.constraint_schema
JOIN information_schema.constraint_column_usage ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.constraint_schema = tc.constraint_schema
WHERE tc.table_schema = 'airbnb' AND tc.constraint_type = 'FOREIGN KEY'
ORDER BY
    tc.table_name,
    kcu.column_name;


-- 8. row count and size
SELECT
    relname AS table_name,
    n_live_tup AS approximate_row_count,
    pg_size_pretty(pg_total_relation_size(relid)) AS total_size
FROM pg_stat_user_tables
WHERE schemaname = 'airbnb'
ORDER BY relname;


-- 9. number of records
WITH table_counts AS (
    SELECT COUNT(*) AS row_count FROM users
    UNION ALL
    SELECT COUNT(*) FROM user_profiles
    UNION ALL
    SELECT COUNT(*) FROM user_verifications
    UNION ALL
    SELECT COUNT(*) FROM addresses
    UNION ALL
    SELECT COUNT(*) FROM listings
    UNION ALL
    SELECT COUNT(*) FROM listing_photos
    UNION ALL
    SELECT COUNT(*) FROM house_rules
    UNION ALL
    SELECT COUNT(*) FROM listing_house_rules
    UNION ALL
    SELECT COUNT(*) FROM availability_calendar
    UNION ALL
    SELECT COUNT(*) FROM pricing_periods
    UNION ALL
    SELECT COUNT(*) FROM bookings
    UNION ALL
    SELECT COUNT(*) FROM booking_guests
    UNION ALL
    SELECT COUNT(*) FROM services
    UNION ALL
    SELECT COUNT(*) FROM booking_services
    UNION ALL
    SELECT COUNT(*) FROM payments
    UNION ALL
    SELECT COUNT(*) FROM payouts
    UNION ALL
    SELECT COUNT(*) FROM cancellations
    UNION ALL
    SELECT COUNT(*) FROM reviews
    UNION ALL
    SELECT COUNT(*) FROM messages
    UNION ALL
    SELECT COUNT(*) FROM favorites
)
SELECT SUM(row_count) AS total_record_count
FROM table_counts;


-- 10. size of schema
SELECT pg_size_pretty(SUM(pg_total_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)))) AS project_schema_size
FROM pg_tables
WHERE schemaname = 'airbnb';


-- 11. size of DB
SELECT
    current_database() AS database_name,
    pg_size_pretty(pg_database_size(current_database())) AS database_size;