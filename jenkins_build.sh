#!/bin/bash

# ============================================
# Score Board - Jenkins CI/CD 构建脚本
# 支持 iOS IPA、Android APK 和 AAB 构建
# ============================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

# ==================== 配置区域 ====================

# 应用信息
APP_NAME="scoreBoard"
BUNDLE_ID="com.qualrb.scoreBoardPro"
TEAM_ID="483V3ZF35S"
IOS_PROVISIONING_PROFILE="scoreboard"
IOS_PROVISIONING_PROFILE_PATH="${IOS_PROVISIONING_PROFILE_PATH:-$HOME/Downloads/scoreboard.mobileprovision}"

# 证书与密钥目录（敏感信息放在 jenkins_secrets.env，勿提交到 Git）
CERT_DIR="${CERT_DIR:-/Users/dan/Documents/cert}"
JENKINS_SECRETS_FILE="${JENKINS_SECRETS_FILE:-${CERT_DIR}/jenkins_secrets.env}"

load_jenkins_secrets() {
    if [ -f "$JENKINS_SECRETS_FILE" ]; then
        set -a
        # shellcheck source=/dev/null
        source "$JENKINS_SECRETS_FILE"
        set +a
        log_info "已加载密钥配置: $JENKINS_SECRETS_FILE"
    fi
}

