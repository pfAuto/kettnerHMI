#!/bin/bash

LOGFILE=~/kiosk.log
CONTAINER=container-edg-1-1
IGNITION_URL=http://localhost:8088/data/perspective/client/Edge
LOAD_PROFILE=/home/operator/load-profile
KIOSK_PROFILE=/home/operator/kiosk-profile

#Launch docker loading
sed -i 's|<h1 id="status">.*</h1>|<h1 id="status">Docker Container is Starting...</h1>|' /srv/shared/kiosk/loading.html
google-chrome --user-data-dir=$LOAD_PROFILE --disable-crash-reporter --kiosk --no-first-run file:///srv/shared/kiosk/loading.html &

#Wait for container
echo "$(date): Waiting for $CONTAINER" >> "$LOGFILE"
while [ "$(docker inspect -f '{{.State.Running}}' $CONTAINER 2>/dev/null)" != "true" ]; do
  sleep 2
done

sed -i 's|<h1 id="status">.*</h1>|<h1 id="status">Ignition Gateway is starting...</h1>|' /srv/shared/kiosk/loading.html
google-chrome --user-data-dir=$LOAD_PROFILE --kiosk --disable-crash-reporter --no-first-run file:///srv/shared/kiosk/loading.html &

#Wait for Ignition Gateway ready
echo "$(date): Waiting for Ignition WebPage at $IGNITION_URL..." >> "$LOGFILE"
until curl -s -f $IGNITION_URL >/dev/null 2>&1; do
  sleep 2
done

echo "$(date): Ignition WepPage is up, launching Chrome..." >> "$LOGFILE"

#Launch Chrome
exec google-chrome --user-data-dir=$KIOSK_PROFILE --kiosk --no-first-run http://localhost:8088/data/perspective/client/Edge >> "$LOGFILE" 2>&1 &

sleep 3
pkill -f "load-profile"

while true; do
  if ! pgrep -af "chrome.*--user-data-dir=$KIOSK_PROFILE" > /dev/null;then
    google-chrome --user-data-dir=$KIOSK_PROFILE --kiosk --no-first-run http://localhost:8088/data/perspective/client/Edge >> "$LOGFILE" 2>&1 &
  fi
  sleep 5
done






