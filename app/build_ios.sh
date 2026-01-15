#!/bin/bash

# iOS 构建脚本
# 使用方法: ./build_ios.sh [ipa|simulator|xcode]

set -e

cd "$(dirname "$0")"

BUILD_TYPE=${1:-ipa}

echo "🚀 开始构建 iOS 应用..."
echo "构建类型: $BUILD_TYPE"

# 清理之前的构建
echo "🧹 清理构建缓存..."
flutter clean

# 获取依赖
echo "📦 获取依赖..."
flutter pub get

case $BUILD_TYPE in
  ipa)
    echo "📱 构建 IPA 文件..."
    flutter build ipa --release
    echo "✅ IPA 构建完成！"
    echo "📁 文件位置: build/ios/ipa/kuleme.ipa"
    ;;
  simulator)
    echo "📱 构建模拟器版本..."
    flutter build ios --simulator
    echo "✅ 模拟器版本构建完成！"
    echo "📁 文件位置: build/ios/iphonesimulator/Runner.app"
    ;;
  xcode)
    echo "📱 构建 Xcode 项目..."
    flutter build ios --release --no-codesign
    echo "✅ Xcode 项目构建完成！"
    echo "📁 打开项目: open ios/Runner.xcworkspace"
    ;;
  *)
    echo "❌ 未知的构建类型: $BUILD_TYPE"
    echo "可用类型: ipa, simulator, xcode"
    exit 1
    ;;
esac

echo "🎉 构建完成！"
