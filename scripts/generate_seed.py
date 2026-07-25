from __future__ import annotations
import random
from datetime import date, datetime, timedelta, timezone
from pathlib import Path
from typing import Any
from faker import Faker


RANDOM_SEED = 12345
random.seed(RANDOM_SEED)

fake = Faker("de_DE")
Faker.seed(RANDOM_SEED)

PROJECT_ROOT = Path(__file__).resolve().parent.parent
OUTPUT_FILE = PROJECT_ROOT / "database" / "seed.sql"


def sql_value(value: Any) -> str:
    """Convert python to sql"""
    if value is None:
        return "NULL"

    if isinstance(value, bool):
        return "TRUE" if value else "FALSE"

    if isinstance(value, datetime):
        escaped = value.isoformat().replace("'", "''")
        return f"TIMESTAMPTZ '{escaped}'"

    if isinstance(value, date):
        return f"DATE '{value.isoformat()}'"

    if isinstance(value, (int, float)):
        return str(value)

    escaped = str(value).replace("'", "''")
    return f"'{escaped}'"


def insert_statement(
    table: str,
    columns: list[str],
    rows: list[tuple[Any, ...]],
) -> str:
    """Build insert statement"""
    if not rows:
        raise ValueError(f"No rows supplied for table {table}")

    column_list = ", ".join(columns)

    values = ",\n".join(
        "    (" + ", ".join(sql_value(value) for value in row) + ")"
        for row in rows
    )

    return (
        f"INSERT INTO {table} (\n"
        f"    {column_list}\n"
        f")\n"
        f"VALUES\n"
        f"{values};\n"
    )


def generate_users() -> list[tuple[Any, ...]]:
    rows = []

    for user_id in range(1, 31):
        first_name = fake.first_name()
        last_name = fake.last_name()

        email = (
            f"{first_name}.{last_name}.{user_id}@sql-project.com"
            .lower()
            .replace("'", "")
            .replace(" ", "")
        )

        phone = fake.phone_number()

        created_at = datetime(
            2025,
            1,
            1,
            tzinfo=timezone.utc,
        ) + timedelta(days=user_id)

        rows.append(
            (
                email,
                first_name,
                last_name,
                phone,
                created_at,
            )
        )

    return rows


def generate_user_profiles() -> list[tuple[Any, ...]]:
    rows = []

    bios = [
        "Travel enthusiast",
        "Frequent business traveler",
        "Weekend explorer",
        "City trip lover",
        "Nature and hiking fan",
    ]

    for user_id in range(1, 26):
        birth_date = date(
            random.randint(1970, 2004),
            random.randint(1, 12),
            random.randint(1, 28),
        )

        bio = bios[(user_id - 1) % len(bios)]

        rows.append(
            (
                user_id,
                bio,
                birth_date,
                f"https://sql-project.com/profiles/user-{user_id}.jpg",
            )
        )

    return rows


def generate_user_verifications() -> list[tuple[Any, ...]]:
    rows = []
    verification_types = ["email", "phone", "identity", "address"]
    statuses = ["verified", "verified", "verified", "pending"]

    for user_id in range(1, 31):
        verification_type = verification_types[(user_id - 1) % 4]
        status = statuses[(user_id - 1) % 4]

        verified_at = (
            datetime(
                2025,
                2,
                1,
                tzinfo=timezone.utc,
            )
            + timedelta(days=user_id)
            if status == "verified"
            else None
        )

        rows.append(
            (
                user_id,
                verification_type,
                status,
                verified_at,
            )
        )

    return rows


def generate_addresses() -> list[tuple[Any, ...]]:
    cities = [
        ("Germany", "Berlin", "10115"),
        ("Germany", "Hamburg", "20095"),
        ("Germany", "Munich", "80331"),
        ("Germany", "Cologne", "50667"),
        ("Germany", "Frankfurt", "60311"),
    ]

    rows = []

    for address_id in range(1, 26):
        country, city, postal_code = cities[(address_id - 1) % len(cities)]

        rows.append(
            (
                country,
                city,
                postal_code,
                fake.street_name(),
                str(10 + address_id),
                str((address_id % 12) + 1),
            )
        )

    return rows


