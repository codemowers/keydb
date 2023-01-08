#!/bin/bash
set -e
[[ -n "${REDIS_PASSWORD}" ]] && export REDISCLI_AUTH="${REDIS_PASSWORD}"
response="$(
  timeout -s 3 "${1}" \
  keydb-cli \
    -h localhost \
    -p 6379 \
    ping
)"
if [ "${response}" != "PONG" ]; then
  echo "${response}"
  exit 1
fi
