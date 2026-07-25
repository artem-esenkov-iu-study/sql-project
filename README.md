# SQL project - airbnb postgreSQL database

A database for a housing booking service. The project is implemented in PostgreSQL and contains 20 linked tables for users, listings, bookings, payments, reviews and messages


## Technologies

PostgreSQL, SQL, Python, Faker, pgAdmin


## Main files

- `database/schema.sql` - DB structure
- `database/seed.sql` - test data
- `database/queries.sql` - basic queries
- `database/tests.sql` - data checks
- `database/metadata.sql` - metadata
- `scripts/generate_seed.py` - data generator
- `model/` - ERD


## Execution order

1. `reset.sql`
2. `schema.sql`
3. `seed.sql`
4. `tests.sql`
5. `queries.sql`
6. `metadata.sql`

Each table contains a minimum of 20 records