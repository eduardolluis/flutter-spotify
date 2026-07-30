from config import JWT_SECRET
from fastapi import Header, HTTPException
import jwt


def auth_middleware(x_auth_token=Header()):
  try:
    # get the user token from the headers
    if not x_auth_token:
      raise HTTPException(
          status_code=401, detail='No auth token, access denied :('
      )

    # decode the token
    verified_token = jwt.decode(
        x_auth_token, JWT_SECRET, algorithms=['HS256']
    )
    if not verified_token:
      raise HTTPException(
          status_code=401,
          detail='Token verification failed, authorization denied :(',
      )

    # get the id from the token
    uid = verified_token.get('id')
    return {'uid': uid, 'token': x_auth_token}
  except jwt.PyJWTError:
    raise HTTPException(
        status_code=401, detail='Token is not valid, authorization failed :('
    )