def generate_listings() -> list[tuple[Any, ...]]:
    property_types = ["apartment", "house", "room", "studio"]

    descriptions = [
        "Comfortable accommodation near the city centre.",
        "Quiet place with convenient public transport access.",
        "Bright and clean property suitable for short stays.",
        "Simple accommodation with all basic facilities.",
        "Cozy property in a residential area.",
    ]

    rows = []

    for listing_id in range(1, 26):
        host_user_id = ((listing_id - 1) % 10) + 1
        address_id = listing_id
        property_type = property_types[(listing_id - 1) % 4]
        max_guests = random.randint(1, 6)
        price = round(random.uniform(50, 220), 2)

        description = descriptions[
            (listing_id - 1) % len(descriptions)
        ]

        rows.append(
            (
                host_user_id,
                address_id,
                f"{property_type.title()} number {listing_id}",
                description,
                property_type,
                max_guests,
                price,
                datetime(
                    2025,
                    3,
                    1,
                    tzinfo=timezone.utc,
                )
                + timedelta(days=listing_id),
            )
        )

    return rows


def generate_listing_photos() -> list[tuple[Any, ...]]:
    rows = []

    for listing_id in range(1, 26):
        for display_order in range(1, 3):
            rows.append(
                (
                    listing_id,
                    (
                        "https://sql-project.com/listings/"
                        f"{listing_id}/photo-{display_order}.jpg"
                    ),
                    f"Photo {display_order} for listing {listing_id}",
                    display_order,
                )
            )

    return rows


def generate_house_rules() -> list[tuple[Any, ...]]:
    rule_names = [
        "No smoking",
        "No parties",
        "No pets",
        "Quiet hours after 23:00",
        "No additional guests",
        "No shoes inside",
        "No loud music",
        "No commercial photography",
        "No events",
        "No open flames",
        "Keep shared areas clean",
        "Lock doors when leaving",
        "Respect neighbours",
        "Separate household waste",
        "No food in bedrooms",
        "Report damages immediately",
        "Turn off lights when leaving",
        "Do not move furniture",
        "Use designated parking only",
        "Check out before 12:00",
    ]

    return [
        (
            rule_name,
            f"Property rules: {rule_name.lower()}.",
        )
        for rule_name in rule_names
    ]


def generate_listing_house_rules() -> list[tuple[Any, ...]]:
    rows = []

    for listing_id in range(1, 26):
        host_user_id = ((listing_id - 1) % 10) + 1

        first_rule = ((listing_id - 1) % 20) + 1
        second_rule = (listing_id % 20) + 1

        rows.append((listing_id, first_rule, host_user_id))
        rows.append((listing_id, second_rule, host_user_id))

    return rows


def generate_availability() -> list[tuple[Any, ...]]:
    rows = []
    start_date = date(2026, 8, 1)

    for listing_id in range(1, 26):
        for day_offset in range(4):
            rows.append(
                (
                    listing_id,
                    start_date + timedelta(days=day_offset),
                    day_offset != 3,
                )
            )

    return rows


def generate_pricing_periods() -> list[tuple[Any, ...]]:
    rows = []

    for listing_id in range(1, 26):
        host_user_id = ((listing_id - 1) % 10) + 1
        start_date = date(2026, 12, 1) + timedelta(days=listing_id)
        end_date = start_date + timedelta(days=5)
        price = round(random.uniform(80, 260), 2)

        rows.append(
            (
                listing_id,
                host_user_id,
                start_date,
                end_date,
                price,
            )
        )

    return rows


def generate_bookings() -> list[tuple[Any, ...]]:
    rows = []
    base_date = date(2026, 9, 1)

    for booking_id in range(1, 51):
        listing_id = ((booking_id - 1) % 25) + 1
        host_user_id = ((listing_id - 1) % 10) + 1

        guest_user_id = ((booking_id - 1) % 20) + 11

        check_in = base_date + timedelta(days=booking_id * 3)
        number_of_nights = random.randint(2, 6)
        check_out = check_in + timedelta(days=number_of_nights)

        guest_count = random.randint(1, 4)

        if booking_id <= 20:
            status = "cancelled"
        elif booking_id <= 35:
            status = "completed"
        elif booking_id <= 45:
            status = "confirmed"
        else:
            status = "pending"

        nightly_price = 70 + listing_id * 3
        total_amount = float(nightly_price * number_of_nights)

        rows.append(
            (
                listing_id,
                guest_user_id,
                check_in,
                check_out,
                guest_count,
                status,
                total_amount,
                datetime(
                    2026,
                    1,
                    1,
                    tzinfo=timezone.utc,
                )
                + timedelta(days=booking_id),
            )
        )

    return rows


