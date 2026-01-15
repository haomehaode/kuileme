from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime

from app.db.base import Base


class UserLevel(Base):
    """用户等级和经验值"""
    __tablename__ = "user_levels"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, unique=True, nullable=False, index=True)
    level = Column(Integer, default=1, nullable=False)
    exp = Column(Integer, default=0, nullable=False)  # 当前经验值
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)


class PointsRecord(Base):
    """积分记录"""
    __tablename__ = "points_records"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False, index=True)
    amount = Column(Integer, nullable=False)  # 正数为获得，负数为消耗
    description = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
