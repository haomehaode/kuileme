#!/bin/bash

# Android 构建脚本
# 使用方法: ./build_android.sh [apk|bundle|split]

set -e

cd "$(dirname "$0")"

BUILD_TYPE=${1:-apk}

echo "🚀 开始构建 Android 应用..."
echo "构建类型: $BUILD_TYPE"

# 清理之前的构建
echo "🧹 清理构建缓存..."
flutter clean

# 获取依赖
echo "📦 获取依赖..."
flutter pub get

case $BUILD_TYPE in
  apk)
    echo "📱 构建 APK 文件..."
    flutter build apk --release
    echo "✅ APK 构建完成！"
    echo "📁 文件位置: build/app/outputs/flutter-apk/app-release.apk"
    ;;
  bundle)
    echo "📱 构建 App Bundle 文件..."
    flutter build appbundle --release
    echo "✅ App Bundle 构建完成！"
    echo "📁 文件位置: build/app/outputs/bundle/release/app-release.aab"
    ;;
  split)
    echo "📱 构建分架构 APK 文件..."
    echo "构建 ARM64 版本..."
    flutter build apk --release --target-platform android-arm64
    echo "构建 ARM32 版本..."
    flutter build apk --release --target-platform android-arm
    echo "✅ 分架构 APK 构建完成！"
    echo "📁 文件位置:"
    echo "  - ARM64: build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
    echo "  - ARM32: build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk"
    ;;
  *)
    echo "❌ 未知的构建类型: $BUILD_TYPE"
    echo "可用类型: apk, bundle, split"
    exit 1
    ;;
esac

echo "🎉 构建完成！"
