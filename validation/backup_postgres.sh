#!/bin/bash
# PostgreSQL logical backup script
PG_DB="bcs_prod"
PG_USER="admin"
PG_BACKUP_DIR="/var/backups/bcs"
PG_DATE=$(date +%F_%T)

mkdir -p $PG_BACKUP_DIR
pg_dump -U $PG_USER -d $PG_DB -F c -f "$PG_BACKUP_DIR/${PG_DB}_$PG_DATE.backup"
echo "PostgreSQL backup completed: $PG_BACKUP_DIR/${PG_DB}_$PG_DATE.backup"
