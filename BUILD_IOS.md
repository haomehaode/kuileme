# iOS 打包说明

## 本地构建 iOS 包

### 方法 1: 构建 IPA（需要 Apple Developer 账号）

```bash
cd app
flutter build ipa --release
```

构建完成后，IPA 文件位于：`app/build/ios/ipa/kuleme.ipa`

### 方法 2: 构建 Xcode 项目（可以手动签名）

```bash
cd app
flutter build ios --release
```

然后在 Xcode 中打开项目：
```bash
open app/ios/Runner.xcworkspace
```

在 Xcode 中：
1. 选择 Product > Archive
2. 等待构建完成
3. 在 Organizer 中导出 IPA

### 方法 3: 使用 GitHub Actions 自动构建

1. 在 GitHub 上创建仓库
2. 推送代码到 GitHub
3. 创建标签触发构建：
   ```bash
   git tag v0.1.0
   git push origin v0.1.0
   ```
4. GitHub Actions 会自动构建并创建 Release

## 代码签名设置

如果没有 Apple Developer 账号，可以：

1. **使用免费的个人开发者账号**：
   - 在 Xcode 中登录你的 Apple ID
   - Xcode 会自动创建开发证书和配置文件

2. **使用自动签名**：
   - 打开 `app/ios/Runner.xcworkspace`
   - 选择 Runner target
   - 在 Signing & Capabilities 中启用 "Automatically manage signing"
   - 选择你的 Team

## 上传到 GitHub Releases

构建完成后，可以：

1. 在 GitHub 上创建 Release
2. 上传 IPA 文件作为附件
3. 或者使用 GitHub Actions 自动上传（已配置）

## 注意事项

- IPA 文件通常较大（50-200MB），建议使用 GitHub Releases 而不是直接提交到仓库
- 需要 Apple Developer 账号才能在真实设备上安装
- 模拟器版本只能在模拟器上运行
