from datetime import datetime

from sqlalchemy import Boolean, Column, DateTime, ForeignKey, Integer, String
from sqlalchemy.orm import relationship

from app.db.base import Base


class Notification(Base):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

    type = Column(String(20), nullable=False)  # like/comment/reply/system
    title = Column(String(100), nullable=False)
    content = Column(String(500), nullable=False)
    related_id = Column(String(50), nullable=True)  # 关联的 post/comment id

    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", backref="notifications")

