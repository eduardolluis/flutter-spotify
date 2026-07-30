from pydantic import BaseModel

class ForgotPassword(BaseModel):
    email: str