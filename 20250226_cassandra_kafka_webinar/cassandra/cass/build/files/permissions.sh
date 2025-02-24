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

logit "Sorting permissions"

sudo chown -R 999:999 /var/lib/cassandra
sudo chown -R 999:999 /var/log/cassandra

# Create AxonOps logs dir
chown -R 9988:9988 /var/log/axonops
chown -R 9988:9988 /var/lib/axonops
