
SET search_path TO airbnb, public;
BEGIN;


-- 1. users
CREATE TABLE users (

    user_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email VARCHAR(199) NOT NULL UNIQUE,
    first_name VARCHAR(99) NOT NULL,
    last_name VARCHAR(99) NOT NULL,
    phone_number VARCHAR(30),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP

);


-- 2. user profiles
CREATE TABLE user_profiles (

    profile_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    bio TEXT,
    birth_date DATE,
    profile_photo_url VARCHAR(499),

    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE

);


-- 3. user verifications
CREATE TABLE user_verifications (

    verification_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id BIGINT NOT NULL,
    verification_type VARCHAR(30) NOT NULL,
    verification_status VARCHAR(20) NOT NULL DEFAULT 'pending',
    verified_at TIMESTAMPTZ,

    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,

    CHECK (verification_type IN ('email', 'phone', 'identity', 'address')),
    CHECK (verification_status IN ('pending', 'verified', 'rejected')),

    UNIQUE (user_id, verification_type)

);


-- 4. addresses
CREATE TABLE addresses (

    address_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country VARCHAR(99) NOT NULL,
    city VARCHAR(99) NOT NULL,
    postal_code VARCHAR(20) NOT NULL,
    street VARCHAR(199) NOT NULL,
    house_number VARCHAR(20) NOT NULL,
    apartment_number VARCHAR(20)

);


-- 5. listings
CREATE TABLE listings (

    listing_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    host_user_id BIGINT NOT NULL,
    address_id BIGINT NOT NULL,
    title VARCHAR(199) NOT NULL,
    description TEXT,
    property_type VARCHAR(30) NOT NULL,
    max_guests INTEGER NOT NULL,
    price_per_night NUMERIC(10,2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (host_user_id) REFERENCES users(user_id),
    FOREIGN KEY (address_id) REFERENCES addresses(address_id),

    CHECK (max_guests > 0),
    CHECK (price_per_night > 0)

);


-- 6. listing photos
CREATE TABLE listing_photos (

    photo_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    listing_id BIGINT NOT NULL,
    photo_url VARCHAR(499) NOT NULL,
    caption VARCHAR(199),
    display_order INTEGER NOT NULL DEFAULT 1,

    FOREIGN KEY (listing_id) REFERENCES listings(listing_id) ON DELETE CASCADE,

    CHECK (display_order > 0),

    UNIQUE (listing_id, display_order)

);


-- 7. house rules
CREATE TABLE house_rules (
    house_rule_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    rule_name VARCHAR(99) NOT NULL UNIQUE,
    description TEXT
);


-- 8. listing house rules (3x)
CREATE TABLE listing_house_rules (

    listing_id BIGINT NOT NULL,
    house_rule_id BIGINT NOT NULL,
    added_by_user_id BIGINT NOT NULL,

    PRIMARY KEY (listing_id, house_rule_id),

    FOREIGN KEY (listing_id) REFERENCES listings(listing_id) ON DELETE CASCADE,
    FOREIGN KEY (house_rule_id) REFERENCES house_rules(house_rule_id),
    FOREIGN KEY (added_by_user_id) REFERENCES users(user_id)

);


-- 9. avilibility calendar
CREATE TABLE availability_calendar (

    availability_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    listing_id BIGINT NOT NULL,
    available_date DATE NOT NULL,
    is_available BOOLEAN NOT NULL DEFAULT TRUE,

    FOREIGN KEY (listing_id) REFERENCES listings(listing_id) ON DELETE CASCADE,

    UNIQUE (listing_id, available_date)

);


-- 10. pricing periods (3x)
CREATE TABLE pricing_periods (

    pricing_period_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    listing_id BIGINT NOT NULL,
    created_by_user_id BIGINT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    price_per_night NUMERIC(10,2) NOT NULL,

    FOREIGN KEY (listing_id) REFERENCES listings(listing_id) ON DELETE CASCADE,
    FOREIGN KEY (created_by_user_id) REFERENCES users(user_id),

    CHECK (end_date >= start_date),
    CHECK (price_per_night > 0)

);


-- 11. bookings
CREATE TABLE bookings (

    booking_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    listing_id BIGINT NOT NULL,
    guest_user_id BIGINT NOT NULL,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    guest_count INTEGER NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    total_amount NUMERIC(10,2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (listing_id) REFERENCES listings(listing_id),
    FOREIGN KEY (guest_user_id) REFERENCES users(user_id),

    CHECK (check_out_date > check_in_date),
    CHECK (guest_count > 0),
    CHECK (total_amount >= 0),
    CHECK (status IN ('pending', 'confirmed', 'cancelled', 'completed'))

);


-- 12. booking guests
CREATE TABLE booking_guests (

    booking_guest_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    booking_id BIGINT NOT NULL,
    first_name VARCHAR(99) NOT NULL,
    last_name VARCHAR(99) NOT NULL,
    age INTEGER,

    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE,

    CHECK (age IS NULL OR age >= 0)

);


-- 13. services
CREATE TABLE services (

    service_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    service_name VARCHAR(99) NOT NULL UNIQUE,
    description TEXT,
    base_price NUMERIC(10,2) NOT NULL,

    CHECK (base_price >= 0)

);


-- 14. booking services (3x)
CREATE TABLE booking_services (

    booking_id BIGINT NOT NULL,
    service_id BIGINT NOT NULL,
    provider_user_id BIGINT NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    price NUMERIC(10,2) NOT NULL,

    PRIMARY KEY (booking_id, service_id, provider_user_id),

    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id) ON DELETE CASCADE,
    FOREIGN KEY (service_id) REFERENCES services(service_id),
    FOREIGN KEY (provider_user_id) REFERENCES users(user_id),

    CHECK (quantity > 0),
    CHECK (price >= 0)

);


-- 15. payments
CREATE TABLE payments (

    payment_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    booking_id BIGINT NOT NULL UNIQUE,
    amount NUMERIC(10,2) NOT NULL,
    payment_method VARCHAR(30) NOT NULL,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'pending',
    paid_at TIMESTAMPTZ,

    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),

    CHECK (amount > 0),
    CHECK (payment_method IN ('credit_card', 'debit_card', 'paypal', 'bank_transfer')),
    CHECK (payment_status IN ('pending', 'completed', 'failed', 'refunded'))

);


