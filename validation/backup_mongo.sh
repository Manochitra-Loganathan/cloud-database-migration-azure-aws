#!/bin/bash
# MongoDB backup script
BACKUP_DIR="/var/backups/mongo"
DB="bcs_archive"
COLLECTION="policy_archive"
DATE=$(date +%F_%T)

mkdir -p $BACKUP_DIR
mongodump --db=$DB --collection=$COLLECTION --out="$BACKUP_DIR/mongo_backup_$DATE"
echo "MongoDB backup complete: $BACKUP_DIR/mongo_backup_$DATE"
