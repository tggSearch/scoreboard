# 签名证书信息

## 证书文件位置

- **专用 Keystore（必需）**: `${CERT_DIR}/scoreboard-upload-keystore.jks`
- **可选配置**: `${CERT_DIR}/scoreboard-key.properties`
- **Jenkins 构建时**: 复制到 `android/app/upload-keystore.jks`，并生成 `android/key.properties`

## 证书信息

- **包名**: `com.qualrb.scoreboard`
- **证书别名**: `upload`
- **默认证书密码**: `scoreboard123`
- **Google Play upload key SHA1**: `3B:CA:B7:74:01:9E:5F:E8:51:7E:DE:0C:7E:46:08:C1:02:98:33:97`

> **重要**: ScoreBoard 与 texasWinRate 使用不同的 Google Play upload key，**不可**共用 `upload/android` keystore。

## 构建文件

- **APK 文件**: `build/app/outputs/flutter-apk/app-release.apk`
- **AAB 文件**: `build/app/outputs/bundle/release/app-release.aab`

## iOS 签名（Jenkins / 本地打包）

- **Bundle ID**: `com.qualrb.scoreBoardPro`
- **Team ID**: `483V3ZF35S`
- **描述文件**: `scoreboard`（App Store Connect 类型）
- **描述文件路径**: `~/Downloads/scoreboard.mobileprovision` 或 `${CERT_DIR}/scoreboard.mobileprovision`
- **ExportOptions**: `ios/ExportOptions.plist`

```bash
# 安装描述文件并同步 Xcode / ExportOptions
./jenkins_ios_signing_setup.sh

# 构建 IPA
./jenkins_build.sh -t ios -m release

# 构建全部平台
./jenkins_build.sh -t all -m release
```

## 构建命令

```bash
# 准备 Android 签名
./jenkins_build.sh --prepare-android-signing

# 构建APK
flutter build apk --release

# 构建AAB (用于Google Play)
flutter build appbundle --release
```

## 重要提醒

1. 请妥善保管 `scoreboard-upload-keystore.jks` 和密码，这是上传到 Google Play 的唯一凭证
2. 如果丢失 keystore 文件，将无法更新应用
3. 建议将 keystore 文件备份到安全位置

## Google Play 上传

使用生成的 AAB 文件 (`app-release.aab`) 上传到 Google Play Console。
