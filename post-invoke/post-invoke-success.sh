#!/usr/bin/env bash
# a script to run after a successful dpkg run
# see documentation for "post-invoke" in dpkg config
# by sahal

set -o errexit
set -o nounset
set -o pipefail
#set -o xtrace

# Using this output file, so a non-root user can run
# the script standalone (i.e. outside of the Post-Invoke-Success process)
# Also used for testing
REBOOT_REQUIRED_FILE="${PWD}/test/reboot-required"
CHECK_RESTART_FILE="${PWD}/test/check-restart-output-required"
#CHECK_RESTART_FILE="/var/run/check-restart-output"
#REBOOT_REQUIRED_FILE="/var/run/reboot-required"

SERVER_NAME="$(hostname)"

send_msg() {
  # send_msg - use a third party messging service API to send an alert to my phone
  # I don't want to setup outgoing email on servers (for abuse reasons)

  local msg="${1:-unset}"
  local data_body

  if [[ ${msg} == "service_restart" ]]; then
    echo "One or more services need to be restarted."
  elif [[ ${msg} == "server_restart" ]]; then
    echo "Server needs a reboot"
  elif [[ "${msg}" == "unset" ]]; then
    echo "Nothing to do."
    exit 0
  fi

  # do something with the msg brah
  data_body=$(jq --null-input \
    --arg msg_api_deviceid="${MSG_API_DEVICEID}" \
    --arg msg="${msg}" \
    --arg server_name="${SERVER_NAME}" \
    '{"device_uuid": $msg_api_deviceid, "title": "$server_name - $msg" }')
  echo curl -X POST "${MSG_API_ENDPOINT}" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${MSG_API_TOKEN}" \
    -d "${data_body}"
}

# checkrestart is a script provided by package: debian-goodies
# this returns a list of services that might have to be restarted
if ! test -f "${CHECK_RESTART_FILE}"; then
  # This line is so we can catch the failure of the test command
  # Used because of set -o errexit above
  exit 0
else
  grep --quiet "Found 0 processes using old versions of upgraded files" \
    < "${CHECK_RESTART_FILE}" > /dev/null 2>&1 || send_msg service_restart
fi

# /var/run/reboot-required exists when a reboot of the server is required
# e.g. when a new kernel was installed
if ! test -f "${REBOOT_REQUIRED_FILE}"; then
  # This line is so we can catch the failure of the test command
  # Used because of set -o errexit above
  exit 0
else
  send_msg server_restart
fi

