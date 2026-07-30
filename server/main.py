from fastapi import FastAPI
from sqlalchemy import inspect, text
from database import engine
from models.base import Base
from routes import auth, song

from routes.user import router as user_router
from routes.playlist import router as playlist_router

app = FastAPI()

app.include_router(auth.router, prefix='/auth')
app.include_router(song.router, prefix='/song')
app.include_router(user_router, prefix='/user')
app.include_router(playlist_router, prefix='/playlist')

Base.metadata.create_all(bind=engine)


def _run_lightweight_migrations():
    """`create_all` only creates missing tables, it never alters existing
    ones. The `genre` column was added to an already-deployed `songs`
    table, so add it here if it isn't there yet (safe/idempotent)."""
    inspector = inspect(engine)
    if 'songs' in inspector.get_table_names():
        existing_song_columns = {col['name'] for col in inspector.get_columns('songs')}
        if 'genre' not in existing_song_columns:
            with engine.begin() as connection:
                connection.execute(text('ALTER TABLE songs ADD COLUMN genre VARCHAR(50)'))


_run_lightweight_migrations()