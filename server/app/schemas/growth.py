from pydantic import BaseModel, ConfigDict
from datetime import datetime


class UserLevelOut(BaseModel):
    user_id: int
    level: int
    exp: int
    model_config = ConfigDict(from_attributes=True)


class PointsRecordOut(BaseModel):
    id: int
    user_id: int
    amount: int
    description: str
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)


class GrowthSummaryOut(BaseModel):
    """成长系统汇总：等级、经验、积分、回血金"""
    level: int
    exp: int
    points: int
    recovery_balance: float
    unlocked_medals_count: int
