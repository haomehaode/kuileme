from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """
    基础配置。

    使用 PostgreSQL 数据库，支持从环境变量读取配置。
    开发环境：通过 .env 文件配置
    生产环境（Docker）：通过环境变量配置
    """

    PROJECT_NAME: str = "Kuleme Backend"

    # PostgreSQL 数据库配置
    POSTGRES_USER: str = "kuleme"
    POSTGRES_PASSWORD: str = "kuleme_password"
    POSTGRES_DB: str = "kuleme"
    POSTGRES_HOST: str = "localhost"
    POSTGRES_PORT: str = "5432"

    @property
    def SQLALCHEMY_DATABASE_URI(self) -> str:
        """构建 PostgreSQL 连接字符串"""
        return (
            f"postgresql://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}"
            f"@{self.POSTGRES_HOST}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
        )

    # JWT 设置
    JWT_SECRET_KEY: str = "change-me-to-a-random-secret-in-production"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 1 天

    class Config:
        env_file = ".env"
        case_sensitive = False


settings = Settings()

