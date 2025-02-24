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

logit $PATH


processcount=$(ps -ef | grep java | grep -ie cassandra | grep -v grep | wc -l)

if (( ${processcount} != 0 )) ; then
    eexit "ERROR - Cassandra process already exists.."
else
    cassandra -v
    cassandra > /dev/null 2>&1
    logit "Cassandra Started"
fi