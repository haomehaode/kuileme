from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.core.security import create_access_token, verify_password, get_password_hash
from app.core.deps import get_db
from app.models.user import User
from app.schemas.auth import LoginRequest, PasswordLoginRequest, RegisterRequest, ResetPasswordRequest, Token


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


@router.post("/login/password", response_model=Token)
def login_with_password(
    data: PasswordLoginRequest,
    db: Session = Depends(get_db),
):
    """
    账号密码登录：
    - 使用手机号作为账号
    - 验证密码
    """
    user = db.query(User).filter(User.phone == data.phone).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="用户不存在",
        )
    
    if not user.password_hash:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="该账号未设置密码，请使用验证码登录",
        )
    
    if not verify_password(data.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="密码错误",
        )
    
    token = create_access_token(str(user.id))
    return Token(access_token=token)


@router.post("/register", response_model=Token)
def register(
    data: RegisterRequest,
    db: Session = Depends(get_db),
):
    """
    用户注册：
    - 手机号 + 验证码 + 密码
    - 验证码固定为 123456（开发环境）
    - 如果用户已存在，返回错误
    """
    # 验证码检查（开发环境固定为 123456）
    if data.code != "123456":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="验证码错误（开发环境固定为 123456）",
        )
    
    # 验证密码长度（bcrypt 限制为 72 字节）
    password_bytes = data.password.encode('utf-8')
    if len(password_bytes) > 72:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="密码长度不能超过 72 个字符",
        )
    
    if len(data.password) < 6:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="密码长度至少 6 个字符",
        )
    
    # 检查用户是否已存在
    existing_user = db.query(User).filter(User.phone == data.phone).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="该手机号已被注册",
        )
    
    # 创建新用户
    user = User(
        phone=data.phone,
        nickname=f"亏友_{data.phone[-4:]}",
        password_hash=get_password_hash(data.password),
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    
    token = create_access_token(str(user.id))
    return Token(access_token=token)


@router.post("/reset-password")
def reset_password(
    data: ResetPasswordRequest,
    db: Session = Depends(get_db),
):
    """
    重置密码：
    - 手机号 + 验证码 + 新密码
    - 验证码固定为 123456（开发环境）
    """
    # 验证码检查（开发环境固定为 123456）
    if data.code != "123456":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="验证码错误（开发环境固定为 123456）",
        )
    
    # 验证密码长度
    password_bytes = data.new_password.encode('utf-8')
    if len(password_bytes) > 72:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="密码长度不能超过 72 个字符",
        )
    
    if len(data.new_password) < 6:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="密码长度至少 6 个字符",
        )
    
    # 查找用户
    user = db.query(User).filter(User.phone == data.phone).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="用户不存在",
        )
    
    # 更新密码
    user.password_hash = get_password_hash(data.new_password)
    db.commit()
    db.refresh(user)
    
    return {"message": "密码重置成功"}

