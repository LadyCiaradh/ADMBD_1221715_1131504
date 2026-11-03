-- Monthly partitions of ridelink.trip (run after 01_schema.sql).
-- In production a scheduled job (pg_cron / pg_partman) creates next month's partition ahead of time.
SET search_path = ridelink, public;

DO $$
DECLARE
    m date := date_trunc('month', now())::date - interval '1 month';
    i int;
BEGIN
    FOR i IN 0..4 LOOP   -- previous month + current + next 3
        EXECUTE format(
            'CREATE TABLE IF NOT EXISTS trip_%s PARTITION OF trip FOR VALUES FROM (%L) TO (%L)',
            to_char(m, 'YYYY_MM'), m, (m + interval '1 month')::date);
        m := (m + interval '1 month')::date;
    END LOOP;
END $$;
