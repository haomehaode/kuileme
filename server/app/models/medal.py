from datetime import datetime
from sqlalchemy import Column, Integer, String, DateTime, Boolean, Enum as SQLEnum
from sqlalchemy.orm import relationship

from app.db.base import Base
import enum


class MedalRarity(str, enum.Enum):
    common = "common"
    rare = "rare"
    epic = "epic"
    legendary = "legendary"


class Medal(Base):
    __tablename__ = "medals"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    description = Column(String)
    icon = Column(String)  # 存储图标名称，前端用 Material Icons
    rarity = Column(SQLEnum(MedalRarity), nullable=False)
    unlock_condition = Column(String, nullable=False)
    target_value = Column(Integer, nullable=True)  # 解锁目标值


class UserMedal(Base):
    """用户勋章关联表"""
    __tablename__ = "user_medals"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False, index=True)
    medal_id = Column(Integer, nullable=False, index=True)
    is_unlocked = Column(Boolean, default=False, nullable=False)
    progress = Column(Integer, default=0, nullable=False)  # 当前进度
    unlocked_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
