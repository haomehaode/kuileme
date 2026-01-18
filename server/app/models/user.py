from datetime import datetime

from sqlalchemy import Column, DateTime, Integer, String

from app.db.base import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    phone = Column(String(20), unique=True, index=True, nullable=False)
    nickname = Column(String(50), nullable=False)
    password_hash = Column(String(200), nullable=True)
    avatar = Column(String(500), nullable=True)  # 头像URL
    bio = Column(String(200), nullable=True)  # 亏损宣言/签名
    tags = Column(String(500), nullable=True)  # 常用投资领域，JSON格式存储
    hide_total_loss = Column(Integer, default=0)  # 是否隐藏总亏损额，0=否，1=是
    hide_medals = Column(Integer, default=0)  # 是否隐藏成就勋章，0=否，1=是

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(
        DateTime, default=datetime.utcnow, onupdate=datetime.utcnow
    )

