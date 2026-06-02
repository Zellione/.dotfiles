#!/usr/bin/env bash

MAX_RESTARTS=3
RESTART_DELAY=1
CRASH_WINDOW=30

if pidof hyprlock > /dev/null 2>&1; then
    exit 0
fi

crash_count=0
while [ $crash_count -lt $MAX_RESTARTS ]; do
    start_time=$(date +%s)
    hyprlock "$@"
    exit_code=$?
    if [ $exit_code -eq 0 ]; then
        exit 0
    fi
    end_time=$(date +%s)
    runtime=$((end_time - start_time))
    if [ $runtime -ge $CRASH_WINDOW ]; then
        crash_count=1
    else
        crash_count=$((crash_count + 1))
    fi
    logger -t hyprlock-watchdog "hyprlock crashed (exit $exit_code), restart $crash_count/$MAX_RESTARTS"
    notify-send -u critical "Lock Screen" "hyprlock crashed. Restarting... ($crash_count/$MAX_RESTARTS)"
    sleep $RESTART_DELAY
done

logger -t hyprlock-watchdog "hyprlock crashed $MAX_RESTARTS times in a row. Suspending."
notify-send -u critical "Lock Screen" "hyprlock keeps crashing. Suspending system."
sleep 2
systemctl suspend
