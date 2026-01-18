#!/bin/bash
# 激活虚拟环境

cd "$(dirname "$0")"

if [ ! -d "venv" ]; then
    echo "❌ 虚拟环境不存在，正在创建..."
    python3 -m venv venv
    echo "✅ 虚拟环境创建完成！"
fi

echo "🔄 激活虚拟环境..."
source venv/bin/activate

echo "✅ 虚拟环境已激活！"
echo ""
echo "Python 路径: $(which python)"
echo "Python 版本: $(python --version)"
echo ""
echo "💡 提示："
echo "  - 安装依赖: pip install -r requirements.txt"
echo "  - 启动服务: uvicorn app.main:app --reload --host 0.0.0.0 --port 8000"
echo "  - 退出环境: deactivate"
