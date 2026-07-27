import os
from fastapi import APIRouter, UploadFile, File, Depends, HTTPException
from sqlalchemy.orm import Session
from database import get_db
from models.user import User
from middleware.auth_middleware import auth_middleware

router = APIRouter()

UPLOAD_DIR = "uploads/avatars"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@router.post("/avatar")
async def upload_avatar(
    avatar: UploadFile = File(...),
    db: Session = Depends(get_db),
    user_dict = Depends(auth_middleware)
):
    user = db.query(User).filter(User.id == user_dict['uid']).first()
    if not user:
        raise HTTPException(404, 'User not found!')

    file_path = f"{UPLOAD_DIR}/{user.id}.jpg"
    contents = await avatar.read()
    with open(file_path, "wb") as f:
        f.write(contents)

    user.avatar_url = file_path
    db.commit()
    db.refresh(user)

    return user