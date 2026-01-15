from datetime import datetime
from pydantic import BaseModel, ConfigDict
from typing import Optional
from app.models.recovery import RecoveryRecordType


class RecoveryRecordOut(BaseModel):
    id: int
    user_id: int
    type: RecoveryRecordType
    amount: float
    description: str
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)


class UserBalanceOut(BaseModel):
    user_id: int
    recovery_balance: float
    points: int
    model_config = ConfigDict(from_attributes=True)


class LotteryDrawRequest(BaseModel):
    pass  # 不需要参数，从 token 获取用户


class LotteryDrawResponse(BaseModel):
    prize_name: str
    prize_amount: float
    new_balance: float
