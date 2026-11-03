-- RideLink TVDE platform - PostgreSQL 16 + PostGIS schema (Iteration 1 draft)
-- Run: psql -U postgres -f sql/01_schema.sql
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS btree_gist;

CREATE SCHEMA IF NOT EXISTS ridelink;
SET search_path = ridelink, public;

-- ---------- Enumerations ----------
CREATE TYPE user_role        AS ENUM ('RIDER', 'DRIVER', 'ADMIN', 'SUPPORT');
CREATE TYPE driver_status    AS ENUM ('PENDING', 'APPROVED', 'SUSPENDED', 'REJECTED');
CREATE TYPE trip_status      AS ENUM ('REQUESTED', 'ACCEPTED', 'ARRIVED', 'IN_PROGRESS',
                                      'COMPLETED', 'CANCELLED_RIDER', 'CANCELLED_DRIVER', 'NO_DRIVER');
CREATE TYPE payment_status   AS ENUM ('PENDING', 'AUTHORIZED', 'CAPTURED', 'FAILED', 'REFUNDED');
CREATE TYPE payment_method   AS ENUM ('CARD', 'MBWAY', 'CASH');
CREATE TYPE document_type    AS ENUM ('TVDE_LICENSE', 'DRIVING_LICENSE', 'CRIMINAL_RECORD', 'INSURANCE', 'VEHICLE_INSPECTION');

