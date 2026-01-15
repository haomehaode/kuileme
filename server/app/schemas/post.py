from pydantic import BaseModel, ConfigDict


class PostBase(BaseModel):
    content: str
    amount: float
    mood: str | None = None
    is_anonymous: bool = False
    tags: list[str] = []


class PostCreate(PostBase):
    pass


class PostOut(PostBase):
    id: int
    user_id: int
    likes: int
    comments_count: int
    model_config = ConfigDict(from_attributes=True)

