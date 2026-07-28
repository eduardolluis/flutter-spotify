from pydantic import BaseModel


class PlaylistCreate(BaseModel):
    name: str