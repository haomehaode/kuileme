from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.core.config import settings


# PostgreSQL 连接池配置
engine = create_engine(
    settings.SQLALCHEMY_DATABASE_URI,
    pool_size=10,
    max_overflow=20,
    pool_pre_ping=True,  # 自动重连
    echo=False,  # 设置为 True 可以看到 SQL 日志
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

