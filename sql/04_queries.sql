-- Typical PostgreSQL operations O1-O7 from §1.5 of the report (parameters shown as literals).
SET search_path = ridelink, public;

-- O1 - insert a trip request
INSERT INTO trip (rider_id, category_id, pickup, dropoff, pickup_address, dropoff_address)
VALUES (1, 1, ST_SetSRID(ST_MakePoint(-8.611, 41.1496), 4326)::geography,
               ST_SetSRID(ST_MakePoint(-8.630, 41.1579), 4326)::geography, 'Aliados', 'Casa da Música')
RETURNING trip_id, requested_at;

-- O2 - atomic driver assignment (row lock on driver, status guard on trip prevents double assignment)
BEGIN;
  SELECT 1 FROM driver WHERE driver_id = 2001 AND status = 'APPROVED' FOR UPDATE;
  UPDATE trip SET driver_id = 2001, vehicle_id = 1, status = 'ACCEPTED'
   WHERE trip_id = (SELECT max(trip_id) FROM trip WHERE rider_id = 1 AND status = 'REQUESTED')
     AND status = 'REQUESTED'
  RETURNING trip_id, status;                 -- 0 rows => somebody else got it, ROLLBACK
COMMIT;

-- O3 - status transition (only legal predecessor allowed)
UPDATE trip SET status = 'IN_PROGRESS', started_at = now()
 WHERE trip_id = (SELECT max(trip_id) FROM trip WHERE rider_id = 1 AND status = 'ACCEPTED')
   AND status = 'ACCEPTED';

-- O4 - capture payment and issue invoice in one transaction
BEGIN;
  UPDATE trip SET status = 'COMPLETED', ended_at = now(), distance_km = 4.2
   WHERE trip_id = (SELECT max(trip_id) FROM trip WHERE rider_id = 1 AND status = 'IN_PROGRESS')
     AND status = 'IN_PROGRESS';
  WITH t AS (SELECT trip_id, requested_at FROM trip WHERE rider_id = 1 AND status = 'COMPLETED'
              ORDER BY ended_at DESC LIMIT 1),
  p AS (
    INSERT INTO payment (trip_id, trip_requested_at, method, status, amount, vat_amount, platform_fee, driver_payout)
    SELECT trip_id, requested_at, 'CARD', 'CAPTURED', 6.86, 0.39, 1.72, 5.14 FROM t
    RETURNING payment_id, amount)
  INSERT INTO invoice (payment_id, series, number, total)
  SELECT payment_id, 'A' || to_char(now(), 'YYYY'),
         (SELECT coalesce(max(number), 0) + 1 FROM invoice WHERE series = 'A' || to_char(now(), 'YYYY')),
         amount FROM p;
COMMIT;

-- O5 - paginated trip history of a rider (keyset pagination, uses idx_trip_rider_time)
SELECT trip_id, requested_at, status, distance_km
  FROM trip
 WHERE rider_id = 1 AND requested_at < now()
 ORDER BY requested_at DESC
 LIMIT 20;

-- O6 - weekly earnings per driver (run on the read replica)
SELECT t.driver_id, date_trunc('week', t.ended_at) AS week, count(*) AS trips, sum(p.driver_payout) AS earnings
  FROM trip t JOIN payment p ON p.trip_id = t.trip_id AND p.trip_requested_at = t.requested_at
 WHERE t.status = 'COMPLETED' AND p.status = 'CAPTURED'
 GROUP BY t.driver_id, date_trunc('week', t.ended_at)
 ORDER BY week DESC, earnings DESC
 LIMIT 20;

-- O6b - revenue per operator and day
SELECT o.legal_name, t.ended_at::date AS day, sum(p.amount) AS revenue
  FROM trip t
  JOIN payment p ON p.trip_id = t.trip_id AND p.trip_requested_at = t.requested_at
  JOIN driver d ON d.driver_id = t.driver_id
  JOIN tvde_operator o ON o.operator_id = d.operator_id
 GROUP BY o.legal_name, t.ended_at::date
 ORDER BY day DESC, revenue DESC
 LIMIT 20;

-- O7 - mandatory documents expiring in the next 30 days (daily batch; candidates for suspension)
SELECT d.driver_id, d.doc_type, d.valid_until
  FROM driver_document d
 WHERE d.valid_until BETWEEN current_date AND current_date + 30
 ORDER BY d.valid_until;

-- Suspend drivers whose mandatory document already expired
UPDATE driver SET status = 'SUSPENDED'
 WHERE status = 'APPROVED'
   AND driver_id IN (SELECT driver_id FROM driver_document
                      WHERE doc_type = 'TVDE_LICENSE' AND valid_until < current_date);
