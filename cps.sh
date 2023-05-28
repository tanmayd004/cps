#!/bin/bash

# Define the list of authorized device MAC addresses

authorized_devices=("AA:BB:CC:DD:EE:FF" "11:22:33:44:55:66")

# Function to check if a device is authorized

is_authorized() {

    local device=$1

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

    echo "ALERT: Unauthorized device detected - $device"

    # Add code here to send an alert via email, SMS, or any other desired method

}

# Main script

while true; do

    # Get the list of connected devices

    connected_devices=$(arp -a | awk '{print $4}')

    # Iterate over the connected devices

    for device in $connected_devices; do

        # Check if the device is authorized

        if ! is_authorized "$device"; then

            send_alert "$device"

        fi

    done

    # Wait for some time before checking again

    sleep 60

done
