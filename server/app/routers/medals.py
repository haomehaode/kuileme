from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import and_

from app.core.deps import get_db, get_current_user
from app.models.user import User
from app.models.medal import Medal, UserMedal, MedalRarity
from app.schemas.medal import MedalOut, MedalWithProgress

router = APIRouter(prefix="/medals", tags=["medals"])


@router.get("", response_model=List[MedalWithProgress])
def get_medals(
    rarity: str | None = None,  # common, rare, epic, legendary
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """获取勋章列表（带用户进度）"""
    query = db.query(Medal)
    if rarity:
        try:
            rarity_enum = MedalRarity(rarity)
            query = query.filter(Medal.rarity == rarity_enum)
        except ValueError:
            # 无效的rarity值，忽略过滤
            pass

    medals = query.all()
    result = []

    for medal in medals:
        user_medal = (
            db.query(UserMedal)
            .filter(
                and_(
                    UserMedal.user_id == current_user.id,
                    UserMedal.medal_id == medal.id,
                )
            )
            .first()
        )

        if not user_medal:
            # 初始化用户勋章记录
            user_medal = UserMedal(
                user_id=current_user.id,
                medal_id=medal.id,
                is_unlocked=False,
                progress=0,
            )
            db.add(user_medal)
            db.commit()
            db.refresh(user_medal)

        result.append(
            MedalWithProgress(
                id=medal.id,
                name=medal.name,
                description=medal.description,
                icon=medal.icon,
                rarity=medal.rarity,
                unlock_condition=medal.unlock_condition,
                target_value=medal.target_value,
                is_unlocked=user_medal.is_unlocked,
                progress=user_medal.progress,
                unlocked_at=user_medal.unlocked_at,
            )
        )

    return result
