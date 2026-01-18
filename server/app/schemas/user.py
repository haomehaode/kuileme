from pydantic import BaseModel, ConfigDict
from typing import List, Optional


class UserBase(BaseModel):
    phone: str
    nickname: str


class UserCreate(BaseModel):
    phone: str
    nickname: str
    password: str | None = None


class UserUpdate(BaseModel):
    nickname: Optional[str] = None
    avatar: Optional[str] = None
    bio: Optional[str] = None
    tags: Optional[List[str]] = None
    hide_total_loss: Optional[int] = None
    hide_medals: Optional[int] = None


class UserOut(UserBase):
    id: int
    avatar: Optional[str] = None
    bio: Optional[str] = None
    tags: Optional[List[str]] = None
    hide_total_loss: int = 0
    hide_medals: int = 0
    model_config = ConfigDict(from_attributes=True)

