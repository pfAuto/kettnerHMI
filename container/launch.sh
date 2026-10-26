#!/bin/bash
# File: /srv/shared/container/launch.sh

# Log file
LOGFILE=~/launch.log

# Delay the launch by 30 seconds (adjust as needed)
echo "$(date): Starting script with delay" >> $LOGFILE
sleep 30

# Navigate to the directory containing your docker-compose.yml file
cd /srv/shared/container/ || { echo "$(date): Failed to change directory" >> $LOGFILE; exit 1; }

# Start the Docker Compose container
docker compose up -d >> $LOGFILE 2>&1
echo "$(date): Docker Compose started" >> $LOGFILE
