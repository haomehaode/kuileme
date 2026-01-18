# 亏了么 (Kuleme)

一个记录投资亏损、分享心路历程的社交应用。

## 项目结构

```
kuileme/
├── app/              # Flutter 移动应用
├── server/           # Python FastAPI 后端服务
└── docs/             # 文档
```

## 功能特性

- ✅ 用户登录/注册
- ✅ 亏友圈发帖
- ✅ 首页数据展示
- ✅ 账单查看
- ✅ 个人中心
- ✅ 存钱抽奖回血
- ✅ 紧急救助站

## 快速开始

### 移动应用 (Flutter)

```bash
cd app
flutter pub get
flutter run
```

### 后端服务 (Python)

```bash
cd server
pip install -r requirements.txt
uvicorn app.main:app --reload
```

## 构建说明

### iOS 构建

```bash
cd app
flutter build ipa --release
```

构建完成后，IPA 文件位于：`app/build/ios/ipa/kuleme.ipa`

详细说明请参考 [BUILD_IOS.md](./BUILD_IOS.md)

### Android 构建

```bash
cd app
flutter build apk --release
```

构建完成后，APK 文件位于：`app/build/app/outputs/flutter-apk/app-release.apk`

详细说明请参考 [BUILD_ANDROID.md](./BUILD_ANDROID.md)

## 下载应用

### 当前版本: v0.1.0

#### iOS
- **未签名 IPA**: [kuleme-unsigned.ipa](./app/build/ios/ipa/kuleme-unsigned.ipa)
  - ⚠️ 注意：此版本未签名，无法直接在设备上安装
  - 需要手动签名或使用开发者账号重新构建

#### Android
- **APK**: 需要先构建（运行 `cd app && flutter build apk --release`）
  - 构建完成后位于：`app/build/app/outputs/flutter-apk/app-release.apk`

### 安装说明

#### iOS
1. **使用开发者账号签名**：
   - 在 Xcode 中打开项目
   - 配置代码签名
   - 重新构建 IPA

2. **使用模拟器版本**：
   - 下载模拟器版本：`app/build/ios/iphonesimulator/Runner.app`
   - 在 Xcode 模拟器中运行

#### Android
1. 在 Android 设备上启用"未知来源"安装
2. 下载 APK 文件
3. 点击安装

## 技术栈

- **前端**: Flutter 3.7.0
- **后端**: Python FastAPI
- **数据库**: PostgreSQL (通过 Docker)

## 开发

### 环境要求

- Flutter 3.7.0+
- Python 3.11+
- Xcode (iOS 开发)
- Android Studio (Android 开发)

### 运行后端

```bash
cd server
docker-compose up -d
```

## License

MIT
