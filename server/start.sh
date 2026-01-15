#!/bin/bash

# Kuleme Backend Docker 启动脚本

echo "========================================"
echo "  Kuleme Backend Docker 部署脚本"
echo "========================================"
echo ""

# 检查 Docker 是否运行
echo "检查 Docker 状态..."
if ! docker ps > /dev/null 2>&1; then
    echo "✗ Docker 未运行，请先启动 Docker Desktop"
    exit 1
fi
echo "✓ Docker 正在运行"

# 检查 .env 文件（可选，docker-compose.yml 有默认值）
echo ""
echo "检查环境变量配置..."
if [ ! -f .env ]; then
    echo "⚠ .env 文件不存在，将使用 docker-compose.yml 中的默认值"
    echo "  提示：生产环境建议创建 .env 文件并修改敏感信息"
else
    echo "✓ .env 文件已存在"
fi

# 停止现有容器（如果有）
echo ""
echo "停止现有容器..."
docker compose down 2>/dev/null || docker-compose down 2>/dev/null
echo "✓ 已清理"

# 构建并启动
echo ""
echo "构建 Docker 镜像..."
if command -v docker-compose &> /dev/null; then
    docker-compose build
else
    docker compose build
fi

echo ""
echo "启动服务..."
if command -v docker-compose &> /dev/null; then
    docker-compose up -d
else
    docker compose up -d
fi

echo ""
echo "等待服务启动..."
sleep 5

# 检查服务状态
echo ""
echo "检查服务状态..."
if command -v docker-compose &> /dev/null; then
    docker-compose ps
else
    docker compose ps
fi

echo ""
echo "========================================"
echo "  部署完成！"
echo "========================================"
echo ""
echo "API 文档: http://localhost:8000/docs"
echo "查看日志: docker compose logs -f (或 docker-compose logs -f)"
echo "停止服务: docker compose down (或 docker-compose down)"
echo ""
echo "数据库连接信息："
echo "  主机: localhost"
echo "  端口: 5432"
echo "  数据库: kuleme"
echo "  用户名: kuleme"
echo "  密码: kuleme_password"
echo ""