resolve_ios_api_credentials() {
    if [ ! -f "$IOS_API_KEY_PATH" ]; then
        local candidate
        for candidate in \
            "${CERT_DIR}/4GN8P39YH9.p8" \
            "${CERT_DIR}"/AuthKey_*.p8 \
            "${CERT_DIR}"/*.p8; do
            if [ -f "$candidate" ]; then
                IOS_API_KEY_PATH="$candidate"
                log_info "自动发现 iOS API Key 文件: $IOS_API_KEY_PATH"
                break
            fi
        done
    fi

    if [ -z "$IOS_API_KEY_ID" ] && [ -f "$IOS_API_KEY_PATH" ]; then
        local key_base
        key_base=$(basename "$IOS_API_KEY_PATH" .p8)
        IOS_API_KEY_ID="${key_base#AuthKey_}"
        log_info "从 p8 文件名解析 IOS_API_KEY_ID: $IOS_API_KEY_ID"
    fi

    if [ -z "$IOS_API_ISSUER_ID" ]; then
        # Qualrb 团队 App Store Connect Issuer ID（与 Texas Win Rate 等项目相同）
        IOS_API_ISSUER_ID="aabd36b8-9b8f-44ed-a8db-5afff7624ad6"
        log_info "使用 Qualrb 团队默认 IOS_API_ISSUER_ID"
    fi
}

# iOS App Store Connect API 配置
IOS_API_KEY_ID="${IOS_API_KEY_ID:-}"
IOS_API_ISSUER_ID="${IOS_API_ISSUER_ID:-}"
IOS_API_KEY_PATH="${IOS_API_KEY_PATH:-${CERT_DIR}/4GN8P39YH9.p8}"

# Android Google Play API 配置
ANDROID_SERVICE_ACCOUNT_JSON="${ANDROID_SERVICE_ACCOUNT_JSON:-${CERT_DIR}/tudan.json}"
ANDROID_PACKAGE_NAME="com.qualrb.scoreboard"
# ScoreBoard 专用 upload key（勿与 texasWinRate 共用）
GOOGLE_PLAY_UPLOAD_SHA1="${GOOGLE_PLAY_UPLOAD_SHA1:-8B:60:AB:7A:BA:1E:28:B4:3C:99:60:D5:2D:B0:01:A9:AB:79:50:FF}"

# 腾讯云 COS 配置 (APK 上传)
TENCENT_SECRET_ID="${TENCENT_SECRET_ID:-}"
TENCENT_SECRET_KEY="${TENCENT_SECRET_KEY:-}"
COS_BUCKET="${COS_BUCKET:-apk-1251046496}"
COS_BUCKET_PATH="${COS_BUCKET_PATH:-apk}"
COS_REGION="${COS_REGION:-ap-guangzhou}"

# 默认值
DEFAULT_BUILD_TARGET="all"
DEFAULT_BUILD_MODE="release"

# ==================== 颜色定义 ====================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ==================== 日志函数 ====================

log_info() {
    echo -e "${BLUE}[INFO]${NC} $(date '+%Y-%m-%d %H:%M:%S') $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $(date '+%Y-%m-%d %H:%M:%S') $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $(date '+%Y-%m-%d %H:%M:%S') $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%Y-%m-%d %H:%M:%S') $1"
}

log_step() {
    echo ""
    echo -e "${CYAN}========================================${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}========================================${NC}"
    echo ""
}

# ==================== 帮助信息 ====================

show_help() {
    cat << EOF

Score Board - Jenkins CI/CD 构建脚本

用法:
    ./jenkins_build.sh [选项]

选项:
    -t, --target <target>    构建目标: all, android, ios, apk, aab (默认: all)
    -m, --mode <mode>        构建模式: release, profile, debug (默认: release)
    -v, --version <version>  版本号覆盖 (格式: x.x.x+buildNumber)
    -c, --clean              执行清理构建
    -s, --skip-tests         跳过测试
    --no-codesign            跳过 iOS 签名 (生成未签名的 xcarchive)
    -u, --upload             构建后上传到应用商店
    --upload-only            仅上传 (跳过构建，使用已有产物)
    --track <track>          Google Play 发布轨道: internal, alpha, beta, production (默认: internal)
    -h, --help               显示帮助信息

环境变量:
    FLUTTER_HOME             Flutter SDK 路径
    ANDROID_HOME             Android SDK 路径
    BUILD_NUMBER             Jenkins 构建号 (自动获取)

上传配置:
    iOS IPA  -> App Store Connect (p8 密钥: ${IOS_API_KEY_PATH})
    AAB      -> Google Play (JSON: ${ANDROID_SERVICE_ACCOUNT_JSON})
    APK      -> 腾讯云 COS (${COS_BUCKET}/${COS_BUCKET_PATH})
    密钥文件 -> ${JENKINS_SECRETS_FILE} 或 Jenkins 环境变量

示例:
    ./jenkins_build.sh -t all -m release
    ./jenkins_build.sh -t android -c
    ./jenkins_build.sh -t ios -v 1.2.0+100
    ./jenkins_build.sh --target apk --mode profile
    
    # 构建并上传
    ./jenkins_build.sh -t all -u
    ./jenkins_build.sh -t ios --upload
    ./jenkins_build.sh -t aab --upload --track production
    
    # 仅上传已有产物
    ./jenkins_build.sh -t ios --upload-only
    ./jenkins_build.sh -t aab --upload-only --track beta

EOF
}

# ==================== 参数解析 ====================

BUILD_TARGET="$DEFAULT_BUILD_TARGET"
BUILD_MODE="$DEFAULT_BUILD_MODE"
VERSION_OVERRIDE=""
CLEAN_BUILD=false
SKIP_TESTS=false
NO_CODESIGN=false
UPLOAD_ENABLED=false
UPLOAD_ONLY=false
GOOGLE_PLAY_TRACK="internal"
PREPARE_ANDROID_SIGNING_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --prepare-android-signing)
            PREPARE_ANDROID_SIGNING_ONLY=true
            shift
            ;;
        -t|--target)
            BUILD_TARGET="$2"
            shift 2
            ;;
        -m|--mode)
            BUILD_MODE="$2"
            shift 2
            ;;
        -v|--version)
            VERSION_OVERRIDE="$2"
            shift 2
            ;;
        -c|--clean)
            CLEAN_BUILD=true
            shift
            ;;
        -s|--skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        --no-codesign)
            NO_CODESIGN=true
            shift
            ;;
        -u|--upload)
            UPLOAD_ENABLED=true
            shift
            ;;
        --upload-only)
            UPLOAD_ONLY=true
            UPLOAD_ENABLED=true
            shift
            ;;
        --track)
            GOOGLE_PLAY_TRACK="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            log_error "未知参数: $1"
            show_help
            exit 1
            ;;
    esac
done

# ==================== 验证参数 ====================

validate_params() {
    case $BUILD_TARGET in
        all|android|ios|apk|aab)
            ;;
        *)
            log_error "无效的构建目标: $BUILD_TARGET"
            log_info "有效选项: all, android, ios, apk, aab"
            exit 1
            ;;
    esac

    case $BUILD_MODE in
        release|profile|debug)
            ;;
        *)
            log_error "无效的构建模式: $BUILD_MODE"
            log_info "有效选项: release, profile, debug"
            exit 1
            ;;
    esac
}

# ==================== 环境检查 ====================

check_environment() {
    log_step "检查构建环境"

    # 添加 Homebrew 和常见工具路径到 PATH（优先使用 Homebrew）
    # /opt/homebrew/bin - Apple Silicon Mac 的 Homebrew
    # /usr/local/bin - Intel Mac 的 Homebrew
    export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/.rbenv/shims:$HOME/.rvm/bin:$PATH"
    
    # 检查 Flutter
    if [ -n "$FLUTTER_HOME" ] && [ -f "$FLUTTER_HOME/bin/flutter" ]; then
        export PATH="$FLUTTER_HOME/bin:$PATH"
    fi

    if ! command -v flutter &> /dev/null; then
        log_error "Flutter 未安装或不在 PATH 中"
        log_info "请设置 FLUTTER_HOME 环境变量或确保 flutter 在 PATH 中"
        exit 1
    fi

    log_info "Flutter 版本:"
    flutter --version

    # 检查 Android SDK (如果需要构建 Android)
    if [[ "$BUILD_TARGET" =~ ^(all|android|apk|aab)$ ]]; then
        if [ -z "$ANDROID_HOME" ] && [ -z "$ANDROID_SDK_ROOT" ]; then
            # 尝试常见路径
            if [ -d "/Users/Shared/android-sdk" ]; then
                export ANDROID_HOME="/Users/Shared/android-sdk"
            elif [ -d "$HOME/Library/Android/sdk" ]; then
                export ANDROID_HOME="$HOME/Library/Android/sdk"
            elif [ -d "$HOME/Android/Sdk" ]; then
                export ANDROID_HOME="$HOME/Android/Sdk"
            else
                log_warning "ANDROID_HOME 未设置，Android 构建可能失败"
            fi
        fi
        
        if [ -n "$ANDROID_HOME" ]; then
            export ANDROID_SDK_ROOT="$ANDROID_HOME"
            log_info "Android SDK: $ANDROID_HOME"
        fi
    fi

    # 检查 iOS 构建环境 (如果需要)
    if [[ "$BUILD_TARGET" =~ ^(all|ios)$ ]]; then
        if [[ "$OSTYPE" != "darwin"* ]]; then
            log_error "iOS 构建需要在 macOS 上运行"
            if [ "$BUILD_TARGET" == "ios" ]; then
                exit 1
            else
                log_warning "跳过 iOS 构建"
            fi
        else
            if ! command -v xcodebuild &> /dev/null; then
                log_error "Xcode 命令行工具未安装"
                exit 1
            fi
            log_info "Xcode 版本: $(xcodebuild -version | head -1)"
            
            # 检查 CocoaPods
            if ! command -v pod &> /dev/null; then
                log_warning "CocoaPods 未在 PATH 中找到，尝试常见安装位置..."
                
                # 尝试常见的 CocoaPods 安装路径
                POSSIBLE_POD_PATHS=(
                    "/usr/local/bin/pod"
                    "/opt/homebrew/bin/pod"
                    "$HOME/.rbenv/shims/pod"
                    "$HOME/.rvm/gems/ruby-*/bin/pod"
                    "$HOME/Library/Ruby/*/bin/pod"
                    "$(which -a pod 2>/dev/null | head -1)"
                )
                
                POD_FOUND=false
                for pod_path in "${POSSIBLE_POD_PATHS[@]}"; do
                    # 展开通配符
                    for expanded_path in $pod_path; do
                        if [ -f "$expanded_path" ] && [ -x "$expanded_path" ]; then
                            log_info "找到 CocoaPods: $expanded_path"
                            export PATH="$(dirname "$expanded_path"):$PATH"
                            POD_FOUND=true
                            break 2
                        fi
                    done
                done
                
                if [ "$POD_FOUND" = false ]; then
                    log_warning "CocoaPods 未安装，尝试安装..."
                    
                    # 尝试安装 CocoaPods
                    if command -v gem &> /dev/null; then
                        log_info "使用 gem 安装 CocoaPods..."
                        gem install cocoapods --user-install || {
                            log_error "CocoaPods 安装失败"
                            log_info "请手动安装: sudo gem install cocoapods"
                            exit 1
                        }
                        
                        # 添加 RubyGems 用户 bin 目录到 PATH
                        if [ -d "$HOME/.gem/ruby" ]; then
                            RUBY_VERSION=$(ls -t "$HOME/.gem/ruby" | head -1)
                            if [ -n "$RUBY_VERSION" ]; then
                                export PATH="$HOME/.gem/ruby/$RUBY_VERSION/bin:$PATH"
                            fi
                        fi
                    else
                        log_error "gem 未安装，无法自动安装 CocoaPods"
                        log_info "请手动安装 CocoaPods: https://cocoapods.org/"
                        exit 1
                    fi
                fi
            fi
            
            # 验证 CocoaPods 可用
            if command -v pod &> /dev/null; then
                log_info "CocoaPods 版本: $(pod --version)"
                log_info "CocoaPods 路径: $(which pod)"
            else
                log_error "CocoaPods 仍然不可用"
                exit 1
            fi
        fi
    fi

    log_success "环境检查完成"
}

