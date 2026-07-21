from models.base import BaseModel
from sqlalchemy import Column, TEXT, ForeignKey
from sqlalchemy.orm import relationship

class Favorite(BaseModel):
    __tablename__ = 'favorites'

    id = Column(TEXT, primary_key=True)
    song_id = Column(TEXT, ForeignKey("songs.id"))
    user_id = Column(TEXT, ForeignKey("users.id"))    

    song = relationship('Song')
    user = relationship('User', back_populates='favorites')