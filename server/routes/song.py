import uuid

from fastapi import APIRouter, File, UploadFile, Form, Depends, HTTPException
from middleware.auth_middleware import auth_middleware
from sqlalchemy.orm import Session
from database import get_db
from models.song import Song
from config import (
    CLOUDINARY_API_KEY,
    CLOUDINARY_API_SECRET,
    CLOUDINARY_CLOUD_NAME,
)
import cloudinary
import cloudinary.uploader

router = APIRouter()
cloudinary.config( 
    cloud_name=CLOUDINARY_CLOUD_NAME,
    api_key=CLOUDINARY_API_KEY,
    api_secret=CLOUDINARY_API_SECRET,
    secure=True
)

@router.post('/upload', status_code=201)
def upload_song(song: UploadFile = File(...), 
                thumbnail: UploadFile = File(...),
                artist: str = Form(...), 
                song_name: str = Form(...),
                hex_code: str = Form(...),
                db: Session = Depends(get_db),
                auth_dict = Depends(auth_middleware)):
    song_id = str(uuid.uuid4())
    folder = f'songs/{song_id}'

    try:
        song_res = cloudinary.uploader.upload(
            song.file,
            resource_type='video',
            folder=folder,
        )
        thumbnail_res = cloudinary.uploader.upload(
            thumbnail.file,
            resource_type='image',
            folder=folder,
        )

    except Exception as exc:
        raise HTTPException(status_code=502, detail='Could not upload files to Cloudinary') from exc

    song_db = Song(
        id=song_id,
        song_name=song_name,
        artist=artist,
        hex_code=hex_code,
        song_url=song_res['secure_url'],
        thumbnail_url=thumbnail_res['secure_url'],
        owner_id=auth_dict['uid'],
    )

    try:
        db.add(song_db)
        db.commit()
        db.refresh(song_db)
    except Exception as exc:
        db.rollback()
        raise HTTPException(status_code=500, detail='Could not save song in database') from exc

    return {
        'id': song_db.id,
        'song_url': song_db.song_url,
        'thumbnail_url': song_db.thumbnail_url,
        'artist': song_db.artist,
        'song_name': song_db.song_name,
        'hex_code': song_db.hex_code,
        'owner_id': song_db.owner_id,
    }
