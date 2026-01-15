#!/bin/bash

# 推送到 GitHub 脚本
# 使用方法: ./push_to_github.sh [GitHub仓库地址]

set -e

REPO_URL=$1

if [ -z "$REPO_URL" ]; then
  echo "❌ 请提供 GitHub 仓库地址"
  echo ""
  echo "使用方法:"
  echo "  ./push_to_github.sh https://github.com/你的用户名/kuileme.git"
  echo ""
  echo "或者使用 SSH:"
  echo "  ./push_to_github.sh git@github.com:你的用户名/kuileme.git"
  exit 1
fi

echo "🚀 开始配置并推送到 GitHub..."
echo "仓库地址: $REPO_URL"
echo ""

# 检查是否已有远程仓库
if git remote get-url origin >/dev/null 2>&1; then
  echo "⚠️  已存在远程仓库，更新地址..."
  git remote set-url origin "$REPO_URL"
else
  echo "➕ 添加远程仓库..."
  git remote add origin "$REPO_URL"
fi

echo "📤 推送到 GitHub..."
git push -u origin main

echo ""
echo "✅ 推送完成！"
echo ""
echo "下一步："
echo "1. 访问你的 GitHub 仓库查看代码"
echo "2. 创建 Release 并上传构建文件："
echo "   - iOS IPA: app/build/ios/ipa/kuleme-unsigned.ipa"
echo "   - Android APK: 需要先构建 (cd app && flutter build apk --release)"
