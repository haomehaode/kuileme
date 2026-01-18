from pydantic import BaseModel, ConfigDict
from datetime import datetime


class NotificationOut(BaseModel):
    id: int
    type: str
    title: str
    content: str
    related_id: str | None = None
    is_read: bool
    created_at: datetime
    model_config = ConfigDict(from_attributes=True)

