# nextCloudDockerBackup

This project provides a robust backup solution for Nextcloud instances running in Docker containers using the default nextcloud docker installation method for Ubuntu 22.04. 
The script performs incremental backups of the Nextcloud data directory, configuration files, and PostgreSQL database, ensuring data integrity and efficient use of storage.

## Features

- **Incremental Backups**: Uses `rsync` for efficient incremental backups of the data directory.
- **Database Backup**: Backs up the PostgreSQL database using `pg_dumpall`.
- **Configuration Backup**: Backs up configuration files to ensure all settings are preserved.
- **Automated Maintenance Mode**: Puts Nextcloud into maintenance mode during backups to prevent inconsistencies.
- **Backup and Log Rotation**: Automatically rotates backups and logs to manage disk space.

## Prerequisites

- Docker installed and running on the host machine.
- Access to the Docker containers running Nextcloud and PostgreSQL.
- Sufficient disk space for backups.

## Installation

1. Clone this repository to your backup server:
  
   git clone https://github.com/yourusername/nextCloudDockerBackup.git
   
   cd nextCloudDockerBackup
   
   chmod +x nextCloudBackup.sh
   
   nano nextCloudBackup.sh
       BACKUP_DEST="/Data/backup"  #SET BACKUP DESTINATION

    sh nextCloudDockerBackup

Add to cron to run automatically if desired. 



      
