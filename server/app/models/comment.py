from datetime import datetime

from sqlalchemy import Column, DateTime, ForeignKey, Integer, String
from sqlalchemy.orm import relationship

from app.db.base import Base


class Comment(Base):
    __tablename__ = "comments"

    id = Column(Integer, primary_key=True, index=True)
    post_id = Column(Integer, ForeignKey("posts.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    content = Column(String(1000), nullable=False)

    created_at = Column(DateTime, default=datetime.utcnow)

    post = relationship("Post", backref="comments")
    user = relationship("User", backref="comments")

