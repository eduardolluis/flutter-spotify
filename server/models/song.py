from sqlalchemy import Column, ForeignKey, String, Text
from sqlalchemy.orm import relationship
from models.base import Base


class Song(Base):
    __tablename__ = 'songs'

    id = Column(Text, primary_key=True, index=True)
    song_url = Column(Text, nullable=False)
    thumbnail_url = Column(Text, nullable=False)
    artist = Column(String(200), nullable=False)
    song_name = Column(String(200), nullable=False)
    hex_code = Column(String(7), nullable=False)
    owner_id = Column(Text, ForeignKey("users.id"))

    owner = relationship('User')