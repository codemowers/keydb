#!/bin/bash
set -euxo pipefail
host="$(hostname)"
replicas=()
for node in ${REPLICAS}; do
  if [ "${host}" != "${node}" ]; then
      replicas+=("--replicaof ${node}.${SERVICE_NAME} 6379")
  fi
done
exec keydb-server /etc/redis/redis.conf \
    --bind "0.0.0.0" \
    --port 6379 \
    "${replicas[@]}" \
    $@
