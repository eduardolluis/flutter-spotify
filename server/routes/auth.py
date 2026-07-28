import uuid
import jwt
import bcrypt
import requests  # Para validar el token con los servidores de Google
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

# Esquema para recibir el id_token enviado desde Flutter
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


@router.post("/signup", status_code=201)
def signup_user(user: UserCreate, db: Session = Depends(get_db)):
    # check if the user already exists in the db
    user_db = db.query(User).filter(User.email == user.email).first()

    if user_db:
        raise HTTPException(status_code=400, detail="User with the same email already exists!")

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

        # Validar el id_token directamente con la API de Google
        google_res = requests.get(
            f"https://oauth2.googleapis.com/tokeninfo?id_token={data.id_token}"
        )

        if google_res.status_code != 200:
            raise HTTPException(status_code=400, detail="Token de Google inválido")

        google_data = google_res.json()

        # CRITICAL: tokeninfo only proves the token is a *valid Google* token —
        # it doesn't prove it was issued for *this* app. Without checking `aud`,
        # a valid Google id_token from any other app would also be accepted here.
        if google_data.get("aud") != GOOGLE_WEB_CLIENT_ID:
            raise HTTPException(status_code=401, detail="Token de Google no pertenece a esta app")

        email = google_data.get("email")
        name = google_data.get("name", "Usuario de Google")

        if not email:
            raise HTTPException(status_code=400, detail="No se pudo obtener el correo de Google")

        # 2. Verificar si el usuario ya existe en tu DB
        user_db = db.query(User).filter(User.email == email).first()

        # 3. Si no existe, creamos la cuenta automáticamente
        if not user_db:
            # Generamos un hash aleatorio ya que este usuario inicia sesión con Google
            random_pw = bcrypt.hashpw(str(uuid.uuid4()).encode("utf-8"), bcrypt.gensalt())
            user_db = User(
                id=str(uuid.uuid4()),
                email=email,
                name=name,
                password=random_pw
            )
            db.add(user_db)
            db.commit()
            db.refresh(user_db)

        # 4. Generar tu propio token JWT
        token = jwt.encode({'id': user_db.id}, JWT_SECRET, algorithm='HS256')

        return {'token': token, 'user': _serialize_user(user_db)}

    except Exception as e:
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