def generate_booking_guests() -> list[tuple[Any, ...]]:
    rows = []

    for booking_id in range(1, 51):
        rows.append(
            (
                booking_id,
                fake.first_name(),
                fake.last_name(),
                random.randint(18, 65),
            )
        )

    return rows


def generate_services() -> list[tuple[Any, ...]]:
    service_names = [
        "Airport transfer",
        "Breakfast",
        "Late checkout",
        "Additional cleaning",
        "Bike rental",
        "Parking reservation",
        "Train station pickup",
        "Welcome package",
        "Grocery delivery",
        "Baby bed",
        "Extra towels",
        "Laundry service",
        "Local city tour",
        "Early check-in",
        "Pet cleaning",
        "Workspace setup",
        "Luggage storage",
        "Dinner delivery",
        "Car rental assistance",
        "Daily housekeeping",
    ]

    return [
        (
            service_name,
            f"Optional service: {service_name.lower()}.",
            round(10 + index * 1.5, 2),
        )
        for index, service_name in enumerate(service_names, start=1)
    ]


def generate_booking_services() -> list[tuple[Any, ...]]:
    rows = []

    for booking_id in range(1, 51):
        service_id = ((booking_id - 1) % 20) + 1
        provider_user_id = ((booking_id - 1) % 10) + 1
        quantity = random.randint(1, 3)
        price = round((15 + service_id * 3.5) * quantity, 2)

        rows.append(
            (
                booking_id,
                service_id,
                provider_user_id,
                quantity,
                price,
            )
        )

    return rows


def generate_payments() -> list[tuple[Any, ...]]:
    rows = []
    methods = [
        "credit_card",
        "debit_card",
        "paypal",
        "bank_transfer",
    ]

    for booking_id in range(1, 51):
        listing_id = ((booking_id - 1) % 25) + 1
        amount = float((70 + listing_id * 3) * 3)

        if booking_id <= 20:
            status = "refunded"
        elif booking_id <= 45:
            status = "completed"
        else:
            status = "pending"

        paid_at = (
            datetime(
                2026,
                2,
                1,
                tzinfo=timezone.utc,
            )
            + timedelta(days=booking_id)
            if status in {"completed", "refunded"}
            else None
        )

        rows.append(
            (
                booking_id,
                amount,
                methods[(booking_id - 1) % len(methods)],
                status,
                paid_at,
            )
        )

    return rows


def generate_payouts() -> list[tuple[Any, ...]]:
    rows = []

    for booking_id in range(21, 46):
        listing_id = ((booking_id - 1) % 25) + 1
        host_user_id = ((listing_id - 1) % 10) + 1
        amount = round((70 + listing_id * 3) * 3 * 0.90, 2)

        rows.append(
            (
                booking_id,
                host_user_id,
                amount,
                "completed",
                datetime(
                    2026,
                    4,
                    1,
                    tzinfo=timezone.utc,
                )
                + timedelta(days=booking_id),
            )
        )

    return rows


def generate_cancellations() -> list[tuple[Any, ...]]:
    reasons = [
        "Travel plans changed",
        "Guest illness",
        "Flight was cancelled",
        "Host maintenance issue",
        "Incorrect booking dates",
    ]

    rows = []

    for booking_id in range(1, 21):
        guest_user_id = ((booking_id - 1) % 20) + 11

        rows.append(
            (
                booking_id,
                guest_user_id,
                reasons[(booking_id - 1) % len(reasons)],
                round(random.uniform(50, 250), 2),
                datetime(
                    2026,
                    3,
                    1,
                    tzinfo=timezone.utc,
                )
                + timedelta(days=booking_id),
            )
        )

    return rows


