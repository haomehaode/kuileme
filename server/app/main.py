import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.core.config import settings
from app.db.base import Base
from app.db.session import engine
from app.routers import (
    auth,
    users,
    posts,
    comments,
    interactions,
    notifications,
    recovery,
    gifts,
    growth,
    medals,
    review,
)


def create_app() -> FastAPI:
    app = FastAPI(title=settings.PROJECT_NAME)

    # 允许 Flutter App 访问（开发时可以先放开）
    app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # 创建数据库表
    Base.metadata.create_all(bind=engine)
    
    # 执行数据库迁移（添加用户表新字段）
    try:
        import sys
        import os as os_module
        # 添加server目录到路径
        server_dir = os_module.path.dirname(os_module.path.dirname(os_module.path.abspath(__file__)))
        if server_dir not in sys.path:
            sys.path.insert(0, server_dir)
        from migrate_add_user_fields import migrate_database
        migrate_database()
    except ImportError as e:
        # 如果迁移脚本不存在，跳过（首次运行时会自动创建表）
        print(f"提示: 跳过数据库迁移（{e}）")
    except Exception as e:
        # 迁移失败不影响启动，但会记录错误
        print(f"警告: 数据库迁移失败: {e}")
    
    # 创建上传目录
    os.makedirs("uploads/avatars", exist_ok=True)
    
    # 挂载静态文件服务（用于访问上传的文件）
    app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

    # 注册路由
    app.include_router(auth.router)
    app.include_router(users.router)
    app.include_router(posts.router)
    app.include_router(comments.router)
    app.include_router(interactions.router)
    app.include_router(notifications.router)
    app.include_router(recovery.router)
    app.include_router(gifts.router)
    app.include_router(growth.router)
    app.include_router(medals.router)
    app.include_router(review.router)

    return app


app = create_app()

