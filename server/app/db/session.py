from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import os

from app.core.config import settings


# 根据数据库类型配置连接参数
db_type = os.getenv("DATABASE_TYPE", settings.DATABASE_TYPE).lower()

if db_type == "postgresql":
    # PostgreSQL 连接池配置
    engine = create_engine(
        settings.SQLALCHEMY_DATABASE_URI,
        pool_size=10,
        max_overflow=20,
        pool_pre_ping=True,  # 自动重连
        echo=False,  # 设置为 True 可以看到 SQL 日志
    )
else:
    # SQLite 连接配置（不需要连接池）
    engine = create_engine(
        settings.SQLALCHEMY_DATABASE_URI,
        connect_args={"check_same_thread": False},  # SQLite 需要这个参数
        echo=False,  # 设置为 True 可以看到 SQL 日志
    )

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

