SET search_path TO airbnb, public;


-- 1. full booking info
SELECT
    b.booking_id,
    guest.first_name || ' ' || guest.last_name AS guest_name,
    host.first_name || ' ' || host.last_name AS host_name,
    l.title AS listing_title,
    a.city,
    b.check_in_date,
    b.check_out_date,
    b.guest_count,
    b.total_amount,
    b.status
FROM bookings b
JOIN users guest ON guest.user_id = b.guest_user_id
JOIN listings l ON l.listing_id = b.listing_id
JOIN users host ON host.user_id = l.host_user_id
JOIN addresses a ON a.address_id = l.address_id
ORDER BY b.booking_id;


-- 2. all listings with host and address
SELECT
    l.listing_id,
    l.title,
    l.property_type,
    l.max_guests,
    l.price_per_night,
    u.first_name || ' ' || u.last_name AS host_name,
    a.city,
    a.country
FROM listings l
JOIN users u ON u.user_id = l.host_user_id
JOIN addresses a ON a.address_id = l.address_id
ORDER BY l.listing_id;


-- 3. booking history for each guest
SELECT
    u.user_id,
    u.first_name || ' ' || u.last_name AS guest_name,
    COUNT(b.booking_id) AS booking_count,
    SUM(b.total_amount) AS total_spent
FROM users u
JOIN bookings b ON b.guest_user_id = u.user_id
GROUP BY
    u.user_id,
    u.first_name,
    u.last_name
ORDER BY total_spent DESC;


-- 4. host revenue
SELECT
    u.user_id,
    u.first_name || ' ' || u.last_name AS host_name,
    COUNT(p.payout_id) AS payout_count,
    SUM(p.amount) AS total_revenue
FROM payouts p
JOIN users u ON u.user_id = p.host_user_id
WHERE p.payout_status = 'completed'
GROUP BY
    u.user_id,
    u.first_name,
    u.last_name
ORDER BY total_revenue DESC;


-- 5. rating
SELECT
    u.user_id,
    u.first_name || ' ' || u.last_name AS user_name,
    COUNT(r.review_id) AS review_count,
    ROUND(AVG(r.rating), 2) AS average_rating
FROM users u
JOIN reviews r ON r.target_user_id = u.user_id
GROUP BY
    u.user_id,
    u.first_name,
    u.last_name
ORDER BY average_rating DESC;


-- 6. cancelled bookings
SELECT
    b.booking_id,
    u.first_name || ' ' || u.last_name AS cancelled_by,
    c.reason,
    c.refund_amount,
    c.cancelled_at
FROM cancellations c
JOIN bookings b ON b.booking_id = c.booking_id
JOIN users u ON u.user_id = c.cancelled_by_user_id
ORDER BY c.cancelled_at;


-- 7. services
SELECT
    bs.booking_id,
    s.service_name,
    provider.first_name || ' ' || provider.last_name AS provider_name,
    bs.quantity,
    bs.price
FROM booking_services bs
JOIN services s ON s.service_id = bs.service_id
JOIN users provider ON provider.user_id = bs.provider_user_id
ORDER BY bs.booking_id;


-- 8. house rules
SELECT
    l.title AS listing_title,
    hr.rule_name,
    u.first_name || ' ' || u.last_name AS added_by
FROM listing_house_rules lhr
JOIN listings l ON l.listing_id = lhr.listing_id
JOIN house_rules hr ON hr.house_rule_id = lhr.house_rule_id
JOIN users u ON u.user_id = lhr.added_by_user_id
ORDER BY l.listing_id, hr.rule_name;


-- 9. pricing periods
SELECT
    l.title,
    pp.start_date,
    pp.end_date,
    pp.price_per_night,
    u.first_name || ' ' || u.last_name AS created_by
FROM pricing_periods pp
JOIN listings l ON l.listing_id = pp.listing_id
JOIN users u ON u.user_id = pp.created_by_user_id
ORDER BY pp.start_date;


-- 10. most liked
SELECT
    l.listing_id,
    l.title,
    COUNT(f.user_id) AS favorite_count
FROM listings l
LEFT JOIN favorites f ON f.listing_id = l.listing_id
GROUP BY
    l.listing_id,
    l.title
ORDER BY favorite_count DESC, l.listing_id;


-- 11. payment status summary
SELECT
    payment_status,
    COUNT(*) AS payment_count,
    SUM(amount) AS total_amount
FROM payments
GROUP BY payment_status
ORDER BY payment_status;


-- 12. available dates
SELECT
    l.listing_id,
    l.title,
    ac.available_date
FROM availability_calendar ac
JOIN listings l ON l.listing_id = ac.listing_id
WHERE ac.is_available = TRUE
ORDER BY l.listing_id, ac.available_date;