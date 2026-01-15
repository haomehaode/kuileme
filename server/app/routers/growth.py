from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.deps import get_db, get_current_user
from app.models.user import User
from app.models.growth import UserLevel, PointsRecord
from app.models.recovery import UserBalance
from app.models.medal import UserMedal
from app.schemas.growth import (
    UserLevelOut,
    PointsRecordOut,
    GrowthSummaryOut,
)

router = APIRouter(prefix="/growth", tags=["growth"])


@router.get("/summary", response_model=GrowthSummaryOut)
def get_growth_summary(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """获取成长系统汇总：等级、经验、积分、回血金、已解锁勋章数"""
    # 获取等级
    user_level = (
        db.query(UserLevel)
        .filter(UserLevel.user_id == current_user.id)
        .first()
    )
    if not user_level:
        user_level = UserLevel(user_id=current_user.id)
        db.add(user_level)
        db.commit()
        db.refresh(user_level)

    # 获取余额
    balance = (
        db.query(UserBalance)
        .filter(UserBalance.user_id == current_user.id)
        .first()
    )
    if not balance:
        balance = UserBalance(user_id=current_user.id)
        db.add(balance)
        db.commit()
        db.refresh(balance)

    # 获取已解锁勋章数
    unlocked_count = (
        db.query(UserMedal)
        .filter(
            UserMedal.user_id == current_user.id,
            UserMedal.is_unlocked == True,
        )
        .count()
    )

    return GrowthSummaryOut(
        level=user_level.level,
        exp=user_level.exp,
        points=balance.points,
        recovery_balance=balance.recovery_balance,
        unlocked_medals_count=unlocked_count,
    )


@router.get("/level", response_model=UserLevelOut)
def get_user_level(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """获取用户等级信息"""
    user_level = (
        db.query(UserLevel)
        .filter(UserLevel.user_id == current_user.id)
        .first()
    )
    if not user_level:
        user_level = UserLevel(user_id=current_user.id)
        db.add(user_level)
        db.commit()
        db.refresh(user_level)
    return user_level


@router.get("/points-records", response_model=List[PointsRecordOut])
def get_points_records(
    skip: int = 0,
    limit: int = 20,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """获取积分记录"""
    records = (
        db.query(PointsRecord)
        .filter(PointsRecord.user_id == current_user.id)
        .order_by(PointsRecord.created_at.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )
    return records
