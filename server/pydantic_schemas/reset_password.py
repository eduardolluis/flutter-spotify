from pydantic import BaseModel

class ResetPassword(BaseModel):
    email: str
    code: str
    new_password: str