#!/bin/bash
set -e

PGDATA="/var/lib/postgresql/data"

echo "Waiting for master to be ready..."
until pg_isready -h "${MASTER_HOST}" -p "${MASTER_PORT}" -U "${POSTGRES_USER}"; do
    echo "Master not ready yet, retrying in 2s..."
    sleep 2
done

if [ -f "${PGDATA}/standby.signal" ] && [ -f "${PGDATA}/postgresql.conf" ]; then
    echo "PGDATA already initialized, starting PostgreSQL directly..."
    chown -R postgres:postgres "${PGDATA}"
    chmod 700 "${PGDATA}"
    exec gosu postgres postgres -D "${PGDATA}"
fi

echo "First run: performing base backup..."

rm -rf "${PGDATA:?}"/*

PGPASSWORD="${REPLICATION_PASSWORD}" pg_basebackup \
    -h "${MASTER_HOST}" \
    -p "${MASTER_PORT}" \
    -U "${REPLICATION_USER}" \
    -D "${PGDATA}" \
    -Fp \
    -Xs \
    -P \
    -R \
    --slot=replica_slot

echo "Base backup completed."

cat >> "${PGDATA}/postgresql.auto.conf" <<EOF
primary_slot_name = 'replica_slot'
hot_standby = on
EOF

chown -R postgres:postgres "${PGDATA}"
chmod 700 "${PGDATA}"

echo "Replica initialized successfully. Starting PostgreSQL..."

exec gosu postgres postgres -D "${PGDATA}"
