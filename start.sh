#!/bin/sh

# Used to manage starting and stopping this container gracefully.
# It only takes up about 00.01 CPU % allotted to the container, you can verify
# by running `docker stats` after you start a container that uses this as
# as the CMD.

set -e

shutd () {
    printf "%s" "Shutting down the container gracefully..."

    # You can run clean commands here!

    last_signal="15"
}

trap 'shutd' TERM # Wait for terminal signal 15

echo "Started"

# Run non-blocking commands here

last_signal=""

# Keep the script running until this process receives the TERM signal to be
# stopped, which will trigger shutd and set the value to end the loop.
while [ "${last_signal}" != "15" ]; do
    sleep 1
done

echo "done"