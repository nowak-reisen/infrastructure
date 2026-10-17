#!/bin/bash
set -euo pipefail

ping_kuma() {
  local status="$1"
  local msg="$2"
  curl --fail \
       --silent \
       --show-error \
       --max-time 30 \
    "${SQLITE_VAULT_VERIFY_UPTIME_KUMA_URL}?status=${status}&msg=${msg}"
}

set +e
# Installed by the role's tasks; the service deploys this wrapper instead.
/usr/local/bin/sqlite-vault-verify "$@"
exit_code=$?
set -e

if [ "${exit_code}" -eq 0 ]; then
  echo "$(date --iso-8601=seconds) Verification succeeded"
  ping_kuma up verify-ok
else
  echo "$(date --iso-8601=seconds) Verification failed, exit code ${exit_code}"
  ping_kuma down "verify-failed-${exit_code}"
  exit "${exit_code}"
fi
