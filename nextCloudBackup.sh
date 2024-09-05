#!/bin/bash

# Backup destination on the host machine
BACKUP_DEST="/Data/backup"  #SET BACKUP DESTINATION
DATE=$(date +"%Y%m%d")
NEW_BACKUP="${BACKUP_DEST}/nextcloud_backup_${DATE}"
LATEST_LINK="${BACKUP_DEST}/latest"
LOG_FILE="${BACKUP_DEST}/backup_log_${DATE}.log"

# Docker container names
APP_CONTAINER="nextcloud-aio-nextcloud"  #If you've renamed your containers - UserData Container
DB_CONTAINER="nextcloud-aio-database"    #If you've renamed your containers - Database

# Correct role for database backup
DB_ROLE="nextcloud"  # Use the role that works, as identified earlier

# Function to log messages
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a "$LOG_FILE"
}

log_message "Backup process started."

# Enable maintenance mode in the Nextcloud app
log_message "Enabling maintenance mode."
docker exec -i $APP_CONTAINER sudo -u www-data php /var/www/html/occ maintenance:mode --on 2>&1 | tee -a "$LOG_FILE"

# Create the new backup directory on the host
mkdir -p "${NEW_BACKUP}"

# Backup data directory using docker cp
log_message "Copying data directory from container to host."
docker cp "${APP_CONTAINER}:/mnt/ncdata" "${NEW_BACKUP}/data" 2>>"$LOG_FILE"

# Check if copy was successful
if [ $? -eq 0 ]; then
    log_message "Data directory copied successfully."
else
    log_message "Error: Data directory copy failed."
    exit 1
fi

# Backup the PostgreSQL database using the correct role
log_message "Backing up PostgreSQL database."
docker exec -i $DB_CONTAINER pg_dumpall -U $DB_ROLE > "$NEW_BACKUP/backupdb.sql" 2>>"$LOG_FILE"
if [ $? -eq 0 ]; then
    log_message "Database backup completed successfully."
else
    log_message "Error: Database backup failed."
    exit 1
fi

# Backup the configuration directory using docker cp
log_message "Copying configuration directory from container to host."
docker cp "${APP_CONTAINER}:/var/www/html/config" "${NEW_BACKUP}/config" 2>>"$LOG_FILE"
if [ $? -eq 0 ]; then
    log_message "Configuration directory copied successfully."
else
    log_message "Error: Configuration directory copy failed."
fi

# Update the latest link to the new backup
log_message "Updating latest link to the current backup."
rm -f "${LATEST_LINK}"
ln -s "${NEW_BACKUP}" "${LATEST_LINK}"

# Disable maintenance mode
log_message "Disabling maintenance mode."
docker exec -i $APP_CONTAINER sudo -u www-data php /var/www/html/occ maintenance:mode --off 2>&1 | tee -a "$LOG_FILE"

log_message "Backup process completed successfully. All files saved to ${NEW_BACKUP}."
