from datetime import datetime, timedelta

from jose import jwt
import bcrypt

from app.core.config import settings


def create_access_token(subject: str) -> str:
    expire = datetime.utcnow() + timedelta(
        minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
    )
    to_encode = {"sub": subject, "exp": expire}
    encoded_jwt = jwt.encode(
        to_encode,
        settings.JWT_SECRET_KEY,
        algorithm=settings.JWT_ALGORITHM,
    )
    return encoded_jwt


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    验证密码。
    支持 passlib 格式和直接 bcrypt 格式。
    """
    try:
        # 尝试使用 bcrypt 直接验证
        password_bytes = plain_password.encode('utf-8')
        # bcrypt 限制密码不能超过 72 字节
        if len(password_bytes) > 72:
            password_bytes = password_bytes[:72]
        hashed_bytes = hashed_password.encode('utf-8')
        return bcrypt.checkpw(password_bytes, hashed_bytes)
    except Exception:
        return False


def get_password_hash(password: str) -> str:
    """
    生成密码哈希。
    bcrypt 限制密码不能超过 72 字节，如果超过则截断。
    """
    password_bytes = password.encode('utf-8')
    # bcrypt 限制密码不能超过 72 字节
    if len(password_bytes) > 72:
        password_bytes = password_bytes[:72]
    # 生成 salt 并哈希密码
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password_bytes, salt)
    return hashed.decode('utf-8')

