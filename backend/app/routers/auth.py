from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.schemas.auth import RegisterRequest, LoginRequest, AuthResponse
from app.models.user import User
from app.services.auth_service import hash_password, verify_password, create_access_token
from app.database import get_db

router = APIRouter()


@router.post("/register", response_model=AuthResponse)
async def register(request: RegisterRequest, db: Session = Depends(get_db)):
    """Create new user account"""
    # Check if email exists
    existing_user = db.query(User).filter(User.email == request.email).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")

    # Hash password
    password_hash = hash_password(request.password)

    # Create user
    user = User(email=request.email, password_hash=password_hash, name=request.name)
    db.add(user)
    db.commit()
    db.refresh(user)

    # Generate JWT token
    token = create_access_token({"sub": str(user.user_id)})

    return {
        "user_id": str(user.user_id),
        "email": user.email,
        "name": user.name,
        "token": token
    }


@router.post("/login", response_model=AuthResponse)
async def login(request: LoginRequest, db: Session = Depends(get_db)):
    """Login existing user"""
    # Find user by email
    user = db.query(User).filter(User.email == request.email).first()
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")

    # Verify password
    if not verify_password(request.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid credentials")

    # Generate JWT token
    token = create_access_token({"sub": str(user.user_id)})

    return {
        "user_id": str(user.user_id),
        "email": user.email,
        "name": user.name,
        "token": token
    }
