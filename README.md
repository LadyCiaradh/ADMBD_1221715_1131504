# RideLink — TVDE Ride-hailing Platform (ADMBD)

Database Administration project, ISEP 2026/2027.

* PostgreSQL 16 + PostGIS (transactional/regulated data) and MongoDB 7 (telemetry, reviews, chat, tickets).
* Report source: [`docs/report.md`](docs/report.md) (Markdown). Build the PDF with `make` (needs `pandoc`, XeLaTeX, `graphviz`).
* Schemas: [`sql/01_schema.sql`](sql/01_schema.sql), [`mongo/01_collections.js`](mongo/01_collections.js).

Iteration 1 is tagged `iteration1`.

## Run the prototype

```bash
docker compose up -d                 # PG primary + sync standby, 3-node Mongo replica set
docker exec -i rl-pg-primary psql -U postgres < sql/03_seed.sql
docker exec -i rl-mongo1 mongosh < mongo/02_seed.js
```

Queries for the typical operations: `sql/04_queries.sql`, `mongo/03_queries.js`. Credentials are test values only.
