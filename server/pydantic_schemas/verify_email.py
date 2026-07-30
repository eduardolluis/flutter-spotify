from pydantic import BaseModel

class VerifyEmail(BaseModel):
    code: str