#!/bin/bash
set -e

mkdir -p "$PGDATA" /var/run/postgresql
chown -R postgres:postgres "$PGDATA" /var/run/postgresql

# Если база еще не инициализирована, создаем новый PostgreSQL-кластер.
if [ ! -s "$PGDATA/PG_VERSION" ]; then
    echo "Initializing PostgreSQL database in $PGDATA..."

    su - postgres -c "/usr/lib/postgresql/15/bin/initdb -D \"$PGDATA\""

    su - postgres -c "/usr/lib/postgresql/15/bin/pg_ctl -D \"$PGDATA\" -o \"-c listen_addresses='*'\" -w start"

    su - postgres -c "psql --command \"CREATE USER $POSTGRES_USER WITH PASSWORD '$POSTGRES_PASSWORD';\""
    su - postgres -c "createdb -O $POSTGRES_USER $POSTGRES_DB"

    echo "host all all 0.0.0.0/0 md5" >> "$PGDATA/pg_hba.conf"
    echo "listen_addresses='*'" >> "$PGDATA/postgresql.conf"

    su - postgres -c "/usr/lib/postgresql/15/bin/pg_ctl -D \"$PGDATA\" -m fast -w stop"
fi

# Запускаем PostgreSQL в фоне.
su - postgres -c "/usr/lib/postgresql/15/bin/postgres -D \"$PGDATA\"" &

# Запускаем Nginx в foreground, чтобы контейнер не завершался.
nginx -g "daemon off;"
