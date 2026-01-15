from datetime import datetime

from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, Float, Boolean
from sqlalchemy.orm import relationship

from app.db.base import Base


class Post(Base):
  __tablename__ = "posts"

  id = Column(Integer, primary_key=True, index=True)
  user_id = Column(Integer, ForeignKey("users.id"), nullable=False)

  content = Column(String(2000), nullable=False)
  amount = Column(Float, nullable=False, default=0.0)  # 亏损金额
  mood = Column(String(20), nullable=True)  # 心理状态
  is_anonymous = Column(Boolean, default=False)

  tags = Column(String(255), nullable=True)  # 简化：用逗号分隔的字符串

  likes = Column(Integer, default=0)
  comments_count = Column(Integer, default=0)

  created_at = Column(DateTime, default=datetime.utcnow)

  user = relationship("User", backref="posts")