# ==================== 版本处理 ====================

get_version() {
    if [ -n "$VERSION_OVERRIDE" ]; then
        echo "$VERSION_OVERRIDE"
    else
        grep "version:" pubspec.yaml | head -1 | awk '{print $2}'
    fi
}

parse_version() {
    local version="$1"
    VERSION_NAME=$(echo "$version" | cut -d'+' -f1)
    VERSION_CODE=$(echo "$version" | cut -d'+' -f2)
    
    # 如果没有 build number，使用 Jenkins BUILD_NUMBER 或时间戳
    if [ "$VERSION_CODE" == "$VERSION_NAME" ] || [ -z "$VERSION_CODE" ]; then
        VERSION_CODE="${BUILD_NUMBER:-$(date +%Y%m%d%H%M)}"
    fi
}

# ==================== Android 签名准备 ====================

keytool_works() {
    local bin="$1"
    # macOS /usr/bin/keytool 是占位脚本，无 JRE 时会失败
    [ -x "$bin" ] || return 1
    "$bin" -help >/dev/null 2>&1
}

resolve_keytool() {
    local candidate
    for candidate in \
        "${JAVA_HOME:+$JAVA_HOME/bin/keytool}" \
        "/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/keytool" \
        "/Applications/Android Studio 2.app/Contents/jbr/Contents/Home/bin/keytool" \
        "/opt/homebrew/opt/openjdk/bin/keytool" \
        "/opt/homebrew/opt/openjdk@21/bin/keytool" \
        "$(command -v keytool 2>/dev/null || true)"; do
        if [ -n "$candidate" ] && keytool_works "$candidate"; then
            echo "$candidate"
            return 0
        fi
    done
    return 1
}

normalize_sha1() {
    echo "$1" | tr '[:lower:]' '[:upper:]' | tr -d ' :'
}

get_keystore_sha1() {
    local keystore="$1"
    local store_pass="$2"
    local keytool_bin
    keytool_bin="$(resolve_keytool)" || {
        log_error "未找到可用的 keytool（请安装 JDK 或设置 JAVA_HOME）"
        return 1
    }
    # 用 openssl 从导出证书读指纹更稳；失败再回退 keytool 文本解析
    local tmp_cert sha1
    tmp_cert="$(mktemp)"
    if "$keytool_bin" -exportcert -rfc -keystore "$keystore" -alias upload \
        -storepass "$store_pass" -file "$tmp_cert" >/dev/null 2>&1; then
        sha1=$(openssl x509 -in "$tmp_cert" -noout -fingerprint -sha1 2>/dev/null \
            | sed 's/.*=//' | tr -d ' ')
    fi
    rm -f "$tmp_cert"
    if [ -z "$sha1" ]; then
        sha1=$("$keytool_bin" -list -v -keystore "$keystore" -storepass "$store_pass" 2>/dev/null \
            | grep "SHA1:" | head -1 | sed 's/.*SHA1: //' | tr -d ' \t' || true)
    fi
    echo "$sha1"
}

materialize_keystore_from_env() {
    local dest="$PROJECT_ROOT/android/app/upload-keystore.jks"

    if [ -n "${ANDROID_UPLOAD_KEYSTORE_BASE64:-}" ]; then
        log_info "从 ANDROID_UPLOAD_KEYSTORE_BASE64 写入 keystore..."
        mkdir -p "$(dirname "$dest")"
        printf '%s' "$ANDROID_UPLOAD_KEYSTORE_BASE64" | base64 --decode > "$dest"
        log_success "已从环境变量生成 upload-keystore.jks"
        return 0
    fi

    if [ -n "${ANDROID_UPLOAD_KEYSTORE_DATA:-}" ]; then
        log_info "从 ANDROID_UPLOAD_KEYSTORE_DATA 写入 keystore..."
        mkdir -p "$(dirname "$dest")"
        printf '%s' "$ANDROID_UPLOAD_KEYSTORE_DATA" | base64 --decode > "$dest"
        log_success "已从环境变量生成 upload-keystore.jks"
        return 0
    fi

    return 1
}

verify_android_upload_key() {
    local keystore="$PROJECT_ROOT/android/app/upload-keystore.jks"
    local props="$PROJECT_ROOT/android/key.properties"
    if [ ! -f "$keystore" ] || [ ! -f "$props" ]; then
        return 1
    fi
    local store_pass
    store_pass=$(grep '^storePassword=' "$props" | cut -d= -f2-)
    local sha1
    sha1=$(get_keystore_sha1 "$keystore" "$store_pass")
    if [ -z "$sha1" ]; then
        log_error "无法读取 keystore 证书指纹，请检查 key.properties 密码"
        return 1
    fi
    local expected actual
    expected=$(normalize_sha1 "$GOOGLE_PLAY_UPLOAD_SHA1")
    actual=$(normalize_sha1 "$sha1")
    if [ "$actual" != "$expected" ]; then
        log_error "Keystore SHA1 与 Google Play upload key 不匹配"
        log_error "  当前: $sha1"
        log_error "  需要: $GOOGLE_PLAY_UPLOAD_SHA1"
        log_error "  请使用 ${CERT_DIR}/scoreboard-upload-keystore.jks（勿用 texas 共用 keystore）"
        return 1
    fi
    log_success "Upload key SHA1 校验通过: $sha1"
    return 0
}

