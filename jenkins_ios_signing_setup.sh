#!/bin/bash
# Score Board iOS 签名准备：安装描述文件，校验证书与 profile

set -euo pipefail

CERT_DIR="${CERT_DIR:-/Users/dan/Documents/cert}"
BUNDLE_ID="${BUNDLE_ID:-com.qualrb.scoreBoardPro}"
IOS_PROVISIONING_PROFILE="${IOS_PROVISIONING_PROFILE:-scoreboard}"
IOS_PROVISIONING_PROFILE_PATH="${IOS_PROVISIONING_PROFILE_PATH:-${CERT_DIR}/scoreboard.mobileprovision}"
PROVISION_DIR="${HOME}/Library/MobileDevice/Provisioning Profiles"
MOBILE_DIR="$(cd "$(dirname "$0")" && pwd)"

log() { echo "[ios-signing] $*"; }

install_profile() {
    local src="$1"
    local dest_name
    dest_name=$(/usr/libexec/PlistBuddy -c 'Print :UUID' /dev/stdin <<< "$(security cms -D -i "$src")" 2>/dev/null || true)
    if [ -z "$dest_name" ]; then
        dest_name=$(basename "$src")
    else
        dest_name="${dest_name}.mobileprovision"
    fi
    mkdir -p "$PROVISION_DIR"
    cp "$src" "${PROVISION_DIR}/${dest_name}"
    log "已安装描述文件: ${PROVISION_DIR}/${dest_name}"
}

sync_export_options() {
    local profile_name="$1"
    local export_options="${MOBILE_DIR}/ios/ExportOptions.plist"
    if [ ! -f "$export_options" ]; then
        return
    fi
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
    python3 - <<PY "$pbxproj" "$profile_name"
import re, sys
path, profile = sys.argv[1:3]
text = open(path).read()
pattern = re.compile(
    r'(97C147071CF9000F007C117D /\* Release \*/ = \{.*?name = Release;\n\t\t\};'
    r'|249021D4217E4FDB00AE95B9 /\* Profile \*/ = \{.*?name = Profile;\n\t\t\};'
    r'|97C147061CF9000F007C117D /\* Debug \*/ = \{.*?name = Debug;\n\t\t\};)',
    re.S,
)
def repl(block):
    if 'CODE_SIGN_STYLE = Manual' not in block:
        return block
    return re.sub(
        r'"PROVISIONING_PROFILE_SPECIFIER\[sdk=iphoneos\*\]" = [^;]+;',
        f'"PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]" = {profile};',
        block,
    )
new_text, count = pattern.subn(lambda m: repl(m.group(0)), text)
if count:
    open(path, 'w').write(new_text)
PY
    log "已同步 Xcode 签名 -> ${profile_name}"
}

log "Bundle ID: $BUNDLE_ID"
log "Profile Name: $IOS_PROVISIONING_PROFILE"
log "CERT_DIR: $CERT_DIR"

mkdir -p "$PROVISION_DIR"

installed=false
for candidate in \
    "$IOS_PROVISIONING_PROFILE_PATH" \
    "${CERT_DIR}/scoreboard.mobileprovision" \
    "${CERT_DIR}/scoreBoardPro.mobileprovision" \
    "${CERT_DIR}/com.qualrb.scoreBoardPro.mobileprovision" \
    "${HOME}/Downloads/scoreboard.mobileprovision"; do
    if [ -f "$candidate" ]; then
        install_profile "$candidate"
        installed=true
        break
    fi
done

if [ "$installed" = false ]; then
    log "未在常见路径找到 scoreboard 描述文件，使用系统已安装 profile"
    log "可放到: ${CERT_DIR}/scoreboard.mobileprovision 或 ${HOME}/Downloads/scoreboard.mobileprovision"
fi

log "可用签名证书:"
security find-identity -v -p codesigning || true

