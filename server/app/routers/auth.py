from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import create_access_token
from app.core.deps import get_db
from app.models.user import User
from app.schemas.auth import LoginRequest, Token


router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/login", response_model=Token)
def login(
    data: LoginRequest,
    db: Session = Depends(get_db),
):
    """
    简化版登录：
    - 前端传手机号 + 验证码
    - 验证码固定为 123456
    - 如果用户不存在则自动创建一个
    """
    if data.code != "123456":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="验证码错误（开发环境固定为 123456）",
        )

    user = db.query(User).filter(User.phone == data.phone).first()
    if not user:
        # 自动注册
        user = User(
            phone=data.phone,
            nickname=f"亏友_{data.phone[-4:]}",
        )
        db.add(user)
        db.commit()
        db.refresh(user)

    token = create_access_token(str(user.id))
    return Token(access_token=token)

