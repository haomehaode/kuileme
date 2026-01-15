# Kuleme Backend Docker 停止脚本

Write-Host "停止 Kuleme Backend 服务..." -ForegroundColor Yellow
docker-compose down
Write-Host "✓ 服务已停止" -ForegroundColor Green
