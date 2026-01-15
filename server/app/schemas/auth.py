from pydantic import BaseModel


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"


class LoginRequest(BaseModel):
    phone: str
    code: str  # 验证码（这里先做成固定码 123456）

