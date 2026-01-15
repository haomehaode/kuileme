# Kuleme Backend API

FastAPI 后端服务，支持用户认证、帖子、评论、回血系统、勋章系统等功能。

## 快速开始

### 方式一：使用 Docker Compose（推荐）

#### 前置准备：配置 Docker 镜像源（国内用户）

为了加速镜像拉取，建议配置阿里云镜像源：

1. **打开 Docker Desktop**
2. **进入 Settings → Docker Engine**
3. **添加以下配置：**

```json
{
  "registry-mirrors": [
    "https://docker.mirrors.aliyuncs.com",
    "https://registry.cn-hangzhou.aliyuncs.com"
  ]
}
```

4. **点击 "Apply & Restart" 重启 Docker Desktop**

#### 部署步骤

1. 复制环境变量文件：
```bash
cp .env.example .env
```

2. 编辑 `.env` 文件，修改数据库密码和 JWT 密钥（生产环境必须修改）

3. 启动服务：
```bash
docker-compose up -d --build
```

4. 访问 API 文档：
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

### 方式二：本地开发

1. 确保已安装 PostgreSQL（版本 12+）

2. 创建数据库：
```sql
CREATE DATABASE kuleme;
CREATE USER kuleme WITH PASSWORD 'kuleme_password';
GRANT ALL PRIVILEGES ON DATABASE kuleme TO kuleme;
```

3. 安装依赖：
```bash
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

4. 配置环境变量：
```bash
cp .env.example .env
# 编辑 .env 文件，设置数据库连接信息
```

5. 初始化数据库表：
```bash
python -c "from app.db.session import engine; from app.db.base import Base; Base.metadata.create_all(bind=engine)"
```

6. 启动服务：
```bash
uvicorn app.main:app --reload --port 8000
```

## API 端点

### 认证
- `POST /auth/login` - 用户登录
- `POST /auth/login-sms` - 短信登录（模拟）

### 用户
- `GET /users/me` - 获取当前用户信息

### 帖子
- `GET /posts/` - 获取帖子列表
- `POST /posts/` - 创建帖子
- `GET /posts/{post_id}` - 获取帖子详情

### 评论
- `GET /comments/?post_id={post_id}` - 获取评论列表
- `POST /comments/` - 创建评论

### 互动
- `POST /interactions/toggle` - 点赞/心碎切换

### 通知
- `GET /notifications/` - 获取通知列表
- `PUT /notifications/{notification_id}/read` - 标记已读
- `PUT /notifications/read-all` - 全部标记已读

### 回血系统
- `GET /recovery/balance` - 获取余额
- `POST /recovery/lottery/draw` - 抽奖
- `GET /recovery/records` - 获取回血记录

### 礼品中心
- `GET /gifts` - 获取礼品列表
- `POST /gifts/{gift_id}/exchange` - 兑换礼品
- `GET /gifts/exchange-records` - 获取兑换记录

### 成长系统
- `GET /growth/summary` - 获取成长汇总
- `GET /growth/level` - 获取等级信息
- `GET /growth/points-records` - 获取积分记录

### 勋章
- `GET /medals` - 获取勋章列表

### 复盘分析
- `GET /review/summary` - 获取复盘汇总
- `POST /review/message` - 保存留言

## 数据库迁移

当前使用 SQLAlchemy 自动创建表。生产环境建议使用 Alembic 进行数据库迁移：

```bash
pip install alembic
alembic init alembic
# 配置 alembic.ini 和 alembic/env.py
alembic revision --autogenerate -m "Initial migration"
alembic upgrade head
```

## 环境变量

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| POSTGRES_USER | PostgreSQL 用户名 | kuleme |
| POSTGRES_PASSWORD | PostgreSQL 密码 | kuleme_password |
| POSTGRES_DB | 数据库名 | kuleme |
| POSTGRES_HOST | 数据库主机 | localhost |
| POSTGRES_PORT | 数据库端口 | 5432 |
| JWT_SECRET_KEY | JWT 密钥 | change-me-to-a-random-secret-in-production |
| JWT_ALGORITHM | JWT 算法 | HS256 |
| ACCESS_TOKEN_EXPIRE_MINUTES | Token 过期时间（分钟） | 1440 |

## 生产环境部署

1. 修改 `.env` 文件中的敏感信息（密码、密钥）
2. 使用 Docker Compose 部署：
```bash
docker-compose -f docker-compose.yml up -d
```
3. 配置反向代理（Nginx）和 HTTPS
4. 定期备份数据库

## 开发

```bash
# 运行测试
pytest

# 代码格式化
black app/

# 类型检查
mypy app/
```
