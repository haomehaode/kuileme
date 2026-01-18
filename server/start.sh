#!/bin/bash
# 启动 FastAPI 服务脚本

cd "$(dirname "$0")"

# 检查虚拟环境是否存在
if [ ! -d "venv" ]; then
    echo "❌ 虚拟环境不存在，正在创建..."
    python3 -m venv venv
    echo "✅ 虚拟环境创建完成！"
fi

# 激活虚拟环境
echo "🔄 激活虚拟环境..."
source venv/bin/activate

# 检查依赖是否已安装
if ! python -c "import fastapi" 2>/dev/null; then
    echo "📦 检测到依赖未安装，正在安装..."
    pip install --upgrade pip
    pip install -r requirements.txt
    if [ $? -ne 0 ]; then
        echo "⚠️  使用默认源安装失败，尝试使用国内镜像源..."
        pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple
    fi
    echo "✅ 依赖安装完成！"
fi

# 设置数据库类型为 SQLite（默认）
export DATABASE_TYPE=${DATABASE_TYPE:-sqlite}

echo ""
echo "=========================================="
echo "🚀 启动 FastAPI 服务..."
echo "数据库类型: $DATABASE_TYPE"
echo "=========================================="
echo ""
echo "📝 API 文档地址："
echo "  - Swagger UI: http://localhost:8000/docs"
echo "  - ReDoc: http://localhost:8000/redoc"
echo ""
echo "按 Ctrl+C 停止服务"
echo ""

# 启动服务
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
