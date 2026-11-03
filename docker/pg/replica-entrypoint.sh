#!/bin/bash
# Builds the standby from the primary with pg_basebackup on first start, then runs postgres.
set -e
export PGDATA=/var/lib/postgresql/data
if [ ! -s "$PGDATA/PG_VERSION" ]; then
  until pg_isready -h "$PRIMARY_HOST" -U postgres; do sleep 2; done
  rm -rf "$PGDATA"/* 2>/dev/null || true
  # -R writes primary_conninfo + standby.signal; PGAPPNAME makes it match synchronous_standby_names
  pg_basebackup -h "$PRIMARY_HOST" -U replicator -D "$PGDATA" -R -X stream -P
  chmod 700 "$PGDATA"
fi
exec postgres -c hot_standby=on