-- ---------- Identity ----------
CREATE TABLE app_user (
    user_id        BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email          TEXT        NOT NULL UNIQUE CHECK (email ~* '^[^@\s]+@[^@\s]+\.[^@\s]+$'),
    phone          TEXT        NOT NULL UNIQUE,
    password_hash  TEXT        NOT NULL,
    full_name      TEXT        NOT NULL,
    role           user_role   NOT NULL,
    nif            CHAR(9)     CHECK (nif ~ '^[0-9]{9}$'),
    is_active      BOOLEAN     NOT NULL DEFAULT TRUE,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE tvde_operator (          -- licensed TVDE operator the driver works for
    operator_id    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    legal_name     TEXT     NOT NULL,
    nif            CHAR(9)  NOT NULL UNIQUE CHECK (nif ~ '^[0-9]{9}$'),
    license_no     TEXT     NOT NULL UNIQUE      -- IMT license
);

CREATE TABLE driver (
    driver_id      BIGINT PRIMARY KEY REFERENCES app_user(user_id),
    operator_id    BIGINT REFERENCES tvde_operator(operator_id),
    tvde_cert_no   TEXT          NOT NULL UNIQUE,  -- TVDE driver certificate
    status         driver_status NOT NULL DEFAULT 'PENDING',
    iban           TEXT,
    avg_rating     NUMERIC(3,2)  CHECK (avg_rating BETWEEN 1 AND 5),
    approved_at    TIMESTAMPTZ
);

CREATE TABLE rider (
    rider_id       BIGINT PRIMARY KEY REFERENCES app_user(user_id),
    avg_rating     NUMERIC(3,2)  CHECK (avg_rating BETWEEN 1 AND 5)
);

CREATE TABLE driver_document (
    document_id    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    driver_id      BIGINT        NOT NULL REFERENCES driver(driver_id),
    doc_type       document_type NOT NULL,
    doc_number     TEXT          NOT NULL,
    valid_from     DATE          NOT NULL,
    valid_until    DATE          NOT NULL,
    CHECK (valid_until > valid_from),
    UNIQUE (driver_id, doc_type, valid_from)
);

-- ---------- Fleet ----------
CREATE TABLE vehicle_category (
    category_id    SMALLINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name           TEXT          NOT NULL UNIQUE,      -- Standard, Comfort, XL, Green
    base_fare      NUMERIC(8,2)  NOT NULL CHECK (base_fare >= 0),
    per_km         NUMERIC(8,3)  NOT NULL CHECK (per_km >= 0),
    per_minute     NUMERIC(8,3)  NOT NULL CHECK (per_minute >= 0),
    min_fare       NUMERIC(8,2)  NOT NULL CHECK (min_fare >= 0)
);

CREATE TABLE vehicle (
    vehicle_id     BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_id    SMALLINT NOT NULL REFERENCES vehicle_category(category_id),
    plate          TEXT     NOT NULL UNIQUE,
    make           TEXT     NOT NULL,
    model          TEXT     NOT NULL,
    year           SMALLINT NOT NULL CHECK (year BETWEEN 2005 AND 2100),
    seats          SMALLINT NOT NULL CHECK (seats BETWEEN 2 AND 9),
    is_electric    BOOLEAN  NOT NULL DEFAULT FALSE
);

CREATE TABLE driver_vehicle (          -- N:M with history (driver may change car)
    driver_id      BIGINT NOT NULL REFERENCES driver(driver_id),
    vehicle_id     BIGINT NOT NULL REFERENCES vehicle(vehicle_id),
    valid_during   TSTZRANGE NOT NULL,
    PRIMARY KEY (driver_id, vehicle_id, valid_during),
    EXCLUDE USING gist (vehicle_id WITH =, valid_during WITH &&),   -- a car has one driver at a time
    EXCLUDE USING gist (driver_id  WITH =, valid_during WITH &&)    -- a driver drives one car at a time
);

-- ---------- Trips ----------
CREATE TABLE promo_code (
    code           TEXT PRIMARY KEY,
    discount_pct   NUMERIC(5,2) NOT NULL CHECK (discount_pct BETWEEN 0 AND 100),
    valid_until    TIMESTAMPTZ  NOT NULL,
    max_uses       INTEGER      CHECK (max_uses > 0)
);

CREATE TABLE trip (
    trip_id           BIGINT GENERATED ALWAYS AS IDENTITY,
    rider_id          BIGINT      NOT NULL REFERENCES rider(rider_id),
    driver_id         BIGINT      REFERENCES driver(driver_id),
    vehicle_id        BIGINT      REFERENCES vehicle(vehicle_id),
    category_id       SMALLINT    NOT NULL REFERENCES vehicle_category(category_id),
    status            trip_status NOT NULL DEFAULT 'REQUESTED',
    pickup            GEOGRAPHY(Point, 4326) NOT NULL,
    dropoff           GEOGRAPHY(Point, 4326) NOT NULL,
    pickup_address    TEXT,
    dropoff_address   TEXT,
    requested_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    started_at        TIMESTAMPTZ,
    ended_at          TIMESTAMPTZ,
    distance_km       NUMERIC(8,2) CHECK (distance_km >= 0),
    surge_multiplier  NUMERIC(3,2) NOT NULL DEFAULT 1.00 CHECK (surge_multiplier BETWEEN 1 AND 5),
    promo_code        TEXT REFERENCES promo_code(code),
    PRIMARY KEY (trip_id, requested_at),                       -- partition key must be in PK
    CHECK (ended_at IS NULL OR started_at IS NULL OR ended_at >= started_at),
    CHECK (status NOT IN ('ACCEPTED','ARRIVED','IN_PROGRESS','COMPLETED') OR driver_id IS NOT NULL)
) PARTITION BY RANGE (requested_at);                          -- monthly partitions (see 02_partitions.sql)

CREATE TABLE trip_default PARTITION OF trip DEFAULT;

CREATE TABLE payment (
    payment_id     BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    trip_id        BIGINT         NOT NULL,
    trip_requested_at TIMESTAMPTZ NOT NULL,
    method         payment_method NOT NULL,
    status         payment_status NOT NULL DEFAULT 'PENDING',
    amount         NUMERIC(10,2)  NOT NULL CHECK (amount >= 0),
    vat_amount     NUMERIC(10,2)  NOT NULL CHECK (vat_amount >= 0),
    platform_fee   NUMERIC(10,2)  NOT NULL CHECK (platform_fee >= 0),
    driver_payout  NUMERIC(10,2)  NOT NULL CHECK (driver_payout >= 0),
    psp_reference  TEXT,
    created_at     TIMESTAMPTZ    NOT NULL DEFAULT now(),
    UNIQUE (trip_id, trip_requested_at, method)
);
-- FK to a partitioned table needs the full PK (trip_id, requested_at)
ALTER TABLE payment ADD FOREIGN KEY (trip_id, trip_requested_at) REFERENCES trip(trip_id, requested_at);

CREATE TABLE invoice (                 -- fiscal document: immutable, long retention
    invoice_id     BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    payment_id     BIGINT      NOT NULL UNIQUE REFERENCES payment(payment_id),
    series         TEXT        NOT NULL,
    number         INTEGER     NOT NULL,
    issued_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    customer_nif   CHAR(9),
    total          NUMERIC(10,2) NOT NULL,
    UNIQUE (series, number)
);

CREATE TABLE driver_payout (
    payout_id      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    driver_id      BIGINT        NOT NULL REFERENCES driver(driver_id),
    period_start   DATE          NOT NULL,
    period_end     DATE          NOT NULL,
    total_amount   NUMERIC(12,2) NOT NULL CHECK (total_amount >= 0),
    paid_at        TIMESTAMPTZ,
    CHECK (period_end >= period_start),
    UNIQUE (driver_id, period_start, period_end)
);

-- ---------- Indexes (initial; to be validated with EXPLAIN in Iteration 2) ----------
CREATE INDEX idx_trip_rider_time  ON trip (rider_id,  requested_at DESC);
CREATE INDEX idx_trip_driver_time ON trip (driver_id, requested_at DESC) WHERE driver_id IS NOT NULL;
CREATE INDEX idx_trip_active      ON trip (status) WHERE status IN ('REQUESTED','ACCEPTED','ARRIVED','IN_PROGRESS');
CREATE INDEX idx_trip_pickup_gist ON trip USING gist (pickup);
CREATE INDEX idx_payment_trip     ON payment (trip_id, trip_requested_at);
CREATE INDEX idx_docs_expiry      ON driver_document (valid_until);

-- ---------- Example transactional operation ----------
-- Atomically assign a driver to a requested trip (prevents double-assignment).
-- BEGIN;
--   SELECT 1 FROM driver WHERE driver_id = $1 AND status = 'APPROVED' FOR UPDATE;
--   UPDATE trip SET driver_id = $1, vehicle_id = $2, status = 'ACCEPTED'
--    WHERE trip_id = $3 AND requested_at = $4 AND status = 'REQUESTED';
-- COMMIT;
