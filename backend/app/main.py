from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routers import auth, hazards
from app.database import engine, Base

# Create database tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title="SAFAR-Nexus API", version="1.0.0")

# CORS middleware (allow mobile app origins)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # For MVP; restrict in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router, prefix="/api/v1/auth", tags=["Authentication"])
app.include_router(hazards.router, prefix="/api/v1/hazards", tags=["Hazards"])


@app.get("/")
async def root():
    return {"message": "SAFAR-Nexus API", "version": "1.0.0"}


@app.get("/health")
async def health_check():
    return {"status": "healthy"}
