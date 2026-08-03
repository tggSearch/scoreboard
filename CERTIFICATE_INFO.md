# 签名证书信息

## 证书文件位置

- **专用 Keystore（仓库内）**: `certs/scoreboard-upload-keystore.jks`
- **公钥证书（Play 重置上传密钥用）**: `android_public_key.pem` / `certs/scoreboard-upload-certificate.pem`
- **配置**: `certs/scoreboard-key.properties`（Jenkins 构建时复制为 `android/key.properties`）
- Jenkins 构建时会复制到 `android/app/upload-keystore.jks`

可选覆盖路径: `${CERT_DIR}/scoreboard-upload-keystore.jks`（默认 `CERT_DIR=/Users/dan/Documents/cert`）

## 证书信息

- **包名**: `com.qualrb.scoreboard`
- **证书别名**: `upload`
- **密码**: `scoreboard123`
- **新 Upload SHA1**: `8E:9F:91:5E:D2:CE:FE:2D:64:0D:C5:B3:E3:CC:FD:60:50:D0:36:BD`
- **旧 Upload SHA1（已丢失私钥）**: `3B:CA:B7:74:01:9E:5F:E8:51:7E:DE:0C:7E:46:08:C1:02:98:33:97`

> **重要**: ScoreBoard 与 texasWinRate 使用不同的 Google Play upload key，**不可**共用 `upload/android` keystore。

### Google Play 重置上传密钥

在 Play Console → 应用签名 → **请求重置上传密钥**，上传：

- `android_public_key.pem`（或 `certs/scoreboard-upload-certificate.pem`）

**不要**上传 `.jks`。批准前用新 key 打包会被拒；批准后用仓库内 keystore 打 AAB 即可。

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
./jenkins_ios_signing_setup.sh
./jenkins_build.sh -t ios -m release
./jenkins_build.sh -t all -m release
```

## 构建命令

```bash
./jenkins_build.sh --prepare-android-signing
flutter build apk --release
flutter build appbundle --release
```

## 重要提醒

1. 妥善保管 `certs/scoreboard-upload-keystore.jks` 和密码
2. 私钥丢失只能走 Play Console 重置上传密钥
3. 建议额外备份 keystore 到安全位置

## Google Play 上传

使用生成的 AAB（上传密钥重置批准后）。
