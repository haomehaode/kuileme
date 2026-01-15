from pydantic import BaseModel, ConfigDict


class UserBase(BaseModel):
    phone: str
    nickname: str


class UserCreate(BaseModel):
    phone: str
    nickname: str
    password: str | None = None


class UserOut(UserBase):
    id: int
    model_config = ConfigDict(from_attributes=True)

