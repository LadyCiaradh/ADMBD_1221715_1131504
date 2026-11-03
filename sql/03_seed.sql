-- Synthetic data for tests and benchmarks (TEST DATA ONLY). Run after 01 and 02.
-- Adjust the numbers in the generate_series calls to scale the data set.
SET search_path = ridelink, public;
BEGIN;

INSERT INTO tvde_operator (legal_name, nif, license_no)
SELECT 'Operator ' || i, lpad((500000000 + i)::text, 9, '0'), 'IMT-' || lpad(i::text, 5, '0')
FROM generate_series(1, 5) i;

INSERT INTO vehicle_category (name, base_fare, per_km, per_minute, min_fare) VALUES
  ('Standard', 1.00, 0.700, 0.150, 3.50),
  ('Comfort',  1.50, 0.900, 0.200, 4.50),
  ('XL',       2.00, 1.100, 0.250, 6.00),
  ('Green',    1.00, 0.750, 0.150, 3.50);

-- 2 000 riders (ids 1..2000) then 200 drivers (ids 2001..2200)
INSERT INTO app_user (email, phone, password_hash, full_name, role, nif)
SELECT 'rider' || i || '@example.test', '91' || lpad(i::text, 7, '0'),
       'x-test-hash', 'Rider ' || i, 'RIDER', lpad((100000000 + i)::text, 9, '0')
FROM generate_series(1, 2000) i;
INSERT INTO rider (rider_id) SELECT user_id FROM app_user WHERE role = 'RIDER';

INSERT INTO app_user (email, phone, password_hash, full_name, role, nif)
SELECT 'driver' || i || '@example.test', '92' || lpad(i::text, 7, '0'),
       'x-test-hash', 'Driver ' || i, 'DRIVER', lpad((200000000 + i)::text, 9, '0')
FROM generate_series(1, 200) i;
INSERT INTO driver (driver_id, operator_id, tvde_cert_no, status)
SELECT user_id, 1 + (user_id % 5), 'CERT-' || user_id, 'APPROVED' FROM app_user WHERE role = 'DRIVER';

INSERT INTO vehicle (category_id, plate, make, model, year, seats, is_electric)
SELECT 1 + (i % 4), 'AA-' || lpad(i::text, 3, '0') || '-ZZ', 'Toyota', 'Corolla',
       2018 + (i % 8), 4, (i % 4 = 3)
FROM generate_series(1, 200) i;
INSERT INTO driver_vehicle (driver_id, vehicle_id, valid_during)
SELECT 2000 + i, i, tstzrange(now() - interval '120 days', NULL) FROM generate_series(1, 200) i;

-- Driver documents: some expire soon (used by operation O7)
INSERT INTO driver_document (driver_id, doc_type, doc_number, valid_from, valid_until)
SELECT 2000 + i, 'TVDE_LICENSE', 'DOC-' || i, current_date - 700,
       current_date + ((i * 7) % 400) - 20
FROM generate_series(1, 200) i;

-- 20 000 trips between the first day of last month and now (matches partitions in 02)
WITH base AS (
  SELECT i,
         date_trunc('month', now()) - interval '1 month'
           + random() * (now() - (date_trunc('month', now()) - interval '1 month')) AS req,
         1 + floor(random() * 2000)::int  AS rider,
         2001 + floor(random() * 200)::int AS drv,
         random() AS r_status, 1 + random() * 20 AS km, 5 + random() * 40 AS mins
  FROM generate_series(1, 20000) i
)
INSERT INTO trip (rider_id, driver_id, vehicle_id, category_id, status, pickup, dropoff,
                  requested_at, started_at, ended_at, distance_km)
SELECT rider,
       CASE WHEN r_status < 0.9 THEN drv END,
       CASE WHEN r_status < 0.9 THEN drv - 2000 END,
       1 + (i % 4),
       CASE WHEN r_status < 0.9 THEN 'COMPLETED'::trip_status ELSE 'CANCELLED_RIDER'::trip_status END,
       ST_SetSRID(ST_MakePoint(-8.65 + random() * 0.1, 41.12 + random() * 0.07), 4326)::geography,
       ST_SetSRID(ST_MakePoint(-8.65 + random() * 0.1, 41.12 + random() * 0.07), 4326)::geography,
       req,
       CASE WHEN r_status < 0.9 THEN req + interval '3 minutes' END,
       CASE WHEN r_status < 0.9 THEN req + interval '3 minutes' + mins * interval '1 minute' END,
       CASE WHEN r_status < 0.9 THEN round(km::numeric, 2) END
FROM base;

-- One payment per completed trip (6% VAT included, 25% platform fee), one invoice per payment
INSERT INTO payment (trip_id, trip_requested_at, method, status, amount, vat_amount, platform_fee, driver_payout)
SELECT trip_id, requested_at, (ARRAY['CARD','MBWAY','CASH'])[1 + (trip_id % 3)]::payment_method, 'CAPTURED',
       a, round(a - a / 1.06, 2), round(a * 0.25, 2), round(a * 0.75, 2)
FROM trip, LATERAL (SELECT round(greatest(3.5, 1 + distance_km * 0.8)::numeric, 2) AS a) f
WHERE status = 'COMPLETED';

INSERT INTO invoice (payment_id, series, number, customer_nif, total)
SELECT payment_id, 'A' || to_char(now(), 'YYYY'), row_number() OVER (ORDER BY payment_id), NULL, amount
FROM payment;

COMMIT;
ANALYZE;
