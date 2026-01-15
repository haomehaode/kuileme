from typing import List

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.deps import get_db, get_current_user
from app.models.comment import Comment
from app.models.post import Post
from app.models.user import User
from app.schemas.comment import CommentCreate, CommentOut


router = APIRouter(prefix="/posts/{post_id}/comments", tags=["comments"])


@router.get("/", response_model=List[CommentOut])
def list_comments(
    post_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    comments = (
        db.query(Comment)
        .filter(Comment.post_id == post_id)
        .order_by(Comment.created_at.desc())
        .all()
    )
    return comments


@router.post("/", response_model=CommentOut, status_code=status.HTTP_201_CREATED)
def create_comment(
    post_id: int,
    data: CommentCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    post = db.query(Post).filter(Post.id == post_id).first()
    if not post:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Post not found",
        )

    comment = Comment(
        post_id=post_id,
        user_id=current_user.id,
        content=data.content,
    )
    db.add(comment)

    # 同步更新帖子评论数
    post.comments_count += 1

    db.commit()
    db.refresh(comment)
    return comment

