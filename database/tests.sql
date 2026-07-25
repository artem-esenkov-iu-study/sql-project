SET search_path TO airbnb, public;


-- 1. number of rows in every table (min 20)
SELECT 'users' AS table_name, COUNT(*) AS row_count FROM users
UNION ALL
SELECT 'user_profiles', COUNT(*) FROM user_profiles
UNION ALL
SELECT 'user_verifications', COUNT(*) FROM user_verifications
UNION ALL
SELECT 'addresses', COUNT(*) FROM addresses
UNION ALL
SELECT 'listings', COUNT(*) FROM listings
UNION ALL
SELECT 'listing_photos', COUNT(*) FROM listing_photos
UNION ALL
SELECT 'house_rules', COUNT(*) FROM house_rules
UNION ALL
SELECT 'listing_house_rules', COUNT(*) FROM listing_house_rules
UNION ALL
SELECT 'availability_calendar', COUNT(*) FROM availability_calendar
UNION ALL
SELECT 'pricing_periods', COUNT(*) FROM pricing_periods
UNION ALL
SELECT 'bookings', COUNT(*) FROM bookings
UNION ALL
SELECT 'booking_guests', COUNT(*) FROM booking_guests
UNION ALL
SELECT 'services', COUNT(*) FROM services
UNION ALL
SELECT 'booking_services', COUNT(*) FROM booking_services
UNION ALL
SELECT 'payments', COUNT(*) FROM payments
UNION ALL
SELECT 'payouts', COUNT(*) FROM payouts
UNION ALL
SELECT 'cancellations', COUNT(*) FROM cancellations
UNION ALL
SELECT 'reviews', COUNT(*) FROM reviews
UNION ALL
SELECT 'messages', COUNT(*) FROM messages
UNION ALL
SELECT 'favorites', COUNT(*) FROM favorites
ORDER BY table_name;


-- 2. tables with <20 records (must be 0)
WITH table_counts AS (
    SELECT 'users' AS table_name, COUNT(*) AS row_count FROM users
    UNION ALL
    SELECT 'user_profiles', COUNT(*) FROM user_profiles
    UNION ALL
    SELECT 'user_verifications', COUNT(*) FROM user_verifications
    UNION ALL
    SELECT 'addresses', COUNT(*) FROM addresses
    UNION ALL
    SELECT 'listings', COUNT(*) FROM listings
    UNION ALL
    SELECT 'listing_photos', COUNT(*) FROM listing_photos
    UNION ALL
    SELECT 'house_rules', COUNT(*) FROM house_rules
    UNION ALL
    SELECT 'listing_house_rules', COUNT(*) FROM listing_house_rules
    UNION ALL
    SELECT 'availability_calendar', COUNT(*) FROM availability_calendar
    UNION ALL
    SELECT 'pricing_periods', COUNT(*) FROM pricing_periods
    UNION ALL
    SELECT 'bookings', COUNT(*) FROM bookings
    UNION ALL
    SELECT 'booking_guests', COUNT(*) FROM booking_guests
    UNION ALL
    SELECT 'services', COUNT(*) FROM services
    UNION ALL
    SELECT 'booking_services', COUNT(*) FROM booking_services
    UNION ALL
    SELECT 'payments', COUNT(*) FROM payments
    UNION ALL
    SELECT 'payouts', COUNT(*) FROM payouts
    UNION ALL
    SELECT 'cancellations', COUNT(*) FROM cancellations
    UNION ALL
    SELECT 'reviews', COUNT(*) FROM reviews
    UNION ALL
    SELECT 'messages', COUNT(*) FROM messages
    UNION ALL
    SELECT 'favorites', COUNT(*) FROM favorites
)
SELECT table_name, row_count
FROM table_counts
WHERE row_count < 20
ORDER BY table_name;


-- 3. check for invalid dates, values, relationships (must be 0)
SELECT *
FROM bookings
WHERE check_out_date <= check_in_date;

SELECT *
FROM bookings
WHERE total_amount < 0;

SELECT *
FROM listings
WHERE price_per_night <= 0;

SELECT *
FROM reviews
WHERE rating < 1 OR rating > 5;

SELECT *
FROM messages
WHERE sender_user_id = receiver_user_id;

SELECT *
FROM reviews
WHERE author_user_id = target_user_id;