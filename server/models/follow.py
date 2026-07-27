from models.base import Base
from sqlalchemy import Column, TEXT, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship


class Follow(Base):
    __tablename__ = 'follows'

    id = Column(TEXT, primary_key=True)
    # el usuario que sigue
    follower_id = Column(TEXT, ForeignKey("users.id"))
    # el usuario (artista) que es seguido
    followed_id = Column(TEXT, ForeignKey("users.id"))

    follower = relationship('User', foreign_keys=[follower_id])
    followed = relationship('User', foreign_keys=[followed_id])

    __table_args__ = (
        UniqueConstraint('follower_id', 'followed_id', name='uq_follower_followed'),
    )