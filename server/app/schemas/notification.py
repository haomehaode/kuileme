from pydantic import BaseModel, ConfigDict


class NotificationOut(BaseModel):
    id: int
    type: str
    title: str
    content: str
    related_id: str | None = None
    is_read: bool
    model_config = ConfigDict(from_attributes=True)

