from pydantic import BaseModel


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"


class LoginRequest(BaseModel):
    phone: str
    code: str  # 验证码（这里先做成固定码 123456）


class PasswordLoginRequest(BaseModel):
    phone: str  # 手机号作为账号
    password: str


class RegisterRequest(BaseModel):
    phone: str
    code: str  # 验证码
    password: str


class ResetPasswordRequest(BaseModel):
    phone: str  # 手机号
    code: str  # 验证码
    new_password: str  # 新密码
