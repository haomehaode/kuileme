from datetime import datetime
from sqlalchemy import Column, Integer, String, Float, DateTime, Boolean, Enum as SQLEnum
from sqlalchemy.orm import relationship

from app.db.base import Base
import enum


class GiftType(str, enum.Enum):
    physical = "physical"  # 实物礼品
    virtual = "virtual"  # 虚拟礼品
    limited = "limited"  # 限时特惠


class Gift(Base):
    __tablename__ = "gifts"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    description = Column(String)
    image_url = Column(String)
    points_required = Column(Integer, default=0, nullable=False)  # 所需积分
    recovery_required = Column(Float, default=0.0, nullable=False)  # 所需回血金
    type = Column(SQLEnum(GiftType), nullable=False)
    stock = Column(Integer, default=999, nullable=False)  # 库存
    is_limited = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)


class ExchangeRecord(Base):
    __tablename__ = "exchange_records"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False, index=True)
    gift_id = Column(Integer, nullable=False)
    gift_name = Column(String, nullable=False)
    points_used = Column(Integer, default=0, nullable=False)
    recovery_used = Column(Float, default=0.0, nullable=False)
    shipping_address = Column(String, nullable=True)  # 实物礼品需要
    tracking_number = Column(String, nullable=True)  # 物流单号
    status = Column(String, default="pending", nullable=False)  # pending, shipped, completed, cancelled
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
