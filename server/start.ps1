# Kuleme Backend Docker 启动脚本

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Kuleme Backend Docker 部署脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查 Docker 是否运行
Write-Host "检查 Docker 状态..." -ForegroundColor Yellow
try {
    docker ps | Out-Null
    Write-Host "✓ Docker 正在运行" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker 未运行，请先启动 Docker Desktop" -ForegroundColor Red
    exit 1
}

# 检查 .env 文件
Write-Host ""
Write-Host "检查环境变量配置..." -ForegroundColor Yellow
if (-not (Test-Path .env)) {
    Write-Host "⚠ .env 文件不存在，从 .env.example 创建..." -ForegroundColor Yellow
    if (Test-Path .env.example) {
        Copy-Item .env.example .env
        Write-Host "✓ 已创建 .env 文件，请编辑后重新运行此脚本" -ForegroundColor Green
        Write-Host "  提示：生产环境请修改 POSTGRES_PASSWORD 和 JWT_SECRET_KEY" -ForegroundColor Yellow
        exit 0
    } else {
        Write-Host "✗ .env.example 文件不存在" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✓ .env 文件已存在" -ForegroundColor Green
}

# 停止现有容器（如果有）
Write-Host ""
Write-Host "停止现有容器..." -ForegroundColor Yellow
docker-compose down 2>$null
Write-Host "✓ 已清理" -ForegroundColor Green

# 构建并启动
Write-Host ""
Write-Host "构建 Docker 镜像..." -ForegroundColor Yellow
docker-compose build

Write-Host ""
Write-Host "启动服务..." -ForegroundColor Yellow
docker-compose up -d

Write-Host ""
Write-Host "等待服务启动..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# 检查服务状态
Write-Host ""
Write-Host "检查服务状态..." -ForegroundColor Yellow
docker-compose ps

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  部署完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "API 文档: http://localhost:8000/docs" -ForegroundColor Cyan
Write-Host "查看日志: docker-compose logs -f" -ForegroundColor Cyan
Write-Host "停止服务: docker-compose down" -ForegroundColor Cyan
Write-Host ""
