# Android 发版指南

按 ABI 拆分安装包（不做 universal 大包）、固定签名密钥、应用内检测更新、覆盖安装升级不丢数据。

## 一、生成固定签名密钥（只做一次）

**密钥一旦用于发布就不能更换** —— Android 只允许覆盖安装「同一签名」的应用，换密钥意味着用户必须卸载重装（数据全丢）。请把密钥文件和口令长期备份到安全位置（密码管理器）。

```bash
keytool -genkey -v \
  -keystore release.keystore \
  -alias aivault \
  -keyalg RSA -keysize 2048 -validity 36500
```

按提示设置 keystore 口令与 key 口令（可以相同），填写组织信息（可随意填）。

## 二、配置 GitHub Secrets

仓库 → Settings → Secrets and variables → Actions → New repository secret：

| Secret 名 | 内容 |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | `base64 -i release.keystore -o keystore.b64` 的文件内容 |
| `ANDROID_KEYSTORE_PASSWORD` | keystore 口令 |
| `ANDROID_KEY_ALIAS` | 别名（如 `aivault`） |
| `ANDROID_KEY_PASSWORD` | key 口令 |

## 三、本地开发签名（可选）

不配置 Secrets 时本地构建会退回 debug 签名。若想本地也用正式签名验证：

```bash
# android/keystore.properties（已加入 .gitignore，不会提交）
storeFile=app/release.keystore
storePassword=你的口令
keyAlias=aivault
keyPassword=你的口令
```

## 四、发版

```bash
# tag 格式固定为 v{版本}+{build}，build 必须大于上一版（versionCode 单调递增）
git tag v0.4.0+5
git push origin v0.4.0+5
```

推送 tag 后 GitHub Actions 自动执行：

1. `flutter analyze` + `flutter test`（失败则中止发版）
2. `flutter build apk --release --split-per-abi`，产物：
   - `aivault-arm64-v8a.apk` —— 主流 64 位手机（近年设备）
   - `aivault-armeabi-v7a.apk` —— 老 32 位设备
   - `aivault-x86_64.apk` —— 模拟器 / x86 设备
3. `apksigner` 校验签名证书（确保固定令牌生效）
4. 创建 GitHub Release，附 3 个 APK + `update-info.json`

## 五、应用内更新

App「设置 → 检查更新」（仅 Android 显示）：

1. 请求 `releases/latest/download/update-info.json` 读取最新版本号与 APK 地址
2. 读取 `/system/build.prop` 判断设备 ABI，自动选择对应安装包
3. 下载（带进度）后交给系统安装器；Android 8+ 首次需允许「安装未知应用」

**首次发布前**：把 `lib/ui/settings/update_page.dart` 中的 `_repo` 常量改成你的实际仓库（`owner/repo`）。

## 升级不丢数据的保证

- **同一 keystore 签名**：Android 允许覆盖安装，应用数据目录不动
- **versionCode 递增**：tag 中的 build number 直接作为 versionCode，覆盖安装要求新版本更高
- **本地数据均在应用私有存储**：SQLite（订阅 / 聊天 / 记录）、图片文件、Keychain/Keystore 凭证 —— 覆盖安装全部保留

## 故障排查

| 现象 | 原因 |
|---|---|
| 安装时提示「签名不一致」 | 用了不同 keystore（或从 debug 版升级到 release 版）——debug 签名的包需先卸载 |
| 覆盖安装被拒绝 | tag 里 build number 没有大于上一版 |
| App 内检查更新失败 | 仓库无 Release / `_repo` 常量未改 / 网络不通 |
