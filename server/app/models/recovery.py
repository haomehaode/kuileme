from datetime import datetime
from sqlalchemy import Column, Integer, String, Float, DateTime, Enum as SQLEnum
from sqlalchemy.orm import relationship

from app.db.base import Base
import enum


class RecoveryRecordType(str, enum.Enum):
    lottery_win = "lottery_win"  # 抽中回血金
    lottery_cost = "lottery_cost"  # 参与投入
    recharge = "recharge"  # 充值
    withdraw = "withdraw"  # 提现
    reward = "reward"  # 奖励（首次发布、连续发布等）


class RecoveryRecord(Base):
    __tablename__ = "recovery_records"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False, index=True)
    type = Column(SQLEnum(RecoveryRecordType), nullable=False)
    amount = Column(Float, nullable=False)  # 正数为收入，负数为支出
    description = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)


class UserBalance(Base):
    """用户余额表（回血金 + 积分）"""
    __tablename__ = "user_balances"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, unique=True, nullable=False, index=True)
    recovery_balance = Column(Float, default=0.0, nullable=False)  # 回血金余额
    points = Column(Integer, default=0, nullable=False)  # 积分余额
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