prepare_android_signing() {
    log_info "准备 Android 签名..."
    log_info "CERT_DIR=${CERT_DIR}"
    log_info "Google Play upload key SHA1: ${GOOGLE_PLAY_UPLOAD_SHA1}"

    local keystore_source=""
    local keystore_candidates=(
        "${ANDROID_UPLOAD_KEYSTORE:-}"
        "${CERT_DIR}/scoreboard-upload-keystore.jks"
        "${PROJECT_ROOT}/certs/scoreboard-upload-keystore.jks"
    )

    local candidate
    for candidate in "${keystore_candidates[@]}"; do
        if [ -n "$candidate" ] && [ -f "$candidate" ]; then
            keystore_source="$candidate"
            break
        fi
    done

    if [ -z "$keystore_source" ]; then
        if materialize_keystore_from_env; then
            keystore_source="$PROJECT_ROOT/android/app/upload-keystore.jks"
        else
            log_error "未找到 ScoreBoard 专用 release keystore"
            log_info "Google Play upload key SHA1: ${GOOGLE_PLAY_UPLOAD_SHA1}"
            log_info "请将 scoreboard-upload-keystore.jks 放到: ${CERT_DIR}/"
            log_info "或通过 ANDROID_UPLOAD_KEYSTORE / ANDROID_UPLOAD_KEYSTORE_BASE64 指定"
            log_info "证书 PEM（供 Play Console 重置 upload key）: ${CERT_DIR}/scoreboard-upload-certificate.pem"
            return 1
        fi
    else
        mkdir -p "$PROJECT_ROOT/android/app"
        cp "$keystore_source" "$PROJECT_ROOT/android/app/upload-keystore.jks"
        log_info "已从 ${keystore_source} 复制 upload-keystore.jks"
    fi

    if [ -f "${CERT_DIR}/scoreboard-key.properties" ]; then
        cp "${CERT_DIR}/scoreboard-key.properties" "$PROJECT_ROOT/android/key.properties"
        log_info "已从证书目录复制 scoreboard-key.properties（专用签名）"
    elif [ -n "${ANDROID_KEY_STORE_PASSWORD:-}" ]; then
        cat > "$PROJECT_ROOT/android/key.properties" << EOF
storePassword=${ANDROID_KEY_STORE_PASSWORD}
keyPassword=${ANDROID_KEY_PASSWORD:-${ANDROID_KEY_STORE_PASSWORD}}
keyAlias=${ANDROID_KEY_ALIAS:-upload}
storeFile=upload-keystore.jks
EOF
        log_info "已从环境变量生成 android/key.properties"
    else
        cat > "$PROJECT_ROOT/android/key.properties" << 'EOF'
storePassword=scoreboard123
keyPassword=scoreboard123
keyAlias=upload
storeFile=upload-keystore.jks
EOF
        log_info "已生成 scoreboard 专用 key.properties"
    fi

    verify_android_upload_key || return 1
}

require_android_release_signing() {
    prepare_android_signing || return 1
    log_success "Android release 签名已就绪"
    return 0
}

# ==================== 构建准备 ====================

prepare_build() {
    log_step "准备构建"

    if [[ "$BUILD_TARGET" == "apk" || "$BUILD_TARGET" == "aab" || "$BUILD_TARGET" == "android" || "$BUILD_TARGET" == "all" ]]; then
        require_android_release_signing || exit 1
        if [[ -f "$PROJECT_ROOT/android/scripts/ensure_ndk_r28.sh" ]]; then
            log_info "确认 Android NDK r28（release native 16KB）..."
            bash "$PROJECT_ROOT/android/scripts/ensure_ndk_r28.sh" || true
        fi
    fi

    APP_VERSION=$(get_version)
    parse_version "$APP_VERSION"

    log_info "应用名称: $APP_NAME"
    log_info "版本号: $VERSION_NAME"
    log_info "构建号: $VERSION_CODE"
    log_info "构建目标: $BUILD_TARGET"
    log_info "构建模式: $BUILD_MODE"

    # 创建输出目录
    rm -rf output
    mkdir -p output

    # 清理构建 (如果需要)
    if [ "$CLEAN_BUILD" = true ]; then
        log_info "执行清理构建..."
        flutter clean
    fi

    # 获取依赖
    log_info "获取依赖包..."
    flutter pub get

    log_success "构建准备完成"
}

# ==================== Android 构建 ====================

build_apk() {
    log_step "构建 Android APK"

    local git_commit
    git_commit="$(git -C "$PROJECT_ROOT" rev-parse --short HEAD 2>/dev/null || echo unknown)"
    log_info "Git commit: $git_commit（若设备仍报 MainApplication，说明装的不是本次构建产物）"

    local build_args="--$BUILD_MODE"
    build_args="$build_args --build-name=$VERSION_NAME"
    build_args="$build_args --build-number=$VERSION_CODE"
    build_args="$build_args --split-per-abi"
    build_args="$build_args --target-platform=android-arm,android-arm64"

    log_info "执行命令: flutter build apk $build_args"
    # Gradle 拉取 NDK / Google Maven 时避免 Jenkins 全局代理干扰
    (
        unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy ALL_PROXY all_proxy
        export JAVA_HOME="${JAVA_HOME:-}"
        flutter build apk $build_args
    )

    # 分 ABI 产物：COS 主包用 arm64（覆盖绝大多数真机）；保留 v7a 供极老 32 位机
    local apk_path="build/app/outputs/flutter-apk/app-arm64-v8a-$BUILD_MODE.apk"
    if [ ! -f "$apk_path" ]; then
        apk_path="build/app/outputs/flutter-apk/app-$BUILD_MODE.apk"
    fi
    if [ -f "$apk_path" ]; then
        cp "$apk_path" "output/${APP_NAME}.apk"
        log_success "APK 构建完成: output/${APP_NAME}.apk"
        
        # 显示 APK 信息
        local apk_size=$(du -h "output/${APP_NAME}.apk" | cut -f1)
        log_info "APK 大小: $apk_size"

        local v7a_path="build/app/outputs/flutter-apk/app-armeabi-v7a-$BUILD_MODE.apk"
        if [ -f "$v7a_path" ]; then
            cp "$v7a_path" "output/${APP_NAME}-armeabi-v7a.apk"
            log_info "32 位备用包: output/${APP_NAME}-armeabi-v7a.apk ($(du -h "output/${APP_NAME}-armeabi-v7a.apk" | cut -f1))"
        fi

        if [[ -f "$PROJECT_ROOT/android/scripts/verify_release_apk.sh" ]]; then
            log_info "校验 release APK（native 库 + 16 KB 对齐）..."
            export ANDROID_HOME="${ANDROID_HOME:-}"
            export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$ANDROID_HOME}"
            if ! bash "$PROJECT_ROOT/android/scripts/verify_release_apk.sh" "$apk_path"; then
                log_error "APK 未通过 release 校验（含 16 KB native 对齐），禁止上传 COS"
                return 1
            fi
        elif [[ -f "$PROJECT_ROOT/android/scripts/check_16kb_elf.sh" ]]; then
            log_info "校验 APK arm64 16 KB native 对齐（Android 15+ 必需）..."
            if ! bash "$PROJECT_ROOT/android/scripts/check_16kb_elf.sh" "" "$apk_path"; then
                log_error "APK 未通过 16 KB 对齐检查，在部分新系统上会闪退。请安装 NDK r28 后重编：sdkmanager \"ndk;28.2.13676358\""
                return 1
            fi
        fi
    else
        log_error "APK 构建失败，文件不存在: $apk_path"
        return 1
    fi
}

