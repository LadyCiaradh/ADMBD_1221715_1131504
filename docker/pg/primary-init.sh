#!/bin/bash
# Runs once on first initialisation of the primary: replication role + pg_hba entry.
set -e
psql -v ON_ERROR_STOP=1 -U postgres <<EOF
CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD '${REPLICATION_PASSWORD}';
EOF
echo "host replication replicator all scram-sha-256" >> "$PGDATA/pg_hba.conf"
