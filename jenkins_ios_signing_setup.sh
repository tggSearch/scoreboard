#!/bin/bash
# iOS signing via fastlane match (App Store Connect API, no Apple ID password)
set -euo pipefail

CERT_DIR="${CERT_DIR:-/Users/dan/Documents/cert}"
BUNDLE_ID="${BUNDLE_ID:-com.qualrb.scoreBoardPro}"
MATCH_GIT_BRANCH="${MATCH_GIT_BRANCH:-scoreboard}"
TEAM_ID="${TEAM_ID:-483V3ZF35S}"
IOS_API_KEY_ID="${IOS_API_KEY_ID:-4GN8P39YH9}"
IOS_API_ISSUER_ID="${IOS_API_ISSUER_ID:-aabd36b8-9b8f-44ed-a8db-5afff7624ad6}"
IOS_API_KEY_PATH="${IOS_API_KEY_PATH:-${CERT_DIR}/4GN8P39YH9.p8}"
# match git 加密口令（非 Apple 密码）；已内置默认值，无需手动设置
MATCH_PASSWORD="${MATCH_PASSWORD:-match}"
MATCH_READONLY="${MATCH_READONLY:-true}"
MOBILE_DIR="$(cd "$(dirname "$0")" && pwd)"
PROFILE_NAME="match AppStore ${BUNDLE_ID}"

resolve_profile_name() {
  python3 - "$PROVISION_DIR" "$BUNDLE_ID" "$PROFILE_NAME" <<'PY'
import os, sys, subprocess, plistlib
prov_dir, bundle_id, fallback = sys.argv[1:4]
best = None
best_mtime = -1
if not os.path.isdir(prov_dir):
    print(fallback)
    raise SystemExit
for name in os.listdir(prov_dir):
    if not name.endswith(".mobileprovision"):
        continue
    path = os.path.join(prov_dir, name)
    try:
        raw = subprocess.check_output(["security", "cms", "-D", "-i", path], stderr=subprocess.DEVNULL)
        data = plistlib.loads(raw)
    except Exception:
        continue
    entitlements = data.get("Entitlements") or {}
    app_id = entitlements.get("application-identifier") or ""
    if not app_id.endswith(bundle_id):
        continue
    pname = data.get("Name") or ""
    if not pname.startswith("match AppStore"):
        continue
    mtime = os.path.getmtime(path)
    if mtime > best_mtime:
        best_mtime = mtime
        best = pname
print(best or fallback)
PY
}

PROVISION_DIR="${HOME}/Library/MobileDevice/Provisioning Profiles"

log() { echo "[ios-signing/match] $*"; }

export PATH="/opt/homebrew/bin:/usr/local/bin:${PATH}"
export MATCH_PASSWORD
export MATCH_GIT_BRANCH
export IOS_API_KEY_ID IOS_API_ISSUER_ID IOS_API_KEY_PATH
export FASTLANE_SKIP_CONFIRMATIONS=1
export FASTLANE_HIDE_CHANGELOG=1
export CI="${CI:-true}"

# Optional proxy (Jenkins nodes often need it for Apple / GitHub)
if [ -z "${HTTP_PROXY:-}${http_proxy:-}" ]; then
  export HTTP_PROXY="${HTTP_PROXY:-http://127.0.0.1:7897}"
  export HTTPS_PROXY="${HTTPS_PROXY:-http://127.0.0.1:7897}"
  export http_proxy="${http_proxy:-$HTTP_PROXY}"
  export https_proxy="${https_proxy:-$HTTPS_PROXY}"
fi

sync_export_options() {
  local profile_name="$1"
  local export_options="${MOBILE_DIR}/ios/ExportOptions.plist"
  if [ ! -f "$export_options" ]; then
    mkdir -p "${MOBILE_DIR}/ios"
    cat > "$export_options" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>method</key>
	<string>app-store</string>
	<key>teamID</key>
	<string>${TEAM_ID}</string>
	<key>signingStyle</key>
	<string>manual</string>
	<key>signingCertificate</key>
	<string>iPhone Distribution</string>
	<key>provisioningProfiles</key>
	<dict>
		<key>${BUNDLE_ID}</key>
		<string>${profile_name}</string>
	</dict>
	<key>uploadSymbols</key>
	<true/>
	<key>uploadBitcode</key>
	<false/>
</dict>
</plist>
PLIST
    log "已创建 ExportOptions.plist"
    return
  fi
  /usr/libexec/PlistBuddy -c "Set :method app-store" "$export_options" 2>/dev/null || true
  /usr/libexec/PlistBuddy -c "Set :teamID ${TEAM_ID}" "$export_options" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add :teamID string ${TEAM_ID}" "$export_options"
  /usr/libexec/PlistBuddy -c "Set :signingStyle manual" "$export_options" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add :signingStyle string manual" "$export_options"
  /usr/libexec/PlistBuddy -c "Set :signingCertificate iPhone Distribution" "$export_options" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add :signingCertificate string iPhone Distribution" "$export_options"
  /usr/libexec/PlistBuddy -c "Set :provisioningProfiles:${BUNDLE_ID} ${profile_name}" "$export_options" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add :provisioningProfiles:${BUNDLE_ID} string ${profile_name}" "$export_options"
  log "已同步 ExportOptions.plist -> ${profile_name}"
}

sync_xcode_project() {
  local profile_name="$1"
  local pbxproj="${MOBILE_DIR}/ios/Runner.xcodeproj/project.pbxproj"
  if [ ! -f "$pbxproj" ]; then
    return
  fi
  python3 "${MOBILE_DIR}/scripts_sync_xcode_signing.py" "$pbxproj" "$profile_name" "$BUNDLE_ID" "$TEAM_ID"
  log "已同步 Xcode 签名 -> ${profile_name}"
}

log "Bundle ID: $BUNDLE_ID"
log "Match branch: $MATCH_GIT_BRANCH"
log "API Key: $IOS_API_KEY_ID"
log "Key path: $IOS_API_KEY_PATH"
log "Readonly: $MATCH_READONLY"

if [ ! -f "$IOS_API_KEY_PATH" ]; then
  echo "ERROR: missing App Store Connect API key: $IOS_API_KEY_PATH" >&2
  exit 1
fi

if [ ! -d "${MOBILE_DIR}/fastlane" ]; then
  echo "ERROR: missing ${MOBILE_DIR}/fastlane" >&2
  exit 1
fi

if ! command -v fastlane >/dev/null 2>&1; then
  echo "ERROR: fastlane not found in PATH" >&2
  exit 1
fi

if [ -n "${KEYCHAIN_PASSWORD:-}" ]; then
  KEYCHAIN_PATH="${HOME}/Library/Keychains/login.keychain-db"
  security unlock-keychain -p "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH" || true
  security set-keychain-settings -u "$KEYCHAIN_PATH" || true
  security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$KEYCHAIN_PASSWORD" "$KEYCHAIN_PATH" 2>/dev/null || true
fi

mkdir -p "$PROVISION_DIR"
cd "$MOBILE_DIR"

log "Running: fastlane sync_certificates readonly:${MATCH_READONLY}"
fastlane sync_certificates readonly:"${MATCH_READONLY}"

PROFILE_NAME="$(resolve_profile_name)"
log "Resolved profile: $PROFILE_NAME"
sync_export_options "$PROFILE_NAME"
sync_xcode_project "$PROFILE_NAME"

log "Done. Profile: $PROFILE_NAME"
security find-identity -v -p codesigning | head -20 || true
ls -la "$PROVISION_DIR" | tail -20 || true
