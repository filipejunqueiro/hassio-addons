#!/bin/bash
set -e

echo "[Info] Show audio devices:"
aplay -l

CONFIG_PATH=/data/options.json

length=$(jq -r '.instances | length' "$CONFIG_PATH")

for i in $(seq 0 $((length - 1))); do
  SPEAKER=$(jq -r ".instances[$i].speaker // \"hw:0,1\"" "$CONFIG_PATH")
  DEVICE_TYPE=$(jq -r ".instances[$i].device_type // \"speaker\"" "$CONFIG_PATH")
  DEVICE_NAME=$(jq -r ".instances[$i].device_name" "$CONFIG_PATH")
  BITRATE=$(jq -r ".instances[$i].bitrate // 160" "$CONFIG_PATH")
  ALLOW_GUESTS=$(jq -r ".instances[$i].allow_guests // true" "$CONFIG_PATH")
  INITIAL_VOLUME=$(jq -r ".instances[$i].initial_volume // 80" "$CONFIG_PATH")
  SPOTIFY_USER=$(jq -r ".instances[$i].spotify_user // empty" "$CONFIG_PATH")
  SPOTIFY_PASSWORD=$(jq -r ".instances[$i].spotify_password // empty" "$CONFIG_PATH")

  DISCOVERY_ARG=""
  if [ "$ALLOW_GUESTS" != "true" ]; then
    DISCOVERY_ARG="--disable-discovery"
  fi

  echo "[$((i+1))/$length] Starting spotify connect for device: $DEVICE_NAME"

  LIBRESPOT_CMD="librespot -n \"$DEVICE_NAME\" --device \"$SPEAKER\" --bitrate $BITRATE --initial-volume $INITIAL_VOLUME --device-type $DEVICE_TYPE $DISCOVERY_ARG"

  if [ -n "$SPOTIFY_USER" ] && [ -n "$SPOTIFY_PASSWORD" ]; then
    LIBRESPOT_CMD="$LIBRESPOT_CMD -u \"$SPOTIFY_USER\" -p \"$SPOTIFY_PASSWORD\""
  fi

  if [ "$i" -eq $((length - 1)) ]; then
    # Last instance: exec to allow container to track process
    eval exec $LIBRESPOT_CMD
  else
    # Background others
    eval $LIBRESPOT_CMD &
  fi

  sleep 2
done