build_aab() {
    log_step "构建 Android App Bundle"

    local build_args="--$BUILD_MODE"
    build_args="$build_args --build-name=$VERSION_NAME"
    build_args="$build_args --build-number=$VERSION_CODE"
    build_args="$build_args --target-platform=android-arm,android-arm64"

    log_info "执行命令: flutter build appbundle $build_args"
    (
        unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy ALL_PROXY all_proxy
        export JAVA_HOME="${JAVA_HOME:-}"
        flutter build appbundle $build_args
    )

    local aab_path="build/app/outputs/bundle/$BUILD_MODE/app-$BUILD_MODE.aab"
    if [ -f "$aab_path" ]; then
        local output_name="${APP_NAME}-${VERSION_NAME}+${VERSION_CODE}.aab"
        cp "$aab_path" "output/$output_name"
        log_success "AAB 构建完成: output/$output_name"
        
        # 显示 AAB 信息
        local aab_size=$(du -h "output/$output_name" | cut -f1)
        log_info "AAB 大小: $aab_size"
    else
        log_error "AAB 构建失败，文件不存在: $aab_path"
        return 1
    fi
}

# ==================== iOS 构建 ====================

check_ios_signing() {
    log_info "检查 iOS 手动签名配置..."

    # 显示可用的签名身份
    log_info "可用的签名身份:"
    security find-identity -v -p codesigning 2>/dev/null || true

    # 检查描述文件
    local provision_dir="$HOME/Library/MobileDevice/Provisioning Profiles"
    if [ -d "$provision_dir" ]; then
        local count=$(ls -1 "$provision_dir"/*.mobileprovision 2>/dev/null | wc -l | tr -d ' ')
        log_info "已安装描述文件数量: $count"
    else
        log_warning "描述文件目录不存在: $provision_dir"
    fi
}

build_ios() {
    log_step "构建 iOS IPA"

    # 检查是否在 macOS 上
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "iOS 构建需要在 macOS 上运行"
        return 1
    fi

    # 检查签名配置（手动签名模式）
    if [ "$NO_CODESIGN" != true ]; then
        if [ -f "$PROJECT_ROOT/jenkins_ios_signing_setup.sh" ]; then
            log_info "准备 iOS 签名..."
            bash "$PROJECT_ROOT/jenkins_ios_signing_setup.sh"
            if [ -f "$PROJECT_ROOT/ios/ci_provisioning_profile.env" ]; then
                # shellcheck source=/dev/null
                source "$PROJECT_ROOT/ios/ci_provisioning_profile.env"
            fi
        fi
        check_ios_signing
    fi

    # 安装 CocoaPods 依赖
    log_info "安装 CocoaPods 依赖..."
    cd ios
    pod install --repo-update || pod install
    cd ..

    # 构建参数
    local build_args="--$BUILD_MODE"
    build_args="$build_args --build-name=$VERSION_NAME"
    build_args="$build_args --build-number=$VERSION_CODE"

    # 检查 ExportOptions.plist
    local export_options="ios/ExportOptions.plist"
    if [ ! -f "$export_options" ]; then
        log_warning "ExportOptions.plist 不存在，创建默认配置..."
        create_export_options
    fi

    if [ "$NO_CODESIGN" = true ]; then
        log_info "执行命令: flutter build ios $build_args --no-codesign"
        flutter build ios $build_args --no-codesign
        
        log_warning "已跳过代码签名，生成未签名的构建"
        log_info "Archive 位置: build/ios/archive/Runner.xcarchive"
    else
        log_info "执行命令: flutter build ipa $build_args --export-options-plist=$export_options"
        flutter build ipa $build_args --export-options-plist="$export_options"

        # 查找并复制 IPA
        local ipa_path=$(find build/ios/ipa -name "*.ipa" -type f 2>/dev/null | head -1)
        if [ -n "$ipa_path" ] && [ -f "$ipa_path" ]; then
            local output_name="${APP_NAME}-${VERSION_NAME}+${VERSION_CODE}.ipa"
            cp "$ipa_path" "output/$output_name"
            log_success "IPA 构建完成: output/$output_name"
            
            # 显示 IPA 信息
            local ipa_size=$(du -h "output/$output_name" | cut -f1)
            log_info "IPA 大小: $ipa_size"
        else
            log_error "IPA 构建失败，文件不存在"
            return 1
        fi
    fi
}

create_export_options() {
    cat > ios/ExportOptions.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>483V3ZF35S</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>manual</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>com.qualrb.scoreBoardPro</key>
        <string>scoreboard</string>
    </dict>
</dict>
</plist>
EOF
    log_info "已创建 ExportOptions.plist"
}

# ==================== 应用商店上传 ====================

check_upload_requirements() {
    log_info "检查上传配置..."
    
    local has_error=false
    
    # 检查 iOS 上传配置
    if [[ "$BUILD_TARGET" =~ ^(all|ios)$ ]]; then
        if [ -z "$IOS_API_KEY_ID" ] || [ -z "$IOS_API_ISSUER_ID" ]; then
            log_error "iOS API Key 未设置"
            log_info "请在 Jenkins 环境变量或 ${JENKINS_SECRETS_FILE} 中配置 IOS_API_KEY_ID / IOS_API_ISSUER_ID"
            has_error=true
        else
            log_success "iOS API Key 已配置: ${IOS_API_KEY_ID}"
        fi
        if [ ! -f "$IOS_API_KEY_PATH" ]; then
            log_error "iOS API Key 文件不存在: $IOS_API_KEY_PATH"
            has_error=true
        else
            log_success "iOS API Key 文件存在: $IOS_API_KEY_PATH"
        fi
    fi
    
    # 检查 Android 上传配置
    if [[ "$BUILD_TARGET" =~ ^(all|android|aab)$ ]]; then
        if [ ! -f "$ANDROID_SERVICE_ACCOUNT_JSON" ]; then
            log_error "Android 服务账号文件不存在: $ANDROID_SERVICE_ACCOUNT_JSON"
            has_error=true
        else
            log_success "Android 服务账号文件存在: $ANDROID_SERVICE_ACCOUNT_JSON"
        fi
    fi
    
    # 检查 Android APK 上传配置
    if [[ "$BUILD_TARGET" =~ ^(all|android|apk)$ ]]; then
        if [ -z "$TENCENT_SECRET_ID" ] || [ -z "$TENCENT_SECRET_KEY" ]; then
            log_error "腾讯云 COS 密钥未设置"
            log_info "请在 Jenkins 环境变量或 ${JENKINS_SECRETS_FILE} 中配置 TENCENT_SECRET_ID / TENCENT_SECRET_KEY"
            has_error=true
        else
            log_success "腾讯云 COS 密钥已配置"
        fi
    fi
    
    if [ "$has_error" = true ]; then
        log_error "上传配置检查失败"
        return 1
    fi
    
    log_success "上传配置检查完成"
}

upload_ios_to_app_store() {
    log_step "上传 iOS IPA 到 App Store Connect"
    
    # 查找 IPA 文件
    local ipa_file=$(find output -name "*.ipa" -type f 2>/dev/null | head -1)
    if [ -z "$ipa_file" ] || [ ! -f "$ipa_file" ]; then
        log_error "未找到 IPA 文件"
        return 1
    fi
    
    log_info "IPA 文件: $ipa_file"
    log_info "API Key ID: $IOS_API_KEY_ID"
    log_info "Issuer ID: $IOS_API_ISSUER_ID"
    
    # 使用 xcrun altool 上传 (支持 API Key 认证)
    log_info "开始上传到 App Store Connect..."
    
    xcrun altool --upload-app \
        --type ios \
        --file "$ipa_file" \
        --apiKey "$IOS_API_KEY_ID" \
        --apiIssuer "$IOS_API_ISSUER_ID" \
        --verbose
    
    if [ $? -eq 0 ]; then
        log_success "iOS IPA 上传成功!"
        return 0
    else
        log_error "iOS IPA 上传失败"
        return 1
    fi
}

check_and_install_cos_deps() {
    log_info "检查腾讯云 COS 上传依赖..."
    
    # 添加用户 bin 目录到 PATH
    export PATH="$HOME/.local/bin:$HOME/Library/Python/3.9/bin:$HOME/Library/Python/3.10/bin:$HOME/Library/Python/3.11/bin:$HOME/Library/Python/3.12/bin:$HOME/Library/Python/3.13/bin:$PATH"
    
    # 检查 coscmd 是否已安装
    if command -v coscmd &> /dev/null; then
        log_success "coscmd 已就绪"
        return 0
    fi
    
    log_warning "coscmd 未安装，正在自动安装..."
    
    pip3 install --user --break-system-packages coscmd || {
        log_error "coscmd 安装失败"
        return 1
    }
    
    log_success "coscmd 安装完成"
}

configure_coscmd() {
    log_info "配置腾讯云 COS..."
    
    # 配置 coscmd
    coscmd config \
        -a "$TENCENT_SECRET_ID" \
        -s "$TENCENT_SECRET_KEY" \
        -b "$COS_BUCKET" \
        -r "$COS_REGION"
    
    log_success "COS 配置完成"
}

upload_apk_to_tencent_cos() {
    log_step "上传 APK 到腾讯云 COS"
    
    local apk_file="output/${APP_NAME}.apk"
    if [[ ! -f "$apk_file" ]]; then
        apk_file=$(find output -name "*.apk" ! -name "*armeabi-v7a*" -type f 2>/dev/null | head -1)
    fi
    if [[ -z "$apk_file" ]] || [[ ! -f "$apk_file" ]]; then
        log_error "未找到 APK 文件"
        return 1
    fi

    if [[ "$BUILD_MODE" == "release" && -f "$PROJECT_ROOT/android/scripts/verify_release_apk.sh" ]]; then
        log_info "上传前校验 APK（含 Manifest / dex / 16KB）..."
        bash "$PROJECT_ROOT/android/scripts/verify_release_apk.sh" "$apk_file" || return 1
    fi
    
    local apk_name=$(basename "$apk_file")
    log_info "APK 文件: $apk_file"
    log_info "目标路径: cos://${COS_BUCKET}/${COS_BUCKET_PATH}/${apk_name}"
    
    # 检查并安装依赖
    check_and_install_cos_deps || return 1
    
    # 配置 coscmd
    configure_coscmd
    
    # 上传文件
    log_info "开始上传到腾讯云 COS..."
    
    coscmd upload "$apk_file" "/${COS_BUCKET_PATH}/${apk_name}"
    
    if [ $? -eq 0 ]; then
        local download_url="https://${COS_BUCKET}.cos.${COS_REGION}.myqcloud.com/${COS_BUCKET_PATH}/${apk_name}"
        log_success "APK 上传到腾讯云 COS 成功!"
        log_info "下载链接: $download_url"
        
        # 保存下载链接到文件
        echo "$download_url" > output/apk_download_url.txt
        
        return 0
    else
        log_error "APK 上传到腾讯云 COS 失败"
        return 1
    fi
}

check_and_install_google_play_deps() {
    log_info "检查 Google Play 上传依赖..."
    
    if python3 -c "import googleapiclient; import google.oauth2; import requests" 2>/dev/null; then
        log_success "Python 依赖已就绪"
        return 0
    fi
    
    log_warning "缺少 Python 依赖，正在自动安装..."
    
    pip3 install --user --break-system-packages google-api-python-client google-auth requests || {
        log_error "依赖安装失败"
        return 1
    }
    
    log_success "Python 依赖安装完成"
}

setup_google_play_proxy() {
    # Clash mixed 端口：与 curl --proxy http://127.0.0.1:7897 保持一致
    local host="${CLASH_PROXY_HOST:-127.0.0.1}"
    local port="${CLASH_PROXY_PORT:-7897}"
    export HTTP_PROXY="http://${host}:${port}"
    export HTTPS_PROXY="http://${host}:${port}"
    export http_proxy="$HTTP_PROXY"
    export https_proxy="$HTTPS_PROXY"
    # 避免 ALL_PROXY(socks5) 与 HTTP 代理混用导致 requests SSL 异常
    unset ALL_PROXY all_proxy
    log_info "Google Play 代理: $HTTPS_PROXY"
}

upload_aab_to_google_play() {
    log_step "上传 AAB 到 Google Play Store"
    
    # 查找 AAB 文件
    local aab_file=$(find output -name "*.aab" -type f 2>/dev/null | head -1)
    if [ -z "$aab_file" ] || [ ! -f "$aab_file" ]; then
        log_error "未找到 AAB 文件"
        return 1
    fi
    
    log_info "AAB 文件: $aab_file"
    log_info "Package Name: $ANDROID_PACKAGE_NAME"
    log_info "发布轨道: $GOOGLE_PLAY_TRACK"
    
    # 检查是否安装了必要的工具
    if ! command -v python3 &> /dev/null; then
        log_error "Python3 未安装"
        return 1
    fi
    
    # 检查并安装 Python 依赖
    check_and_install_google_play_deps
    
    # 统一代理环境（Jenkins 中 HTTPS_PROXY 可能未传递）
    setup_google_play_proxy
    
    # 创建上传脚本
    local upload_script="output/upload_to_google_play.py"
    create_google_play_upload_script "$upload_script"
    
    # 执行上传
    log_info "开始上传到 Google Play..."
    
    python3 "$upload_script" \
        --service-account "$ANDROID_SERVICE_ACCOUNT_JSON" \
        --package-name "$ANDROID_PACKAGE_NAME" \
        --aab-file "$aab_file" \
        --track "$GOOGLE_PLAY_TRACK"
    
    if [ $? -eq 0 ]; then
        log_success "AAB 上传到 Google Play 成功!"
        return 0
    else
        log_error "AAB 上传到 Google Play 失败"
        return 1
    fi
}

create_google_play_upload_script() {
    local script_path="$1"
    
    cat > "$script_path" << 'PYTHON_SCRIPT'
#!/usr/bin/env python3
"""
Google Play Store AAB 上传脚本
使用 Google Play Developer API v3 + requests（与 curl --proxy 行为一致）
"""

import argparse
import sys
import os
import time

try:
    from google.oauth2 import service_account
    from googleapiclient.discovery import build
    from googleapiclient.errors import HttpError
    from googleapiclient.http import MediaFileUpload
    from google.auth.transport.requests import AuthorizedSession
    import requests
except ImportError:
    print("错误: 需要安装 google-api-python-client google-auth requests")
    print("请运行: pip3 install google-api-python-client google-auth requests")
    sys.exit(1)


class HttpResponse(dict):
    def __init__(self, resp):
        super().__init__()
        self.status = resp.status_code
        self.reason = resp.reason
        for k, v in resp.headers.items():
            self[k.lower()] = v
            setattr(self, k.lower().replace('-', '_'), v)


class RequestsHttp:
    """requests HTTP 适配器，兼容 googleapiclient，带 SSL 重试"""

    def __init__(self, session, timeout=600, max_retries=5):
        self.session = session
        self.timeout = timeout
        self.max_retries = max_retries

    def request(self, uri, method='GET', body=None, headers=None, **kwargs):
        last_error = None
        for attempt in range(self.max_retries):
            try:
                response = self.session.request(
                    method=method,
                    url=uri,
                    data=body,
                    headers=dict(headers) if headers else None,
                    timeout=self.timeout,
                )
                return HttpResponse(response), response.content
            except (requests.exceptions.SSLError, requests.exceptions.ConnectionError) as e:
                last_error = e
                if attempt + 1 < self.max_retries:
                    wait = 2 ** attempt
                    print(f"网络错误 ({attempt + 1}/{self.max_retries}): {e}")
                    print(f"等待 {wait}s 后重试...")
                    time.sleep(wait)
        raise last_error


def get_proxy_config():
    """读取代理，优先 HTTP CONNECT（与 curl --proxy http:// 一致）"""
    proxy_url = (
        os.environ.get('https_proxy') or os.environ.get('HTTPS_PROXY') or
        os.environ.get('http_proxy') or os.environ.get('HTTP_PROXY')
    )
    if proxy_url:
        return {'http': proxy_url, 'https': proxy_url}
    return None


def test_api_connectivity(session):
    """上传前连通性测试"""
    url = 'https://androidpublisher.googleapis.com/$discovery/rest?version=v3'
    for attempt in range(3):
        try:
            resp = session.get(url, timeout=30)
            print(f"API 连通性测试: HTTP {resp.status_code}")
            return
        except (requests.exceptions.SSLError, requests.exceptions.ConnectionError) as e:
            if attempt + 1 >= 3:
                raise
            wait = 2 ** attempt
            print(f"连通性测试失败 ({attempt + 1}/3): {e}，{wait}s 后重试...")
            time.sleep(wait)


def execute_with_retry(request, description, max_retries=5):
    """Google Play API 偶发 502/503，上传 AAB 时自动重试"""
    last_error = None
    for attempt in range(max_retries):
        try:
            return request.execute()
        except HttpError as e:
            last_error = e
            status = getattr(e.resp, 'status', None)
            if status in (429, 500, 502, 503, 504) and attempt + 1 < max_retries:
                wait = min(60, 5 * (2 ** attempt))
                print(f"{description} 失败 HTTP {status} ({attempt + 1}/{max_retries})，{wait}s 后重试...")
                time.sleep(wait)
                continue
            raise
    raise last_error


def upload_aab(service_account_file, package_name, aab_file, track):
    print("正在认证服务账号...")

    credentials = service_account.Credentials.from_service_account_file(
        service_account_file,
        scopes=['https://www.googleapis.com/auth/androidpublisher']
    )

    session = AuthorizedSession(credentials)
    proxies = get_proxy_config()
    if proxies:
        session.proxies.update(proxies)
        print(f"使用代理: {proxies['https']}")
    else:
        print("警告: 未检测到代理设置")

    test_api_connectivity(session)

    http = RequestsHttp(session, timeout=600)
    service = build('androidpublisher', 'v3', http=http)

    max_upload_attempts = 3
    for upload_attempt in range(max_upload_attempts):
        try:
            print("创建编辑会话...")
            edit_response = execute_with_retry(
                service.edits().insert(body={}, packageName=package_name),
                "创建编辑会话",
            )
            edit_id = edit_response['id']

            print(f"编辑会话 ID: {edit_id}")
            print(f"上传 AAB 文件: {aab_file}")

            media = MediaFileUpload(aab_file, mimetype='application/octet-stream', resumable=False)
            bundle_response = execute_with_retry(
                service.edits().bundles().upload(
                    packageName=package_name,
                    editId=edit_id,
                    media_body=media
                ),
                "上传 AAB",
                max_retries=5,
            )

            version_code = bundle_response['versionCode']
            print(f"上传成功! Version Code: {version_code}")

            print(f"设置发布轨道: {track}")
            track_response = execute_with_retry(
                service.edits().tracks().update(
                    packageName=package_name,
                    editId=edit_id,
                    track=track,
                    body={
                        'track': track,
                        'releases': [{
                            'versionCodes': [version_code],
                            'status': 'completed' if track == 'production' else 'draft'
                        }]
                    }
                ),
                "设置发布轨道",
            )

            print(f"轨道设置成功: {track_response['track']}")
            print("提交更改...")

            commit_response = execute_with_retry(
                service.edits().commit(
                    packageName=package_name,
                    editId=edit_id
                ),
                "提交编辑会话",
            )

            print(f"提交成功! Edit ID: {commit_response['id']}")
            print("AAB 已成功上传到 Google Play!")
            return True
        except HttpError as e:
            status = getattr(e.resp, 'status', None)
            if status in (429, 500, 502, 503, 504) and upload_attempt + 1 < max_upload_attempts:
                wait = min(90, 10 * (2 ** upload_attempt))
                print(f"上传流程失败 HTTP {status} ({upload_attempt + 1}/{max_upload_attempts})，{wait}s 后重新开始...")
                time.sleep(wait)
                continue
            raise

    return False


def main():
    parser = argparse.ArgumentParser(description='上传 AAB 到 Google Play Store')
    parser.add_argument('--service-account', required=True, help='服务账号 JSON 文件路径')
    parser.add_argument('--package-name', required=True, help='应用包名')
    parser.add_argument('--aab-file', required=True, help='AAB 文件路径')
    parser.add_argument('--track', default='internal',
                       choices=['internal', 'alpha', 'beta', 'production'],
                       help='发布轨道')

    args = parser.parse_args()

    try:
        upload_aab(
            args.service_account,
            args.package_name,
            args.aab_file,
            args.track
        )
        sys.exit(0)
    except Exception as e:
        print(f"上传失败: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


if __name__ == '__main__':
    main()
PYTHON_SCRIPT

    chmod +x "$script_path"
    log_info "已创建 Google Play 上传脚本: $script_path"
}

setup_ios_api_key() {
    # 创建 API Key 目录 (xcrun altool 需要)
    local api_key_dir="$HOME/.appstoreconnect/private_keys"
    mkdir -p "$api_key_dir"
    
    # 复制 p8 文件到指定位置
    local target_key="$api_key_dir/AuthKey_${IOS_API_KEY_ID}.p8"
    if [ ! -f "$target_key" ]; then
        cp "$IOS_API_KEY_PATH" "$target_key"
        log_info "已复制 API Key 到: $target_key"
    fi
}

do_upload() {
    log_step "执行应用商店上传"

    local upload_success=true

    # iOS 上传到 App Store
    if [[ "$BUILD_TARGET" =~ ^(all|ios)$ ]]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            setup_ios_api_key
            upload_ios_to_app_store || upload_success=false
        else
            log_warning "非 macOS 系统，跳过 iOS 上传"
        fi
    fi

    # Android AAB 上传到 Google Play
    if [[ "$BUILD_TARGET" =~ ^(all|android|aab)$ ]]; then
        upload_aab_to_google_play || upload_success=false
    fi
    
    # Android APK 上传到腾讯云 COS
    if [[ "$BUILD_TARGET" =~ ^(all|android|apk)$ ]]; then
        upload_apk_to_tencent_cos || upload_success=false
    fi

    if [ "$upload_success" = true ]; then
        log_success "所有上传任务完成!"
        return 0
    else
        log_error "部分上传任务失败"
        return 1
    fi
}

# ==================== 构建报告 ====================

generate_report() {
    log_step "生成构建报告"

    local report_file="output/build-report.txt"
    local report_json="output/build-report.json"

    # 文本报告
    cat > "$report_file" << EOF
==============================================
Score Board - 构建报告
==============================================

构建信息:
  应用名称: $APP_NAME
  版本号: $VERSION_NAME
  构建号: $VERSION_CODE
  构建目标: $BUILD_TARGET
  构建模式: $BUILD_MODE
  构建时间: $(date '+%Y-%m-%d %H:%M:%S')

环境信息:
  Flutter: $(flutter --version | head -1)
  主机: $(hostname)
  系统: $(uname -s) $(uname -r)

Git 信息:
  分支: $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'N/A')
  提交: $(git rev-parse --short HEAD 2>/dev/null || echo 'N/A')
  作者: $(git log -1 --format='%an' 2>/dev/null || echo 'N/A')

输出文件:
$(ls -lh output/*.apk output/*.aab output/*.ipa 2>/dev/null || echo '  无')

==============================================
EOF

    # JSON 报告 (便于后续处理)
    cat > "$report_json" << EOF
{
  "appName": "$APP_NAME",
  "versionName": "$VERSION_NAME",
  "versionCode": "$VERSION_CODE",
  "buildTarget": "$BUILD_TARGET",
  "buildMode": "$BUILD_MODE",
  "buildTime": "$(date -u '+%Y-%m-%dT%H:%M:%SZ')",
  "buildNumber": "${BUILD_NUMBER:-N/A}",
  "gitBranch": "$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '')",
  "gitCommit": "$(git rev-parse HEAD 2>/dev/null || echo '')",
  "artifacts": [
$(ls output/*.apk output/*.aab output/*.ipa 2>/dev/null | while read f; do
    size=$(du -h "$f" | cut -f1)
    name=$(basename "$f")
    echo "    {\"name\": \"$name\", \"size\": \"$size\"},"
done | sed '$ s/,$//')
  ]
}
EOF

    log_info "构建报告:"
    cat "$report_file"
}

# ==================== 主函数 ====================

main() {
    echo ""
    echo -e "${CYAN}============================================${NC}"
    echo -e "${CYAN}  Score Board - Jenkins CI/CD 构建脚本  ${NC}"
    echo -e "${CYAN}============================================${NC}"
    echo ""

    # 记录开始时间
    BUILD_START_TIME=$(date +%s)

    # 验证参数
    validate_params

    # 签名/上传依赖节点密钥，必须在 --prepare-android-signing 之前加载
    load_jenkins_secrets
    resolve_ios_api_credentials

    if [ "$PREPARE_ANDROID_SIGNING_ONLY" = true ]; then
        require_android_release_signing
        exit $?
    fi

    # 检查环境
    check_environment
    
    # 如果启用上传，检查上传配置
    if [ "$UPLOAD_ENABLED" = true ]; then
        check_upload_requirements || exit 1
    fi

    local build_success=true
    local upload_success=true
    
    # 仅上传模式
    if [ "$UPLOAD_ONLY" = true ]; then
        log_info "仅上传模式，跳过构建"
        
        # 获取版本信息 (从已有产物)
        APP_VERSION=$(get_version)
        parse_version "$APP_VERSION"
        
        mkdir -p output 2>/dev/null || true
        
        do_upload || upload_success=false
    else
        # 准备构建
        prepare_build

        # 执行构建
        case $BUILD_TARGET in
            all)
                build_apk || build_success=false
                build_aab || build_success=false
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    build_ios || build_success=false
                else
                    log_warning "非 macOS 系统，跳过 iOS 构建"
                fi
                ;;
            android)
                build_apk || build_success=false
                build_aab || build_success=false
                ;;
            apk)
                build_apk || build_success=false
                ;;
            aab)
                build_aab || build_success=false
                ;;
            ios)
                build_ios || build_success=false
                ;;
        esac

        # 生成报告
        generate_report
        
        # 如果构建成功且启用上传，执行上传
        if [ "$build_success" = true ] && [ "$UPLOAD_ENABLED" = true ]; then
            do_upload || upload_success=false
        fi
    fi

    # 计算构建时间
    BUILD_END_TIME=$(date +%s)
    BUILD_DURATION=$((BUILD_END_TIME - BUILD_START_TIME))
    BUILD_MINUTES=$((BUILD_DURATION / 60))
    BUILD_SECONDS=$((BUILD_DURATION % 60))

    echo ""
    if [ "$build_success" = true ] && [ "$upload_success" = true ]; then
        log_success "全部完成! 耗时: ${BUILD_MINUTES}分${BUILD_SECONDS}秒"
        echo ""
        log_info "输出目录: $(pwd)/output/"
        ls -lh output/ 2>/dev/null || true
        exit 0
    elif [ "$build_success" = true ] && [ "$upload_success" = false ]; then
        log_warning "构建成功，但上传失败! 耗时: ${BUILD_MINUTES}分${BUILD_SECONDS}秒"
        exit 1
    else
        log_error "构建失败! 耗时: ${BUILD_MINUTES}分${BUILD_SECONDS}秒"
        exit 1
    fi
}

# 运行主函数
main
