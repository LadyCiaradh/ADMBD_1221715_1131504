#!/bin/bash
# Last init script: enable synchronous replication only now, otherwise the temporary
# bootstrap server would wait forever for a standby that does not exist yet.
psql -v ON_ERROR_STOP=1 -U postgres -c "ALTER SYSTEM SET synchronous_standby_names = 'ANY 1 (replica1)'"
