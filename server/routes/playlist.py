import uuid

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload

from database import get_db
from models.playlist import Playlist, PlaylistSong
from models.song import Song
from middleware.auth_middleware import auth_middleware
from pydantic_schemas.playlist_create import PlaylistCreate
from pydantic_schemas.playlist_add_song import PlaylistAddSong

router = APIRouter()


def _serialize_song(song: Song):
    return {
        'id': song.id,
        'song_url': song.song_url,
        'thumbnail_url': song.thumbnail_url,
        'artist': song.artist,
        'song_name': song.song_name,
        'hex_code': song.hex_code,
        'genre': song.genre,
        'owner_id': song.owner_id,
    }


def _serialize_playlist(playlist: Playlist, db: Session, include_songs: bool = False):
    entries = (
        db.query(PlaylistSong)
        .options(joinedload(PlaylistSong.song))
        .filter(PlaylistSong.playlist_id == playlist.id)
        .all()
    )
    songs = [entry.song for entry in entries if entry.song is not None]

    data = {
        'id': playlist.id,
        'name': playlist.name,
        'owner_id': playlist.owner_id,
        'song_count': len(songs),
        'cover_thumbnail_url': songs[0].thumbnail_url if songs else None,
    }
    if include_songs:
        data['songs'] = [_serialize_song(song) for song in songs]
    return data


def _get_owned_playlist(playlist_id: str, db: Session, uid: str) -> Playlist:
    playlist = db.query(Playlist).filter(Playlist.id == playlist_id).first()
    if not playlist:
        raise HTTPException(404, 'Playlist not found')
    if playlist.owner_id != uid:
        raise HTTPException(403, "You don't have access to this playlist")
    return playlist


@router.post('/', status_code=201)
def create_playlist(
    payload: PlaylistCreate,
    db: Session = Depends(get_db),
    auth_details=Depends(auth_middleware),
):
    name = payload.name.strip()
    if not name:
        raise HTTPException(400, 'Playlist name cannot be empty')

    playlist = Playlist(id=str(uuid.uuid4()), name=name, owner_id=auth_details['uid'])
    db.add(playlist)
    db.commit()
    db.refresh(playlist)

    return _serialize_playlist(playlist, db, include_songs=True)


@router.get('/')
def list_playlists(
    db: Session = Depends(get_db),
    auth_details=Depends(auth_middleware),
):
    playlists = db.query(Playlist).filter(Playlist.owner_id == auth_details['uid']).all()
    return [_serialize_playlist(playlist, db) for playlist in playlists]


@router.get('/{playlist_id}')
def get_playlist(
    playlist_id: str,
    db: Session = Depends(get_db),
    auth_details=Depends(auth_middleware),
):
    playlist = _get_owned_playlist(playlist_id, db, auth_details['uid'])
    return _serialize_playlist(playlist, db, include_songs=True)


@router.post('/{playlist_id}/songs')
def add_song_to_playlist(
    playlist_id: str,
    payload: PlaylistAddSong,
    db: Session = Depends(get_db),
    auth_details=Depends(auth_middleware),
):
    playlist = _get_owned_playlist(playlist_id, db, auth_details['uid'])

    song = db.query(Song).filter(Song.id == payload.song_id).first()
    if not song:
        raise HTTPException(404, 'Song not found')

    existing = (
        db.query(PlaylistSong)
        .filter(
            PlaylistSong.playlist_id == playlist_id,
            PlaylistSong.song_id == payload.song_id,
        )
        .first()
    )
    if not existing:
        db.add(PlaylistSong(id=str(uuid.uuid4()), playlist_id=playlist_id, song_id=payload.song_id))
        db.commit()

    return _serialize_playlist(playlist, db, include_songs=True)


@router.delete('/{playlist_id}/songs/{song_id}')
def remove_song_from_playlist(
    playlist_id: str,
    song_id: str,
    db: Session = Depends(get_db),
    auth_details=Depends(auth_middleware),
):
    playlist = _get_owned_playlist(playlist_id, db, auth_details['uid'])

    db.query(PlaylistSong).filter(
        PlaylistSong.playlist_id == playlist_id,
        PlaylistSong.song_id == song_id,
    ).delete()
    db.commit()

    return _serialize_playlist(playlist, db, include_songs=True)


@router.delete('/{playlist_id}')
def delete_playlist(
    playlist_id: str,
    db: Session = Depends(get_db),
    auth_details=Depends(auth_middleware),
):
    playlist = _get_owned_playlist(playlist_id, db, auth_details['uid'])

    db.query(PlaylistSong).filter(PlaylistSong.playlist_id == playlist_id).delete()
    db.delete(playlist)
    db.commit()

    return {'message': 'Playlist deleted successfully'}