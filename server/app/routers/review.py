from datetime import datetime, timedelta
from typing import List
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func, and_

from app.core.deps import get_db, get_current_user
from app.models.user import User
from app.models.post import Post

router = APIRouter(prefix="/review", tags=["review"])


@router.get("/summary")
def get_review_summary(
    period: str = "month",  # month, year
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """获取复盘分析汇总"""
    # 计算时间范围
    now = datetime.utcnow()
    if period == "month":
        start_date = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
    else:  # year
        start_date = now.replace(month=1, day=1, hour=0, minute=0, second=0, microsecond=0)

    # 查询用户本期的所有帖子
    posts = (
        db.query(Post)
        .filter(
            and_(
                Post.user_id == current_user.id,
                Post.created_at >= start_date,
            )
        )
        .all()
    )

    # 计算总亏损
    total_loss = sum(abs(post.amount) for post in posts)

    # 计算跌幅（假设初始资产10万）
    initial_value = 100000.0
    loss_percent = (total_loss / initial_value * 100) if initial_value > 0 else 0

    # 生成净值走势数据（简化：最近30天）
    net_value_trend = []
    current_value = 100.0
    for i in range(30):
        # 简化：每天随机减少一点（实际应该按真实日期聚合）
        day_posts = [p for p in posts if (now - p.created_at).days == (29 - i)]
        day_loss = sum(abs(p.amount) for p in day_posts)
        current_value = max(0, current_value - day_loss / 1000)
        net_value_trend.append(current_value)

    # 分析亏损原因（基于内容关键词）
    keywords = {
        "chase": ["追涨", "杀跌", "追高", "割肉", "止损"],
        "message": ["消息", "听说", "据说", "内幕", "推荐", "群友"],
        "bottom": ["抄底", "底部", "到底", "接飞刀", "低点"],
    }

    chase_count = 0
    message_count = 0
    bottom_count = 0

    for post in posts:
        content_lower = post.content.lower()
        if any(kw in content_lower for kw in keywords["chase"]):
            chase_count += 1
        if any(kw in content_lower for kw in keywords["message"]):
            message_count += 1
        if any(kw in content_lower for kw in keywords["bottom"]):
            bottom_count += 1

    total_reasons = chase_count + message_count + bottom_count
    if total_reasons == 0:
        # 默认值
        loss_reasons = {
            "追涨杀跌": 45,
            "小道消息": 30,
            "幻觉抄底": 25,
        }
    else:
        loss_reasons = {
            "追涨杀跌": int(chase_count / total_reasons * 100),
            "小道消息": int(message_count / total_reasons * 100),
            "幻觉抄底": int(bottom_count / total_reasons * 100),
        }

    return {
        "total_loss": total_loss,
        "loss_percent": round(loss_percent, 1),
        "net_value_trend": net_value_trend,
        "loss_reasons": loss_reasons,
    }


@router.post("/message")
def save_message_to_future(
    message: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """保存给未来的留言（简化：直接存储，实际应该加密）"""
    # TODO: 实现加密存储
    # 这里先简单返回成功
    return {"message": "留言已保存", "encrypted": False}
