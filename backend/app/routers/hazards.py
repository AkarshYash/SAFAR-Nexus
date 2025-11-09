from fastapi import APIRouter, Depends, HTTPException, File, UploadFile, Form
from sqlalchemy.orm import Session
from geoalchemy2.elements import WKTElement
from geoalchemy2.functions import ST_DWithin, ST_MakePoint, ST_Distance
from sqlalchemy import cast, Float
from app.models.hazard import Hazard
from app.models.user import User
from app.services.image_service import blur_sensitive_data
from app.services.storage_service import upload_image
from app.dependencies import get_current_user
from app.database import get_db
import uuid

router = APIRouter()


@router.post("")
async def create_hazard(
    image: UploadFile = File(...),
    latitude: float = Form(...),
    longitude: float = Form(...),
    confidence: float = Form(...),
    timestamp: str = Form(...),
    device_id: str = Form(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Upload detected hazard with image"""
    # Validate confidence
    if not (0.0 <= confidence <= 1.0):
        raise HTTPException(status_code=400, detail="Confidence must be between 0 and 1")

    # Validate latitude/longitude
    if not (-90 <= latitude <= 90):
        raise HTTPException(status_code=400, detail="Invalid latitude")
    if not (-180 <= longitude <= 180):
        raise HTTPException(status_code=400, detail="Invalid longitude")

    # Read image
    image_bytes = await image.read()
    if len(image_bytes) > 5 * 1024 * 1024:  # 5MB limit
        raise HTTPException(status_code=413, detail="Image too large")

    # Apply privacy blurring
    blurred_image_bytes = blur_sensitive_data(image_bytes)

    # Upload to Google Cloud Storage
    image_url = upload_to_gcs(blurred_image_bytes, f"{uuid.uuid4()}.jpg")

    # Create hazard record with PostGIS point
    point = WKTElement(f'POINT({longitude} {latitude})', srid=4326)
    hazard = Hazard(
        user_id=current_user.user_id,
        device_id=device_id,
        location=point,
        latitude=latitude,
        longitude=longitude,
        confidence=confidence,
        image_url=image_url,
        detected_at=timestamp
    )
    db.add(hazard)
    db.commit()
    db.refresh(hazard)

    return {
        "hazard_id": str(hazard.hazard_id),
        "status": "success",
        "blurred_image_url": image_url,
        "created_at": hazard.created_at.isoformat()
    }


@router.get("/nearby")
async def get_nearby_hazards(
    latitude: float,
    longitude: float,
    radius_km: float = 5.0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get hazards within radius of location"""
    # Validate parameters
    if radius_km > 50:
        raise HTTPException(status_code=400, detail="Radius cannot exceed 50km")
    if limit > 500:
        limit = 500

    # Query with PostGIS spatial filter
    point = WKTElement(f'POINT({longitude} {latitude})', srid=4326)
    radius_meters = radius_km * 1000

    hazards = db.query(
        Hazard,
        cast(ST_Distance(Hazard.location, point), Float).label("distance")
    ).filter(
        ST_DWithin(Hazard.location, point, radius_meters)
    ).order_by("distance").limit(limit).all()

    # Format response
    result = []
    for hazard, distance in hazards:
        result.append({
            "hazard_id": str(hazard.hazard_id),
            "latitude": hazard.latitude,
            "longitude": hazard.longitude,
            "confidence": hazard.confidence,
            "timestamp": hazard.detected_at.isoformat(),
            "distance_km": round(distance / 1000, 2),
            "image_url": hazard.image_url
        })

    return {"hazards": result}


@router.get("/{hazard_id}")
async def get_hazard_detail(
    hazard_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get details for specific hazard"""
    hazard = db.query(Hazard).filter(Hazard.hazard_id == hazard_id).first()
    if not hazard:
        raise HTTPException(status_code=404, detail="Hazard not found")

    return {
        "hazard_id": str(hazard.hazard_id),
        "latitude": hazard.latitude,
        "longitude": hazard.longitude,
        "confidence": hazard.confidence,
        "timestamp": hazard.detected_at.isoformat(),
        "image_url": hazard.image_url,
        "user_id": str(hazard.user_id),
        "device_id": str(hazard.device_id)
    }
