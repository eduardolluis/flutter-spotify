from models.base import Base
from sqlalchemy import Column, String, Text, LargeBinary
from sqlalchemy.orm import relationship

class User(Base):
    __tablename__ = "users"

    id = Column(Text, primary_key=True, index=True)
    name = Column(String(100))
    email = Column(String(100), unique=True, index=True)
    password = Column(LargeBinary)
    avatar_url = Column(Text, nullable=True)  

    favorites = relationship('Favorite', back_populates='user')