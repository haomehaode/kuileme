from typing import List

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.core.deps import get_db, get_current_user
from app.models.post import Post
from app.models.user import User
from app.schemas.post import PostCreate, PostOut


router = APIRouter(prefix="/posts", tags=["posts"])


@router.get("/", response_model=List[PostOut])
def list_posts(
    db: Session = Depends(get_db),
    tag: str | None = Query(default=None),
    skip: int = 0,
    limit: int = 20,
):
    q = db.query(Post)
    if tag:
        q = q.filter(Post.tags.contains(tag))
    posts = (
        q.order_by(Post.created_at.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )
    # 把 tags 字符串拆成 list
    for p in posts:
        p.tags = p.tags.split(",") if p.tags else []
    return posts


@router.post("/", response_model=PostOut, status_code=status.HTTP_201_CREATED)
def create_post(
    data: PostCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    tags_str = ",".join(data.tags) if data.tags else None
    post = Post(
        user_id=current_user.id,
        content=data.content,
        amount=data.amount,
        mood=data.mood,
        is_anonymous=data.is_anonymous,
        tags=tags_str,
    )
    db.add(post)
    db.commit()
    db.refresh(post)
    post.tags = data.tags
    return post


@router.get("/me", response_model=List[PostOut])
def get_my_posts(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    skip: int = 0,
    limit: int = 20,
):
    """获取当前用户发布的帖子列表"""
    posts = (
        db.query(Post)
        .filter(Post.user_id == current_user.id)
        .order_by(Post.created_at.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )
    # 把 tags 字符串拆成 list
    for p in posts:
        p.tags = p.tags.split(",") if p.tags else []
    return posts


@router.get("/{post_id}", response_model=PostOut)
def get_post(
    post_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),  # 保证登录
):
    post = db.query(Post).filter(Post.id == post_id).first()
    if not post:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Post not found",
        )
    post.tags = post.tags.split(",") if post.tags else []
    return post


@router.put("/{post_id}", response_model=PostOut)
def update_post(
    post_id: int,
    data: PostCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """更新帖子（只能更新自己的帖子）"""
    post = db.query(Post).filter(Post.id == post_id).first()
    if not post:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Post not found",
        )
    
    # 检查是否是帖子所有者
    if post.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only update your own posts",
        )
    
    # 更新帖子内容
    tags_str = ",".join(data.tags) if data.tags else None
    post.content = data.content
    post.amount = data.amount
    post.mood = data.mood
    post.is_anonymous = data.is_anonymous
    post.tags = tags_str
    
    db.commit()
    db.refresh(post)
    post.tags = data.tags
    return post


@router.delete("/{post_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_post(
    post_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """删除帖子（只能删除自己的帖子）"""
    post = db.query(Post).filter(Post.id == post_id).first()
    if not post:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Post not found",
        )
    
    # 检查是否是帖子所有者
    if post.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only delete your own posts",
        )
    
    db.delete(post)
    db.commit()
    return None

