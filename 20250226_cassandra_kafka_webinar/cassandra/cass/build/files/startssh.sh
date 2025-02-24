#!/usr/bin/env bash
set -e

logit() {
    local logdate=$(date +"%Y%m%d-%H:%M:%S %Z")
    local message="[${logdate}] - ${*}"
    echo "${message}"
    logger "${message}"
}
eexit() {
    local error_str="$@"
    logit $error_str
    exit 1
}

logit "Starting SSH service..."
# Start the SSH daemon; by default, sshd will fork to the background
#exec sudo /usr/sbin/sshd -D -e
sudo /usr/sbin/sshd

logit $PATH

# Verify that the SSH daemon started successfully
if pgrep sshd > /dev/null; then
  logit "SSH service is running."
else
  eexit "Failed to start SSH service!"
fi