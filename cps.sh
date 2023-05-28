#!/bin/bash

# Define the list of authorized device MAC addresses
authorized_devices=("AA:BB:CC:DD:EE:FF" "11:22:33:44:55:66")

# Define the whitelist file
whitelist_file="whitelist.txt"

# Define the log file
log_file="unauthorized_devices.log"

# Function to check if a device is whitelisted
is_whitelisted() {
    local device=$1
    if grep -qFx "$device" "$whitelist_file"; then
        return 0
    else
        return 1
    fi
}

# Function to check if a device is authorized
is_authorized() {
    local device=$1
    if grep -qFx "$device" "$whitelist_file"; then
        return 0
    fi
    for auth_device in "${authorized_devices[@]}"; do
        if [ "$auth_device" == "$device" ]; then
            return 0
        fi
    done
    return 1
}

# Function to send an alert
send_alert() {
    local device=$1
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    local subject="ALERT: Unauthorized device detected - $device"
    local body="An unauthorized device ($device) was detected on your network at $timestamp."
    echo "$body" | mail -s "$subject" email@example.com
    echo "ALERT: Unauthorized device detected - $device ($timestamp)"
    log_unauthorized_device "$device" "$timestamp"
}

# Function to log unauthorized devices
log_unauthorized_device() {
    local device=$1
    local timestamp=$2
    echo "UNAUTHORIZED DEVICE: $device - $timestamp" >> "$log_file"
}

# Main script
while true; do
    # Get the list of connected devices
    connected_devices=$(arp -a | awk '{print $4}')

    # Iterate over the connected devices
    for device in $connected_devices; do
        # Check if the device is authorized or whitelisted
        if ! is_whitelisted "$device" && ! is_authorized "$device"; then
            send_alert "$device"
        fi
    done

    # Wait for some time before checking again
    sleep 60
done