def generate_reviews() -> list[tuple[Any, ...]]:
    rows = []

    review_comments = [
        "Clean and comfortable accommodation.",
        "The host was friendly and helpful.",
        "The property matched the description.",
        "Good location and easy check-in.",
        "Everything was clean and well prepared.",
        "The stay was pleasant and quiet.",
        "Communication with the host was easy.",
        "The guest followed all house rules.",
        "The guest was polite and respectful.",
        "The accommodation was good value.",
    ]

    for booking_id in range(21, 36):
        listing_id = ((booking_id - 1) % 25) + 1
        host_user_id = ((listing_id - 1) % 10) + 1
        guest_user_id = ((booking_id - 1) % 20) + 11

        created_at = datetime(
            2026,
            7,
            1,
            tzinfo=timezone.utc,
        ) + timedelta(days=booking_id)

        guest_review_comment = review_comments[
            (booking_id - 21) % len(review_comments)
        ]

        host_review_comment = review_comments[
            (booking_id - 20) % len(review_comments)
        ]

        rows.append(
            (
                booking_id,
                guest_user_id,
                host_user_id,
                random.randint(3, 5),
                guest_review_comment,
                created_at,
            )
        )

        rows.append(
            (
                booking_id,
                host_user_id,
                guest_user_id,
                random.randint(3, 5),
                host_review_comment,
                created_at + timedelta(hours=2),
            )
        )

    return rows


def generate_messages() -> list[tuple[Any, ...]]:
    rows = []

    guest_messages = [
        "Hello, is the accommodation available?",
        "What time is check-in?",
        "Could you provide the exact address?",
        "Is parking available near the property?",
        "Can I arrive later in the evening?",
        "Is Wi-Fi included?",
        "Thank you, everything is clear.",
        "We expect to arrive around 18:00.",
        "Could we request an early check-in?",
        "Is there public transport nearby?",
    ]

    host_messages = [
        "Hello, the accommodation is available.",
        "Check-in starts at 15:00.",
        "I will send the address before arrival.",
        "Parking is available near the building.",
        "Late arrival is not a problem.",
        "Yes, Wi-Fi is included.",
        "You are welcome.",
        "Thank you for the arrival information.",
        "Early check-in depends on availability.",
        "The nearest station is five minutes away.",
    ]

    for message_id in range(1, 61):
        booking_id = ((message_id - 1) % 50) + 1
        listing_id = ((booking_id - 1) % 25) + 1

        host_user_id = ((listing_id - 1) % 10) + 1
        guest_user_id = ((booking_id - 1) % 20) + 11

        message_index = (message_id - 1) % 10

        if message_id % 2 == 0:
            sender_user_id = guest_user_id
            receiver_user_id = host_user_id
            message_text = guest_messages[message_index]
        else:
            sender_user_id = host_user_id
            receiver_user_id = guest_user_id
            message_text = host_messages[message_index]

        rows.append(
            (
                booking_id,
                sender_user_id,
                receiver_user_id,
                message_text,
                datetime(
                    2026,
                    5,
                    1,
                    tzinfo=timezone.utc,
                )
                + timedelta(hours=message_id * 4),
                message_id % 3 != 0,
            )
        )

    return rows


def generate_favorites() -> list[tuple[Any, ...]]:
    rows = []
    used_pairs: set[tuple[int, int]] = set()

    while len(rows) < 60:
        user_id = random.randint(11, 30)
        listing_id = random.randint(1, 25)
        pair = (user_id, listing_id)

        if pair in used_pairs:
            continue

        used_pairs.add(pair)

        rows.append(
            (
                user_id,
                listing_id,
                datetime(
                    2026,
                    1,
                    1,
                    tzinfo=timezone.utc,
                )
                + timedelta(days=len(rows)),
            )
        )

    return rows


