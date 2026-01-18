from pydantic_settings import BaseSettings
import os


class Settings(BaseSettings):
    """
    基础配置。

    支持 SQLite（开发环境）和 PostgreSQL（生产环境）切换。
    通过 DATABASE_TYPE 环境变量控制，默认为 sqlite。
    开发环境：通过 .env 文件配置
    生产环境（Docker）：通过环境变量配置
    """

    PROJECT_NAME: str = "Kuleme Backend"

    # 数据库类型：sqlite 或 postgresql
    DATABASE_TYPE: str = "sqlite"

    # SQLite 数据库配置（默认）
    SQLITE_DB_PATH: str = "kuleme.db"

    # PostgreSQL 数据库配置（可选）
    POSTGRES_USER: str = "kuleme"
    POSTGRES_PASSWORD: str = "kuleme_password"
    POSTGRES_DB: str = "kuleme"
    POSTGRES_HOST: str = "localhost"
    POSTGRES_PORT: str = "5432"

    @property
    def SQLALCHEMY_DATABASE_URI(self) -> str:
        """构建数据库连接字符串"""
        db_type = os.getenv("DATABASE_TYPE", self.DATABASE_TYPE).lower()
        
        if db_type == "postgresql":
            # PostgreSQL 连接字符串
            return (
                f"postgresql://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}"
                f"@{self.POSTGRES_HOST}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
            )
        else:
            # SQLite 连接字符串（默认）
            return f"sqlite:///./{self.SQLITE_DB_PATH}"

    # JWT 设置
    JWT_SECRET_KEY: str = "change-me-to-a-random-secret-in-production"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24  # 1 天

    class Config:
        env_file = ".env"
        case_sensitive = False


settings = Settings()

