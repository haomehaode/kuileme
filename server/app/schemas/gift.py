from datetime import datetime
from pydantic import BaseModel, ConfigDict
from typing import Optional
from app.models.gift import GiftType


class GiftOut(BaseModel):
    id: int
    name: str
    description: Optional[str] = None
    image_url: Optional[str] = None
    points_required: int
    recovery_required: float
    type: GiftType
    stock: int
    is_limited: bool
    model_config = ConfigDict(from_attributes=True)


class ExchangeRecordOut(BaseModel):
    id: int
    user_id: int
    gift_id: int
    gift_name: str
    points_used: int
    recovery_used: float
    shipping_address: Optional[str] = None
    tracking_number: Optional[str] = None
    status: str
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)


class ExchangeRequest(BaseModel):
    gift_id: int
    shipping_address: Optional[str] = None  # 实物礼品需要
