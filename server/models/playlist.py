from models.base import Base
from sqlalchemy import Column, TEXT, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship


class Playlist(Base):
    __tablename__ = 'playlists'

    id = Column(TEXT, primary_key=True)
    name = Column(TEXT, nullable=False)
    owner_id = Column(TEXT, ForeignKey('users.id'))

    owner = relationship('User')


class PlaylistSong(Base):
    __tablename__ = 'playlist_songs'

    id = Column(TEXT, primary_key=True)
    playlist_id = Column(TEXT, ForeignKey('playlists.id'))
    song_id = Column(TEXT, ForeignKey('songs.id'))

    playlist = relationship('Playlist')
    song = relationship('Song')

    __table_args__ = (
        UniqueConstraint('playlist_id', 'song_id', name='uq_playlist_song'),
    )