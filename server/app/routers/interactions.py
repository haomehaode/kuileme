from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.deps import get_db, get_current_user
from app.models.interaction import Interaction
from app.models.post import Post
from app.models.user import User


router = APIRouter(prefix="/posts/{post_id}/interactions", tags=["interactions"])


@router.post("/")
def interact_post(
    post_id: int,
    action: str,  # like / heart
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    if action not in {"like", "heart"}:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid action type",
        )

    post = db.query(Post).filter(Post.id == post_id).first()
    if not post:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Post not found",
        )

    # 简化：同一用户对同一帖子多次点击相同 action 会切换开关
    existing = (
        db.query(Interaction)
        .filter(
            Interaction.post_id == post_id,
            Interaction.user_id == current_user.id,
            Interaction.action_type == action,
        )
        .first()
    )

    if existing:
        db.delete(existing)
        if action == "like":
            post.likes = max(0, post.likes - 1)
    else:
        inter = Interaction(
            post_id=post_id,
            user_id=current_user.id,
            action_type=action,
        )
        db.add(inter)
        if action == "like":
            post.likes += 1

    db.commit()
    return {"success": True, "likes": post.likes}