-- 16. payouts
CREATE TABLE payouts (

    payout_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    booking_id BIGINT NOT NULL UNIQUE,
    host_user_id BIGINT NOT NULL,
    amount NUMERIC(10,2) NOT NULL,
    payout_status VARCHAR(20) NOT NULL DEFAULT 'pending',
    paid_at TIMESTAMPTZ,

    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    FOREIGN KEY (host_user_id) REFERENCES users(user_id),

    CHECK (amount > 0),
    CHECK (payout_status IN ('pending', 'completed', 'failed'))

);


-- 17. cancellations
CREATE TABLE cancellations (

    cancellation_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    booking_id BIGINT NOT NULL UNIQUE,
    cancelled_by_user_id BIGINT NOT NULL,
    reason TEXT,
    refund_amount NUMERIC(10,2) NOT NULL DEFAULT 0,
    cancelled_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    FOREIGN KEY (cancelled_by_user_id) REFERENCES users(user_id),

    CHECK (refund_amount >= 0)

);


-- 18. reviews
CREATE TABLE reviews (

    review_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    booking_id BIGINT NOT NULL,
    author_user_id BIGINT NOT NULL,
    target_user_id BIGINT NOT NULL,
    rating INTEGER NOT NULL,
    comment TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    FOREIGN KEY (author_user_id) REFERENCES users(user_id),
    FOREIGN KEY (target_user_id) REFERENCES users(user_id),

    CHECK (rating BETWEEN 1 AND 5),
    CHECK (author_user_id <> target_user_id),

    UNIQUE (booking_id, author_user_id, target_user_id)

);


-- 19. messages
CREATE TABLE messages (

    message_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    booking_id BIGINT,
    sender_user_id BIGINT NOT NULL,
    receiver_user_id BIGINT NOT NULL,
    message_text TEXT NOT NULL,
    sent_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,

    FOREIGN KEY (booking_id) REFERENCES bookings(booking_id),
    FOREIGN KEY (sender_user_id) REFERENCES users(user_id),
    FOREIGN KEY (receiver_user_id) REFERENCES users(user_id),

    CHECK (sender_user_id <> receiver_user_id)

);


-- 20. favorites
CREATE TABLE favorites (

    user_id BIGINT NOT NULL,
    listing_id BIGINT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (user_id, listing_id),

    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (listing_id) REFERENCES listings(listing_id) ON DELETE CASCADE

);


COMMIT;