def build_seed_sql() -> str:
    statements = [
        "-- automatically generated by generate_seed.py",
        "",
        "SET search_path TO airbnb, public;",
        "",
        "BEGIN;",
        "",
        (
            "TRUNCATE TABLE "
            "messages, reviews, cancellations, payouts, payments, "
            "booking_services, booking_guests, bookings, "
            "pricing_periods, availability_calendar, "
            "listing_house_rules, house_rules, listing_photos, "
            "services, listings, addresses, user_verifications, "
            "user_profiles, favorites, users "
            "RESTART IDENTITY CASCADE;"
        ),
        "",
        insert_statement(
            "users",
            [
                "email",
                "first_name",
                "last_name",
                "phone_number",
                "created_at",
            ],
            generate_users(),
        ),
        insert_statement(
            "user_profiles",
            [
                "user_id",
                "bio",
                "birth_date",
                "profile_photo_url",
            ],
            generate_user_profiles(),
        ),
        insert_statement(
            "user_verifications",
            [
                "user_id",
                "verification_type",
                "verification_status",
                "verified_at",
            ],
            generate_user_verifications(),
        ),
        insert_statement(
            "addresses",
            [
                "country",
                "city",
                "postal_code",
                "street",
                "house_number",
                "apartment_number",
            ],
            generate_addresses(),
        ),
        insert_statement(
            "listings",
            [
                "host_user_id",
                "address_id",
                "title",
                "description",
                "property_type",
                "max_guests",
                "price_per_night",
                "created_at",
            ],
            generate_listings(),
        ),
        insert_statement(
            "listing_photos",
            [
                "listing_id",
                "photo_url",
                "caption",
                "display_order",
            ],
            generate_listing_photos(),
        ),
        insert_statement(
            "house_rules",
            [
                "rule_name",
                "description",
            ],
            generate_house_rules(),
        ),
        insert_statement(
            "listing_house_rules",
            [
                "listing_id",
                "house_rule_id",
                "added_by_user_id",
            ],
            generate_listing_house_rules(),
        ),
        insert_statement(
            "availability_calendar",
            [
                "listing_id",
                "available_date",
                "is_available",
            ],
            generate_availability(),
        ),
        insert_statement(
            "pricing_periods",
            [
                "listing_id",
                "created_by_user_id",
                "start_date",
                "end_date",
                "price_per_night",
            ],
            generate_pricing_periods(),
        ),
        insert_statement(
            "bookings",
            [
                "listing_id",
                "guest_user_id",
                "check_in_date",
                "check_out_date",
                "guest_count",
                "status",
                "total_amount",
                "created_at",
            ],
            generate_bookings(),
        ),
        insert_statement(
            "booking_guests",
            [
                "booking_id",
                "first_name",
                "last_name",
                "age",
            ],
            generate_booking_guests(),
        ),
        insert_statement(
            "services",
            [
                "service_name",
                "description",
                "base_price",
            ],
            generate_services(),
        ),
        insert_statement(
            "booking_services",
            [
                "booking_id",
                "service_id",
                "provider_user_id",
                "quantity",
                "price",
            ],
            generate_booking_services(),
        ),
        insert_statement(
            "payments",
            [
                "booking_id",
                "amount",
                "payment_method",
                "payment_status",
                "paid_at",
            ],
            generate_payments(),
        ),
        insert_statement(
            "payouts",
            [
                "booking_id",
                "host_user_id",
                "amount",
                "payout_status",
                "paid_at",
            ],
            generate_payouts(),
        ),
        insert_statement(
            "cancellations",
            [
                "booking_id",
                "cancelled_by_user_id",
                "reason",
                "refund_amount",
                "cancelled_at",
            ],
            generate_cancellations(),
        ),
        insert_statement(
            "reviews",
            [
                "booking_id",
                "author_user_id",
                "target_user_id",
                "rating",
                "comment",
                "created_at",
            ],
            generate_reviews(),
        ),
        insert_statement(
            "messages",
            [
                "booking_id",
                "sender_user_id",
                "receiver_user_id",
                "message_text",
                "sent_at",
                "is_read",
            ],
            generate_messages(),
        ),
        insert_statement(
            "favorites",
            [
                "user_id",
                "listing_id",
                "created_at",
            ],
            generate_favorites(),
        ),
        "COMMIT;",
        "",
    ]

    return "\n".join(statements)


def main() -> None:
    OUTPUT_FILE.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT_FILE.write_text(build_seed_sql(), encoding="utf-8")

    print(f"Generated: {OUTPUT_FILE}")
    print("The file contains test data for all 20 tables.")


if __name__ == "__main__":
    main()