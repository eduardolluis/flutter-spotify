from fastapi import APIRouter, UploadFile, File, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload
import uuid
import cloudinary.uploader
import config 
from database import get_db
from models.user import User
from models.song import Song
from models.follow import Follow
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


@router.get('/{artist_id}')
def get_artist_profile(
    artist_id: str,
    db: Session = Depends(get_db),
    auth_details = Depends(auth_middleware)
):
    artist = db.query(User).filter(User.id == artist_id).first()
    if not artist:
        raise HTTPException(status_code=404, detail='Artist not found')

    uid = auth_details['uid']

    followers_count = db.query(Follow).filter(Follow.followed_id == artist_id).count()
    following_count = db.query(Follow).filter(Follow.follower_id == artist_id).count()
    is_following = db.query(Follow).filter(
        Follow.follower_id == uid,
        Follow.followed_id == artist_id
    ).first() is not None

    songs = (
        db.query(Song)
        .options(joinedload(Song.owner))
        .filter(Song.owner_id == artist_id)
        .all()
    )

    return {
        'id': artist.id,
        'name': artist.name,
        'avatar_url': artist.avatar_url,
        'followers_count': followers_count,
        'following_count': following_count,
        'is_following': is_following,
        'songs': [
            {
                'id': song.id,
                'song_url': song.song_url,
                'thumbnail_url': song.thumbnail_url,
                'artist': song.artist,
                'song_name': song.song_name,
                'hex_code': song.hex_code,
                'owner_id': song.owner_id,
                'artist_avatar_url': song.owner.avatar_url if song.owner else None,
            }
            for song in songs
        ],
    }


@router.post('/{artist_id}/follow')
def follow_artist(
    artist_id: str,
    db: Session = Depends(get_db),
    auth_details = Depends(auth_middleware)
):
    uid = auth_details['uid']

    if uid == artist_id:
        raise HTTPException(status_code=400, detail="You can't follow yourself")

    artist = db.query(User).filter(User.id == artist_id).first()
    if not artist:
        raise HTTPException(status_code=404, detail='Artist not found')

    existing = db.query(Follow).filter(
        Follow.follower_id == uid,
        Follow.followed_id == artist_id
    ).first()

    if existing:
        db.delete(existing)
        db.commit()
        is_following = False
    else:
        db.add(Follow(id=str(uuid.uuid4()), follower_id=uid, followed_id=artist_id))
        db.commit()
        is_following = True

    followers_count = db.query(Follow).filter(Follow.followed_id == artist_id).count()

    return {
        'message': 'Followed successfully' if is_following else 'Unfollowed successfully',
        'is_following': is_following,
        'followers_count': followers_count,
    }