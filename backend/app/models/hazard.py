from sqlalchemy import Column, String, Float, DateTime, ForeignKey, CheckConstraint, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from geoalchemy2 import Geography
import uuid
from app.database import Base


class Hazard(Base):
    __tablename__ = "hazards"

    hazard_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False)
    device_id = Column(UUID(as_uuid=True), nullable=False)
    hazard_type = Column(String(50), default="pothole")
    location = Column(Geography(geometry_type='POINT', srid=4326), nullable=False)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    confidence = Column(Float, nullable=False)
    image_url = Column(Text, nullable=False)
    original_image_url = Column(Text, nullable=True)
    detected_at = Column(DateTime(timezone=True), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    __table_args__ = (
        CheckConstraint('confidence >= 0 AND confidence <= 1', name='confidence_range'),
    )