RESOLVED_PROFILE=""
if command -v python3 >/dev/null 2>&1; then
    RESOLVED_PROFILE=$(python3 - <<'PY' "$PROVISION_DIR" "$BUNDLE_ID" "$IOS_PROVISIONING_PROFILE" "$CERT_DIR"
import glob, os, plistlib, re, subprocess, sys, tempfile
provision_dir, bundle_id, preferred_name, cert_dir = sys.argv[1:5]

def profile_cert_fingerprints(path):
    raw = subprocess.check_output(["security", "cms", "-D", "-i", path])
    data = plistlib.loads(raw)
    fps = []
    for cert_bytes in data.get("DeveloperCertificates", []):
        tmp = tempfile.NamedTemporaryFile(delete=False, suffix=".der")
        try:
            tmp.write(cert_bytes)
            tmp.close()
            out = subprocess.check_output(
                ["openssl", "x509", "-inform", "DER", "-in", tmp.name, "-noout", "-fingerprint", "-sha1"],
                text=True,
            )
            fps.append(out.split("=", 1)[1].strip().replace(":", "").upper())
        finally:
            os.unlink(tmp.name)
    return fps

def keychain_distribution_fingerprints():
    try:
        out = subprocess.check_output(["security", "find-identity", "-v", "-p", "codesigning"], text=True)
    except subprocess.CalledProcessError:
        return []
    result = []
    for line in out.splitlines():
        m = re.match(r'\s*\d+\)\s+([0-9A-F]+)\s+"(.+)"\s*$', line.strip())
        if m and "Distribution" in m.group(2):
            result.append((m.group(1).upper(), m.group(2)))
    return result

def read_profile(path):
    raw = subprocess.check_output(["security", "cms", "-D", "-i", path])
    data = plistlib.loads(raw)
    app_id = data.get("Entitlements", {}).get("application-identifier", "")
    return {
        "path": path,
        "name": data.get("Name", ""),
        "type": data.get("ProvisionsAllDevices", False) and "Enterprise" or (
            "Development" if data.get("ProvisionedDevices") else "AppStore"
        ),
        "bundle_match": bundle_id in app_id,
        "fps": profile_cert_fingerprints(path),
    }

keychain_fps = keychain_distribution_fingerprints()
candidates = []
for path in glob.glob(provision_dir + "/*.mobileprovision"):
    try:
        info = read_profile(path)
    except Exception:
        continue
    if not info["bundle_match"]:
        continue
    cert_ok = bool(keychain_fps) and any(fp in info["fps"] for fp, _ in keychain_fps)
    print(
        f"[ios-signing] 发现 Profile: {info['name']} | 类型≈{info['type']} | 证书匹配={'是' if cert_ok else '否'}",
        file=sys.stderr,
    )
    candidates.append((info, cert_ok))

if not candidates:
    print(f"[ios-signing] ✗ 未找到 {bundle_id} 的描述文件", file=sys.stderr)
    sys.exit(1)

store_ok = [c for c, cert_ok in candidates if c["type"] == "AppStore" and cert_ok]
store_any = [c for c, _ in candidates if c["type"] == "AppStore"]
name_ok = [c for c, cert_ok in candidates if c["name"] == preferred_name and cert_ok]
name_any = [c for c, _ in candidates if c["name"] == preferred_name]

chosen = None
if name_ok:
    chosen = name_ok[0]
elif name_any:
    chosen = name_any[0]
    print(f"[ios-signing] ⚠ Profile {preferred_name} 证书不匹配，仍尝试使用", file=sys.stderr)
else:
    print(f"[ios-signing] ✗ 未找到名为 {preferred_name} 的描述文件", file=sys.stderr)
    print("[ios-signing] 请将 scoreboard.mobileprovision 放到:", file=sys.stderr)
    print(f"[ios-signing]   {cert_dir}/scoreboard.mobileprovision", file=sys.stderr)
    print("[ios-signing]   或设置 IOS_PROVISIONING_PROFILE_PATH 环境变量", file=sys.stderr)
    if candidates:
        print("[ios-signing] 当前 bundle 匹配的其他 profile:", file=sys.stderr)
        for c, _ in candidates:
            print(f"[ios-signing]   - {c['name']} ({c['type']})", file=sys.stderr)
    sys.exit(1)

if chosen["type"] == "Development":
    print(f"[ios-signing] ✗ {chosen['name']} 是 Development，不能用于 flutter build ipa", file=sys.stderr)
    sys.exit(1)

if keychain_fps and not any(fp in chosen["fps"] for fp, _ in keychain_fps):
    print(f"[ios-signing] ✗ {chosen['name']} 未包含 Distribution 证书 483V3ZF35S", file=sys.stderr)
    sys.exit(1)

print(f"[ios-signing] ✓ 选用 Profile: {chosen['name']} ({chosen['path']})", file=sys.stderr)
print(chosen["name"])
PY
)
fi

if [ -n "$RESOLVED_PROFILE" ]; then
    export IOS_PROVISIONING_PROFILE="$RESOLVED_PROFILE"
    echo "IOS_PROVISIONING_PROFILE=${RESOLVED_PROFILE}" > "${MOBILE_DIR}/ios/ci_provisioning_profile.env"
    sync_export_options "$RESOLVED_PROFILE"
    sync_xcode_project "$RESOLVED_PROFILE"
fi

log "最终 Profile Name: ${IOS_PROVISIONING_PROFILE:-unknown}"
log "iOS 签名准备完成"
