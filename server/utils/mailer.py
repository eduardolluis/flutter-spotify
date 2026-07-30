import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

from config import GMAIL_ADDRESS, GMAIL_APP_PASSWORD

GMAIL_SMTP_HOST = "smtp.gmail.com"
GMAIL_SMTP_PORT = 465


def send_reset_code_email(to_email: str, code: str) -> None:
    """Send the password reset code to `to_email` using Gmail SMTP.

    Requires GMAIL_ADDRESS and GMAIL_APP_PASSWORD env vars. The app
    password is a 16-character code you generate at
    https://myaccount.google.com/apppasswords (needs 2-Step Verification
    enabled on the Gmail account) — it is NOT your normal Gmail password.
    """
    if not GMAIL_ADDRESS or not GMAIL_APP_PASSWORD:
        raise RuntimeError(
            "GMAIL_ADDRESS and GMAIL_APP_PASSWORD must be set in the server "
            "environment to send password reset emails."
        )

    message = MIMEMultipart("alternative")
    message["Subject"] = "Your Melodix password reset code"
    message["From"] = GMAIL_ADDRESS
    message["To"] = to_email

    text_body = (
        f"Your Melodix password reset code is: {code}\n\n"
        "This code expires in 15 minutes. If you didn't request this, "
        "you can safely ignore this email."
    )
    html_body = f"""
    <div style="font-family: sans-serif; max-width: 420px; margin: 0 auto;">
      <h2 style="color: #1a1a1a;">Reset your Melodix password</h2>
      <p>Use this code to reset your password. It expires in 15 minutes.</p>
      <p style="font-size: 32px; font-weight: 700; letter-spacing: 6px;
                background: #f2f2f2; padding: 16px 20px; border-radius: 10px;
                text-align: center;">{code}</p>
      <p style="color: #666; font-size: 13px;">
        If you didn't request this, you can safely ignore this email.
      </p>
    </div>
    """

    message.attach(MIMEText(text_body, "plain"))
    message.attach(MIMEText(html_body, "html"))

    with smtplib.SMTP_SSL(GMAIL_SMTP_HOST, GMAIL_SMTP_PORT) as server:
        server.login(GMAIL_ADDRESS, GMAIL_APP_PASSWORD)
        server.sendmail(GMAIL_ADDRESS, to_email, message.as_string())


def send_verification_code_email(to_email: str, code: str) -> None:
    """Send an email-ownership verification code to `to_email`, sent right
    after signup (and again on demand from the "verify email" screen)."""
    if not GMAIL_ADDRESS or not GMAIL_APP_PASSWORD:
        raise RuntimeError(
            "GMAIL_ADDRESS and GMAIL_APP_PASSWORD must be set in the server "
            "environment to send verification emails."
        )

    message = MIMEMultipart("alternative")
    message["Subject"] = "Verify your Melodix email"
    message["From"] = GMAIL_ADDRESS
    message["To"] = to_email

    text_body = (
        f"Your Melodix verification code is: {code}\n\n"
        "This code expires in 15 minutes. If you didn't create a Melodix "
        "account, you can safely ignore this email."
    )
    html_body = f"""
    <div style="font-family: sans-serif; max-width: 420px; margin: 0 auto;">
      <h2 style="color: #1a1a1a;">Verify your email</h2>
      <p>Enter this code in the app to confirm this email is yours. It expires in 15 minutes.</p>
      <p style="font-size: 32px; font-weight: 700; letter-spacing: 6px;
                background: #f2f2f2; padding: 16px 20px; border-radius: 10px;
                text-align: center;">{code}</p>
      <p style="color: #666; font-size: 13px;">
        If you didn't create a Melodix account, you can safely ignore this email.
      </p>
    </div>
    """

    message.attach(MIMEText(text_body, "plain"))
    message.attach(MIMEText(html_body, "html"))

    with smtplib.SMTP_SSL(GMAIL_SMTP_HOST, GMAIL_SMTP_PORT) as server:
        server.login(GMAIL_ADDRESS, GMAIL_APP_PASSWORD)
        server.sendmail(GMAIL_ADDRESS, to_email, message.as_string())