from models.base import Base
from sqlalchemy import Column, String, Text, LargeBinary, DateTime, Boolean
from sqlalchemy.orm import relationship

class User(Base):
    __tablename__ = "users"

    id = Column(Text, primary_key=True, index=True)
    name = Column(String(100))
    email = Column(String(100), unique=True, index=True)
    password = Column(LargeBinary)
    avatar_url = Column(Text, nullable=True)
    reset_code_hash = Column(Text, nullable=True)
    reset_code_expires_at = Column(DateTime, nullable=True)
    is_verified = Column(Boolean, nullable=False, default=False)
    verification_code_hash = Column(Text, nullable=True)
    verification_code_expires_at = Column(DateTime, nullable=True)

    favorites = relationship('Favorite', back_populates='user')