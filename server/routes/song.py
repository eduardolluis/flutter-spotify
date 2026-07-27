import uuid

from fastapi import APIRouter, File, UploadFile, Form, Depends, HTTPException
from middleware.auth_middleware import auth_middleware
from models.favorite import Favorite
from pydantic_schemas.favorite_song import FavoriteSong
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
from sqlalchemy.orm import joinedload

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
        # Log the real error server-side so we can see exactly why Cloudinary
        # rejected the upload (bad credentials, quota, file too large, etc.)
        # instead of hiding it behind a generic message.
        print(f"[Cloudinary upload error] {type(exc).__name__}: {exc}")
        raise HTTPException(status_code=502, detail=f'Could not upload files to Cloudinary: {exc}') from exc

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

@router.get('/list')
def list_songs(db: Session = Depends(get_db), 
               auth_details = Depends(auth_middleware)):
    songs = db.query(Song).options(joinedload(Song.owner)).all()
    return [
        {
            'id': song.id,
            'song_name': song.song_name,
            'artist': song.artist,
            'thumbnail_url': song.thumbnail_url,
            'song_url': song.song_url,
            'hex_code': song.hex_code,
            'owner_id': song.owner_id,
            'owner_avatar_url': song.owner.avatar_url if song.owner else None,
        }
        for song in songs
    ]

@router.delete('/{song_id}')
def delete_song(song_id: str,
                db: Session = Depends(get_db),
                auth_details = Depends(auth_middleware)):
    song_db = db.query(Song).filter(Song.id == song_id).first()

    if not song_db:
        raise HTTPException(status_code=404, detail='Song not found')

    # Solo el usuario que subió la canción puede eliminarla.
    if song_db.owner_id != auth_details['uid']:
        raise HTTPException(
            status_code=403,
            detail='Only the user who uploaded this song can delete it'
        )

    # Borramos primero los favoritos que apunten a esta canción para no
    # dejar registros huérfanos / violar la foreign key.
    db.query(Favorite).filter(Favorite.song_id == song_id).delete()
    db.delete(song_db)
    db.commit()

    return {"message": "Song deleted successfully."}

@router.post('/favorite')
def favorite_song( song: FavoriteSong,
                  db: Session = Depends(get_db),  
                  auth_details = Depends(auth_middleware)):
    #song is already favorited by the user
    user_id = auth_details['uid']

    fav_song = db.query(Favorite).filter(Favorite.song_id == song.song_id, Favorite.user_id == user_id).first()

    #if song is already favorited, unfavorite the song
    if fav_song:
        db.delete(fav_song)
        db.commit()
        return {"message": "Song unfavorited successfully.", "is_favorite": False}
    #if song isn't favorited, favorite the song
    else: 
        new_fav = Favorite(id=str(uuid.uuid4()), song_id=song.song_id, user_id=user_id)
        db.add(new_fav)
        db.commit()
        return {"message": "Song favorited successfully.", "is_favorite": True}

@router.get('/list/favorites')
def list_fav_songs(db: Session = Depends(get_db), 
               auth_details = Depends(auth_middleware)):
    
    user_id = auth_details['uid']
    fav_songs = db.query(Favorite).filter(Favorite.user_id == user_id).options(
        joinedload(Favorite.song),
        joinedload(Favorite.user)
    ).all()

    # Always return a JSON array (never null), so the client can safely
    # cast it to a List even when the user has zero favorites.
    return [fav.song for fav in fav_songs if fav.song is not None]