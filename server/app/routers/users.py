import json
import os
import uuid
from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session

from app.core.deps import get_db, get_current_user
from app.models.user import User
from app.schemas.user import UserOut, UserUpdate


router = APIRouter(prefix="/users", tags=["users"])


@router.get("/me", response_model=UserOut)
def read_me(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """获取当前用户信息"""
    # 解析tags字段（如果是JSON字符串）
    user_dict = {
        "id": current_user.id,
        "phone": current_user.phone,
        "nickname": current_user.nickname,
        "avatar": current_user.avatar,
        "bio": current_user.bio,
        "tags": json.loads(current_user.tags) if current_user.tags else [],
        "hide_total_loss": current_user.hide_total_loss or 0,
        "hide_medals": current_user.hide_medals or 0,
    }
    return UserOut(**user_dict)


@router.put("/me", response_model=UserOut)
def update_me(
    user_update: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """更新当前用户信息"""
    # 更新昵称
    if user_update.nickname is not None:
        if len(user_update.nickname.strip()) == 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="昵称不能为空",
            )
        if len(user_update.nickname) > 50:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="昵称长度不能超过50个字符",
            )
        current_user.nickname = user_update.nickname.strip()
    
    # 更新头像
    if user_update.avatar is not None:
        current_user.avatar = user_update.avatar
    
    # 更新签名
    if user_update.bio is not None:
        if len(user_update.bio) > 200:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="签名长度不能超过200个字符",
            )
        current_user.bio = user_update.bio
    
    # 更新标签
    if user_update.tags is not None:
        current_user.tags = json.dumps(user_update.tags, ensure_ascii=False)
    
    # 更新隐私设置
    if user_update.hide_total_loss is not None:
        current_user.hide_total_loss = user_update.hide_total_loss
    
    if user_update.hide_medals is not None:
        current_user.hide_medals = user_update.hide_medals
    
    db.commit()
    db.refresh(current_user)
    
    # 返回更新后的用户信息
    user_dict = {
        "id": current_user.id,
        "phone": current_user.phone,
        "nickname": current_user.nickname,
        "avatar": current_user.avatar,
        "bio": current_user.bio,
        "tags": json.loads(current_user.tags) if current_user.tags else [],
        "hide_total_loss": current_user.hide_total_loss or 0,
        "hide_medals": current_user.hide_medals or 0,
    }
    return UserOut(**user_dict)


@router.post("/upload-avatar")
async def upload_avatar(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """上传用户头像"""
    # 验证文件类型
    if not file.content_type or not file.content_type.startswith('image/'):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="只能上传图片文件",
        )
    
    # 验证文件大小（限制为5MB）
    file_content = await file.read()
    if len(file_content) > 5 * 1024 * 1024:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="图片大小不能超过5MB",
        )
    
    # 创建上传目录（如果不存在）
    upload_dir = "uploads/avatars"
    os.makedirs(upload_dir, exist_ok=True)
    
    # 生成唯一文件名
    file_extension = file.filename.split('.')[-1] if '.' in file.filename else 'jpg'
    unique_filename = f"{current_user.id}_{uuid.uuid4().hex[:8]}.{file_extension}"
    file_path = os.path.join(upload_dir, unique_filename)
    
    # 保存文件
    with open(file_path, "wb") as f:
        f.write(file_content)
    
    # 生成URL（开发环境使用相对路径，生产环境应使用完整URL）
    avatar_url = f"/uploads/avatars/{unique_filename}"
    
    # 更新用户头像
    current_user.avatar = avatar_url
    db.commit()
    db.refresh(current_user)
    
    return JSONResponse(content={
        "avatar_url": avatar_url,
        "message": "头像上传成功"
    })

