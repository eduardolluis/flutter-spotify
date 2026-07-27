from fastapi import FastAPI
from database import engine
from models.base import Base
from routes import auth, song

from routes.user import router as user_router

app = FastAPI()

app.include_router(auth.router, prefix='/auth')
app.include_router(song.router, prefix='/song')
app.include_router(user_router, prefix='/user')

Base.metadata.create_all(bind=engine)