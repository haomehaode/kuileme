from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
import random

from app.core.deps import get_db, get_current_user
from app.models.user import User
from app.models.recovery import RecoveryRecord, RecoveryRecordType, UserBalance
from app.schemas.recovery import (
    RecoveryRecordOut,
    UserBalanceOut,
    LotteryDrawRequest,
    LotteryDrawResponse,
)

router = APIRouter(prefix="/recovery", tags=["recovery"])


# 抽奖奖品配置
LOTTERY_PRIZES = [
    {"name": "谢谢参与", "amount": 0, "probability": 0.5},
    {"name": "小额回血", "amount": 5, "probability": 0.3},
    {"name": "中额回血", "amount": 20, "probability": 0.15},
    {"name": "大额回血", "amount": 100, "probability": 0.04},
    {"name": "超级回血", "amount": 500, "probability": 0.009},
    {"name": "巨额回血", "amount": 1000, "probability": 0.001},
]


def draw_prize() -> dict:
    """抽奖逻辑：根据概率随机抽取"""
    r = random.random()
    cumulative = 0.0
    for prize in LOTTERY_PRIZES:
        cumulative += prize["probability"]
        if r <= cumulative:
            return prize
    return LOTTERY_PRIZES[0]  # 默认返回谢谢参与


@router.get("/balance", response_model=UserBalanceOut)
def get_balance(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """获取用户余额（回血金 + 积分）"""
    balance = (
        db.query(UserBalance)
        .filter(UserBalance.user_id == current_user.id)
        .first()
    )
    if not balance:
        # 初始化余额
        balance = UserBalance(user_id=current_user.id)
        db.add(balance)
        db.commit()
        db.refresh(balance)
    return balance


@router.post("/lottery/draw", response_model=LotteryDrawResponse)
def draw_lottery(
    request: LotteryDrawRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """抽奖：投入1元，随机获得奖品"""
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

    # 检查余额
    if balance.recovery_balance < 1:
        raise HTTPException(status_code=400, detail="余额不足，请先充值")

    # 扣除投入
    balance.recovery_balance -= 1
    db.add(
        RecoveryRecord(
            user_id=current_user.id,
            type=RecoveryRecordType.lottery_cost,
            amount=-1,
            description="参与抽奖投入",
        )
    )

    # 抽奖
    prize = draw_prize()
    if prize["amount"] > 0:
        balance.recovery_balance += prize["amount"]
        db.add(
            RecoveryRecord(
                user_id=current_user.id,
                type=RecoveryRecordType.lottery_win,
                amount=prize["amount"],
                description=f"抽中{prize['name']}",
            )
        )

    db.commit()
    db.refresh(balance)

    return LotteryDrawResponse(
        prize_name=prize["name"],
        prize_amount=prize["amount"],
        new_balance=balance.recovery_balance,
    )


@router.get("/records", response_model=List[RecoveryRecordOut])
def get_recovery_records(
    skip: int = 0,
    limit: int = 20,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """获取回血记录列表"""
    records = (
        db.query(RecoveryRecord)
        .filter(RecoveryRecord.user_id == current_user.id)
        .order_by(RecoveryRecord.created_at.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )
    return records
