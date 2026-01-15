# Android 打包说明

## 本地构建 Android 包

### 方法 1: 构建 APK（用于直接安装）

```bash
cd app
flutter build apk --release
```

构建完成后，APK 文件位于：`app/build/app/outputs/flutter-apk/app-release.apk`

### 方法 2: 构建 App Bundle（用于 Google Play 发布）

```bash
cd app
flutter build appbundle --release
```

构建完成后，AAB 文件位于：`app/build/app/outputs/bundle/release/app-release.aab`

### 方法 3: 构建分架构 APK（减小文件大小）

```bash
# 构建 ARM64 版本（现代设备）
flutter build apk --release --target-platform android-arm64

# 构建 ARM32 版本（旧设备）
flutter build apk --release --target-platform android-arm

# 构建 x86_64 版本（模拟器）
flutter build apk --release --target-platform android-x64
```

### 方法 4: 使用构建脚本

```bash
cd app
./build_android.sh [apk|bundle|split]
```

## 代码签名设置

### 生成签名密钥

```bash
keytool -genkey -v -keystore ~/kuleme-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias kuleme
```

### 配置签名

1. 创建 `app/android/key.properties` 文件：

```properties
storePassword=你的密钥库密码
keyPassword=你的密钥密码
keyAlias=kuleme
storeFile=/path/to/kuleme-release-key.jks
```

2. 更新 `app/android/app/build.gradle.kts` 以使用签名配置

## 使用 GitHub Actions 自动构建

1. 在 GitHub 上创建仓库
2. 推送代码到 GitHub
3. 创建标签触发构建：
   ```bash
   git tag v0.1.0
   git push origin v0.1.0
   ```
4. GitHub Actions 会自动构建并创建 Release

## 上传到 GitHub Releases

构建完成后，可以：

1. 在 GitHub 上创建 Release
2. 上传 APK/AAB 文件作为附件
3. 或者使用 GitHub Actions 自动上传（已配置）

## 安装说明

### APK 安装

1. 在 Android 设备上启用"未知来源"安装
2. 下载 APK 文件
3. 点击安装

### 注意事项

- APK 文件通常较大（30-100MB），建议使用 GitHub Releases
- 需要 Android 5.0 (API 21) 或更高版本
- 首次安装可能需要允许"未知来源"应用
