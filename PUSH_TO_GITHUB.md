# 推送到 GitHub 指南

## 步骤 1: 在 GitHub 上创建仓库

1. 访问 https://github.com/new
2. 输入仓库名称（例如：`kuileme`）
3. 选择 Public 或 Private
4. **不要**初始化 README、.gitignore 或 license（我们已经有了）
5. 点击 "Create repository"

## 步骤 2: 配置远程仓库

复制 GitHub 提供的仓库地址，然后运行：

```bash
git remote add origin https://github.com/你的用户名/kuileme.git
```

或者使用 SSH：

```bash
git remote add origin git@github.com:你的用户名/kuileme.git
```

## 步骤 3: 推送代码

```bash
git push -u origin main
```

## 如果遇到问题

### 如果远程仓库已存在内容

```bash
git pull origin main --allow-unrelated-histories
git push -u origin main
```

### 如果需要强制推送（谨慎使用）

```bash
git push -u origin main --force
```

## 推送后的操作

1. **创建 Release**：
   - 在 GitHub 仓库页面点击 "Releases"
   - 点击 "Create a new release"
   - 输入标签：`v0.1.0`
   - 上传 IPA 和 APK 文件

2. **查看构建产物**：
   - iOS IPA: `app/build/ios/ipa/kuleme-unsigned.ipa`
   - Android APK: 需要先构建（运行 `cd app && flutter build apk --release`）
