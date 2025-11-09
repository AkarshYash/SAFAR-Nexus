from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime


class HazardResponse(BaseModel):
    hazard_id: str
    status: str
    blurred_image_url: str
    created_at: str

    class Config:
        from_attributes = True


class HazardDetail(BaseModel):
    hazard_id: str
    latitude: float
    longitude: float
    confidence: float
    timestamp: str
    distance_km: Optional[float] = None
    image_url: str

    class Config:
        from_attributes = True


class NearbyHazardsResponse(BaseModel):
    hazards: List[HazardDetail]

    class Config:
        from_attributes = True
