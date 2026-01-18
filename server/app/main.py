from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

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

