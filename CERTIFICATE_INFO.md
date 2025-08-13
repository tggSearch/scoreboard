# 签名证书信息

## 证书文件位置

- Keystore 文件: `android/app/upload-keystore.jks`
- 配置文件: `android/key.properties`

## 证书信息

- **包名**: `com.qualrb.scoreboard`
- **证书别名**: `upload`
- **证书密码**: `scoreboard123`
- **有效期**: 10,000 天

## 构建文件

- **APK 文件**: `build/app/outputs/flutter-apk/app-release.apk`
- **AAB 文件**: `build/app/outputs/bundle/release/app-release.aab`

## 构建命令

```bash
# 构建APK
flutter build apk --release

# 构建AAB (用于Google Play)
flutter build appbundle --release
```

## 重要提醒

1. 请妥善保管 keystore 文件和密码，这是上传到 Google Play 的唯一凭证
2. 如果丢失 keystore 文件，将无法更新应用
3. 建议将 keystore 文件备份到安全位置

## Google Play 上传

使用生成的 AAB 文件 (`app-release.aab`) 上传到 Google Play Console。
