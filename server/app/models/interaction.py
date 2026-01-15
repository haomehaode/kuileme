from datetime import datetime

from sqlalchemy import Column, DateTime, ForeignKey, Integer, String
from sqlalchemy.orm import relationship

from app.db.base import Base


class Interaction(Base):
    """
    互动：like / heart / share
    """

    __tablename__ = "interactions"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    post_id = Column(Integer, ForeignKey("posts.id"), nullable=False)

    action_type = Column(String(20), nullable=False)  # like / heart / share

    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", backref="interactions")
    post = relationship("Post", backref="interactions")

