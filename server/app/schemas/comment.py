from pydantic import BaseModel, ConfigDict


class CommentBase(BaseModel):
    content: str


class CommentCreate(CommentBase):
    pass


class CommentOut(CommentBase):
    id: int
    user_id: int
    post_id: int
    model_config = ConfigDict(from_attributes=True)

