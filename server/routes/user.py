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
from routes.auth import _serialize_user
from pydantic_schemas.user_update import UserUpdate

router = APIRouter()

@router.post("/avatar")
async def upload_avatar(
    avatar: UploadFile = File(...),
    db: Session = Depends(get_db),
    user_dict = Depends(auth_middleware)
):
    user = db.query(User).options(joinedload(User.favorites)).filter(User.id == user_dict['uid']).first()
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

    return _serialize_user(user)


@router.put("/")
def update_profile(
    payload: UserUpdate,
    db: Session = Depends(get_db),
    user_dict = Depends(auth_middleware)
):
    user = db.query(User).options(joinedload(User.favorites)).filter(User.id == user_dict['uid']).first()
    if not user:
        raise HTTPException(404, 'User not found!')

    if payload.name is not None:
        name = payload.name.strip()
        if not name:
            raise HTTPException(400, 'Name cannot be empty')
        user.name = name

    if payload.email is not None:
        email = payload.email.strip().lower()
        if not email:
            raise HTTPException(400, 'Email cannot be empty')

        existing = db.query(User).filter(User.email == email, User.id != user.id).first()
        if existing:
            raise HTTPException(400, 'That email is already in use')

        user.email = email

    db.commit()
    db.refresh(user)

    return _serialize_user(user)


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
                'genre': song.genre,
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


def _serialize_user_list(users, db: Session, viewer_id: str):
    """Shared shape for followers/following list items, including whether
    the requesting user already follows each person in the list."""
    if not users:
        return []

    user_ids = [u.id for u in users]
    following_ids = {
        row.followed_id
        for row in db.query(Follow.followed_id).filter(
            Follow.follower_id == viewer_id,
            Follow.followed_id.in_(user_ids),
        )
    }

    return [
        {
            'id': user.id,
            'name': user.name,
            'avatar_url': user.avatar_url,
            'is_following': user.id in following_ids,
            'is_self': user.id == viewer_id,
        }
        for user in users
    ]


@router.get('/{artist_id}/followers')
def get_followers(
    artist_id: str,
    db: Session = Depends(get_db),
    auth_details = Depends(auth_middleware)
):
    artist = db.query(User).filter(User.id == artist_id).first()
    if not artist:
        raise HTTPException(status_code=404, detail='Artist not found')

    followers = (
        db.query(User)
        .join(Follow, Follow.follower_id == User.id)
        .filter(Follow.followed_id == artist_id)
        .all()
    )

    return _serialize_user_list(followers, db, auth_details['uid'])


@router.get('/{artist_id}/following')
def get_following(
    artist_id: str,
    db: Session = Depends(get_db),
    auth_details = Depends(auth_middleware)
):
    artist = db.query(User).filter(User.id == artist_id).first()
    if not artist:
        raise HTTPException(status_code=404, detail='Artist not found')

    following = (
        db.query(User)
        .join(Follow, Follow.followed_id == User.id)
        .filter(Follow.follower_id == artist_id)
        .all()
    )

    return _serialize_user_list(following, db, auth_details['uid'])