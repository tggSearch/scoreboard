#!/usr/bin/env bash
set -euo pipefail
export MOBILE_DIR="$(cd "$(dirname "$0")" && pwd)"
export BUNDLE_ID="${BUNDLE_ID:-com.qualrb.scoreBoardPro}"
export MATCH_GIT_BRANCH="${MATCH_GIT_BRANCH:-scoreboard}"
export TEAM_ID="${TEAM_ID:-483V3ZF35S}"
CERT_DIR="${CERT_DIR:-/Users/dan/Documents/cert}"
source "${CERT_DIR}/jenkins_ios_signing_common.sh"
