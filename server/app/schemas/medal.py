from pydantic import BaseModel, ConfigDict
from typing import Optional
from datetime import datetime
from app.models.medal import MedalRarity


class MedalOut(BaseModel):
    id: int
    name: str
    description: Optional[str] = None
    icon: str
    rarity: MedalRarity
    unlock_condition: str
    target_value: Optional[int] = None
    model_config = ConfigDict(from_attributes=True)


class UserMedalOut(BaseModel):
    medal_id: int
    is_unlocked: bool
    progress: int
    unlocked_at: Optional[datetime] = None
    model_config = ConfigDict(from_attributes=True)


class MedalWithProgress(MedalOut):
    """勋章 + 用户进度"""
    is_unlocked: bool
    progress: int
    unlocked_at: Optional[datetime] = None
