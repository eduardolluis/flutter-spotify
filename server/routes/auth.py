import uuid
import jwt
import bcrypt
import requests
import secrets
from datetime import datetime, timedelta, timezone
from pydantic import BaseModel
from config import JWT_SECRET, GOOGLE_WEB_CLIENT_ID
from middleware.auth_middleware import auth_middleware      
from fastapi import Depends, HTTPException, APIRouter, Header, BackgroundTasks
from sqlalchemy.orm import Session, joinedload
from models.user import User
from pydantic_schemas.user_create import UserCreate
from pydantic_schemas.user_login import UserLogin
from pydantic_schemas.forgot_password import ForgotPassword
from pydantic_schemas.reset_password import ResetPassword
from pydantic_schemas.verify_email import VerifyEmail
from database import get_db
from utils.mailer import send_reset_code_email, send_verification_code_email

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
        'is_verified': bool(user_db.is_verified),
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


def _safe_send_verification_code(user_db: User, db: Session) -> None:
    """Wrapper used from BackgroundTasks: runs after the response is
    already sent, so it must never raise (nothing left to catch it)."""
    try:
        _issue_and_send_verification_code(user_db, db)
    except Exception as e:
        print("WARNING: couldn't send verification email on signup:", str(e))


@router.post("/signup", status_code=201)
def signup_user(user: UserCreate, background_tasks: BackgroundTasks, db: Session = Depends(get_db)):
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

    # Best-effort: send the verification code in the background so the
    # signup response doesn't wait on the mail server. Previously this was
    # a synchronous call wrapped in try/except, which "caught" failures but
    # NOT slowness — a slow/unreachable SMTP connection (e.g. Gmail
    # unreachable from the host) would still make the whole request hang
    # until it finally timed out. Running it as a background task means
    # the client gets its token/user back immediately regardless.
    background_tasks.add_task(_safe_send_verification_code, user_db, db)

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
                is_verified=True,  # Google already verified this email for us
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


RESET_CODE_TTL_MINUTES = 15


@router.post('/forgot-password')
def forgot_password(data: ForgotPassword, db: Session = Depends(get_db)):
    generic_response = {
        'message': "If an account exists for that email, we've sent a reset code."
    }

    user_db = db.query(User).filter(User.email == data.email).first()
    if not user_db:
        # Don't reveal whether the email exists.
        return generic_response

    code = f"{secrets.randbelow(1_000_000):06d}"
    code_hash = bcrypt.hashpw(code.encode('utf-8'), bcrypt.gensalt())

    user_db.reset_code_hash = code_hash.decode('utf-8')
    user_db.reset_code_expires_at = datetime.now(timezone.utc) + timedelta(
        minutes=RESET_CODE_TTL_MINUTES
    )
    db.commit()

    try:
        send_reset_code_email(user_db.email, code)
    except Exception as e:
        # Roll back the issued code if we couldn't actually send it, so a
        # broken mail config doesn't leave a dangling valid code.
        user_db.reset_code_hash = None
        user_db.reset_code_expires_at = None
        db.commit()
        raise HTTPException(status_code=500, detail=f"Couldn't send reset email: {e}")

    return generic_response


@router.post('/reset-password')
def reset_password(data: ResetPassword, db: Session = Depends(get_db)):
    invalid_error = HTTPException(status_code=400, detail='Invalid or expired code')

    user_db = db.query(User).filter(User.email == data.email).first()
    if not user_db or not user_db.reset_code_hash or not user_db.reset_code_expires_at:
        raise invalid_error

    expires_at = user_db.reset_code_expires_at
    if expires_at.tzinfo is None:
        expires_at = expires_at.replace(tzinfo=timezone.utc)
    if datetime.now(timezone.utc) > expires_at:
        raise invalid_error

    if not bcrypt.checkpw(data.code.encode('utf-8'), user_db.reset_code_hash.encode('utf-8')):
        raise invalid_error

    _validate_password_strength(data.new_password)

    user_db.password = bcrypt.hashpw(data.new_password.encode('utf-8'), bcrypt.gensalt())
    user_db.reset_code_hash = None
    user_db.reset_code_expires_at = None
    db.commit()

    token = jwt.encode({'id': user_db.id}, JWT_SECRET, algorithm='HS256')
    return {'token': token, 'user': _serialize_user(user_db)}


VERIFICATION_CODE_TTL_MINUTES = 15


def _issue_and_send_verification_code(user_db: User, db: Session) -> None:
    """Generates a fresh 6-digit code, stores its hash on the user, and
    emails it. Raises if sending fails; caller decides how to handle that."""
    code = f"{secrets.randbelow(1_000_000):06d}"
    code_hash = bcrypt.hashpw(code.encode('utf-8'), bcrypt.gensalt())

    user_db.verification_code_hash = code_hash.decode('utf-8')
    user_db.verification_code_expires_at = datetime.now(timezone.utc) + timedelta(
        minutes=VERIFICATION_CODE_TTL_MINUTES
    )
    db.commit()

    send_verification_code_email(user_db.email, code)


@router.post('/send-verification-code')
def send_verification_code(db: Session = Depends(get_db),
                            user_dict=Depends(auth_middleware)):
    user_db = db.query(User).filter(User.id == user_dict['uid']).first()
    if not user_db:
        raise HTTPException(404, 'User not found!')

    if user_db.is_verified:
        return {'message': 'Email is already verified'}

    try:
        _issue_and_send_verification_code(user_db, db)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Couldn't send verification email: {e}")

    return {'message': 'Verification code sent'}


@router.post('/verify-email')
def verify_email(data: VerifyEmail, db: Session = Depends(get_db),
                  user_dict=Depends(auth_middleware)):
    invalid_error = HTTPException(status_code=400, detail='Invalid or expired code')

    user_db = db.query(User).filter(User.id == user_dict['uid']).first()
    if not user_db:
        raise HTTPException(404, 'User not found!')

    if user_db.is_verified:
        return {'user': _serialize_user(user_db)}

    if not user_db.verification_code_hash or not user_db.verification_code_expires_at:
        raise invalid_error

    expires_at = user_db.verification_code_expires_at
    if expires_at.tzinfo is None:
        expires_at = expires_at.replace(tzinfo=timezone.utc)
    if datetime.now(timezone.utc) > expires_at:
        raise invalid_error

    if not bcrypt.checkpw(
        data.code.encode('utf-8'), user_db.verification_code_hash.encode('utf-8')
    ):
        raise invalid_error

    user_db.is_verified = True
    user_db.verification_code_hash = None
    user_db.verification_code_expires_at = None
    db.commit()

    return {'user': _serialize_user(user_db)}