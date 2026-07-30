import uuid
import jwt
import bcrypt
import requests
from datetime import datetime, timezone
from pydantic import BaseModel
from config import JWT_SECRET, GOOGLE_WEB_CLIENT_ID
from middleware.auth_middleware import auth_middleware      
from fastapi import Depends, HTTPException, APIRouter, Header
from sqlalchemy.orm import Session, joinedload
from models.user import User
from pydantic_schemas.user_create import UserCreate
from pydantic_schemas.user_login import UserLogin
from database import get_db

router = APIRouter()

class GoogleAuthSchema(BaseModel):
    id_token: str


def _serialize_user(user_db: User) -> dict:
    """Never serialize the raw ORM object: it carries the bcrypt password
    hash and returning it as-is leaks that hash to the client."""
    return {
        'id': user_db.id,
        'name': user_db.name,
        'email': user_db.email,
        'avatar_url': user_db.avatar_url,
        'favorites': [
            {'id': f.id, 'song_id': f.song_id, 'user_id': f.user_id}
            for f in (user_db.favorites or [])
        ],
    }


def _validate_password_strength(password: str) -> None:
    """Mirrors the client-side rule in AuthTextField(isNewPassword: true).
    The client check is just UX — this is the real gate, since a request
    can always skip the app and hit the API directly."""
    if len(password) < 8:
        raise HTTPException(status_code=400, detail='Password must be at least 8 characters')
    if not any(c.isupper() for c in password):
        raise HTTPException(status_code=400, detail='Password must include an uppercase letter')
    if not any(c.islower() for c in password):
        raise HTTPException(status_code=400, detail='Password must include a lowercase letter')
    if not any(c.isdigit() for c in password):
        raise HTTPException(status_code=400, detail='Password must include a number')


@router.post("/signup", status_code=201)
def signup_user(user: UserCreate, db: Session = Depends(get_db)):
    # check if the user already exists in the db
    user_db = db.query(User).filter(User.email == user.email).first()

    if user_db:
        raise HTTPException(status_code=400, detail="User with the same email already exists!")

    _validate_password_strength(user.password)

    hashpw = bcrypt.hashpw(user.password.encode("utf-8"), bcrypt.gensalt())

    user_db = User(id=str(uuid.uuid4()), email=user.email, name=user.name, password=hashpw)

    # add user to the db
    db.add(user_db)
    db.commit()
    db.refresh(user_db)

    token = jwt.encode({'id': user_db.id}, JWT_SECRET, algorithm='HS256')

    return {'token': token, 'user': _serialize_user(user_db)}


@router.post("/login")
def login_user(user: UserLogin, db: Session = Depends(get_db)):
    # check if a user with same email exists in the db
    user_db = db.query(User).filter(User.email == user.email).first()

    if not user_db:
        raise HTTPException(status_code=400, detail="User with this email does not exist!")

    # password matching or not
    is_match = bcrypt.checkpw(user.password.encode("utf-8"), user_db.password)
    if not is_match:
        raise HTTPException(status_code=400, detail="Incorrect password!")
    
    token = jwt.encode({'id': user_db.id}, JWT_SECRET, algorithm='HS256')

    return {'token': token, 'user': _serialize_user(user_db)}


@router.post('/google-mobile')
def google_auth_mobile(data: GoogleAuthSchema, db: Session = Depends(get_db)):
    try:
        google_res = requests.get(
            f"https://oauth2.googleapis.com/tokeninfo?id_token={data.id_token}"
        )

        if google_res.status_code != 200:
            raise HTTPException(status_code=400, detail="Google Token Invalid")

        google_data = google_res.json()

        print("DEBUG -> AUD que llega de Google:", google_data.get("aud"))
        print("DEBUG -> AUD esperado en servidor:", GOOGLE_WEB_CLIENT_ID)

        if google_data.get("aud") != GOOGLE_WEB_CLIENT_ID:
            raise HTTPException(status_code=401, detail="Google Token does not belong to this app")

        email = google_data.get("email")
        name = google_data.get("name", "Google User")

        if not email:
            raise HTTPException(status_code=400, detail="Email not found in Google token data")

        user_db = db.query(User).filter(User.email == email).first()

        if not user_db:
            random_pw = bcrypt.hashpw(str(uuid.uuid4()).encode("utf-8"), bcrypt.gensalt())
            user_db = User(
                id=str(uuid.uuid4()),
                email=email,
                name=name,
                password=random_pw,
            )
            db.add(user_db)
            db.commit()
            db.refresh(user_db)

        token = jwt.encode({'id': user_db.id}, JWT_SECRET, algorithm='HS256')

        return {'token': token, 'user': _serialize_user(user_db)}

    except Exception as e:
        print("ERROR DETALLADO EN GOOGLE AUTH EXCEPTION:", str(e))
        raise HTTPException(status_code=400, detail=str(e))


@router.get('/')
def current_user_data(db: Session = Depends(get_db),
                      user_dict = Depends(auth_middleware)):
   user = db.query(User).filter(User.id == user_dict['uid']).options(
       joinedload(User.favorites),
   ).first()

   if not user:
       raise HTTPException(404, 'User not found!')

   return _serialize_user(user)