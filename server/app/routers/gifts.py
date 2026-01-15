from typing import List
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.deps import get_db, get_current_user
from app.models.user import User
from app.models.gift import Gift, ExchangeRecord
from app.models.recovery import UserBalance
from app.schemas.gift import GiftOut, ExchangeRecordOut, ExchangeRequest

router = APIRouter(prefix="/gifts", tags=["gifts"])


@router.get("", response_model=List[GiftOut])
def get_gifts(
    type: str | None = None,  # physical, virtual, limited
    db: Session = Depends(get_db),
):
    """获取礼品列表"""
    query = db.query(Gift)
    if type:
        query = query.filter(Gift.type == type)
    gifts = query.all()
    return gifts


@router.post("/{gift_id}/exchange", response_model=ExchangeRecordOut)
def exchange_gift(
    gift_id: int,
    request: ExchangeRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """兑换礼品"""
    gift = db.query(Gift).filter(Gift.id == gift_id).first()
    if not gift:
        raise HTTPException(status_code=404, detail="礼品不存在")

    if gift.stock <= 0:
        raise HTTPException(status_code=400, detail="该礼品已售罄")

    # 获取用户余额
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

    # 检查积分和回血金
    if gift.points_required > balance.points:
        raise HTTPException(
            status_code=400,
            detail=f"积分不足，还需要{gift.points_required - balance.points}积分",
        )

    if gift.recovery_required > balance.recovery_balance:
        raise HTTPException(
            status_code=400,
            detail=f"回血金不足，还需要{gift.recovery_required - balance.recovery_balance:.2f}元",
        )

    # 扣除积分和回血金
    balance.points -= gift.points_required
    balance.recovery_balance -= gift.recovery_required
    gift.stock -= 1

    # 创建兑换记录
    exchange = ExchangeRecord(
        user_id=current_user.id,
        gift_id=gift.id,
        gift_name=gift.name,
        points_used=gift.points_required,
        recovery_used=gift.recovery_required,
        shipping_address=request.shipping_address if gift.type.value == "physical" else None,
        status="pending",
    )
    db.add(exchange)
    db.commit()
    db.refresh(exchange)

    return exchange


@router.get("/exchange-records", response_model=List[ExchangeRecordOut])
def get_exchange_records(
    skip: int = 0,
    limit: int = 20,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """获取兑换记录"""
    records = (
        db.query(ExchangeRecord)
        .filter(ExchangeRecord.user_id == current_user.id)
        .order_by(ExchangeRecord.created_at.desc())
        .offset(skip)
        .limit(limit)
        .all()
    )
    return records
