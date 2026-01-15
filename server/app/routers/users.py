from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.deps import get_db, get_current_user
from app.models.user import User
from app.schemas.user import UserOut


router = APIRouter(prefix="/users", tags=["users"])


@router.get("/me", response_model=UserOut)
def read_me(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    return current_user

