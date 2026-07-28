from pydantic import BaseModel


class PlaylistAddSong(BaseModel):
    song_id: str