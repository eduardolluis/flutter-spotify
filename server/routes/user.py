from fastapi import APIRouter, UploadFile, File, Depends, HTTPException
from sqlalchemy.orm import Session
import cloudinary.uploader
import config 
from database import get_db
from models.user import User
from middleware.auth_middleware import auth_middleware

router = APIRouter()

@router.post("/avatar")
async def upload_avatar(
    avatar: UploadFile = File(...),
    db: Session = Depends(get_db),
    user_dict = Depends(auth_middleware)
):
    user = db.query(User).filter(User.id == user_dict['uid']).first()
    if not user:
        raise HTTPException(404, 'User not found!')

    contents = await avatar.read()

    result = cloudinary.uploader.upload(
        contents,
        folder="avatars",
        public_id=user.id,
        overwrite=True
    )

    user.avatar_url = result["secure_url"]
    db.commit()
    db.refresh(user)

    return user