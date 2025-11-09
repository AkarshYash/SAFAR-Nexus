-- Initialize SAFAR-Nexus Database
-- This script runs automatically when database container starts

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Verify extensions
SELECT PostGIS_Version();

-- Create initial tables (optional - FastAPI will create via SQLAlchemy)
-- Uncomment below if you want to manually create tables

/*
CREATE TABLE IF NOT EXISTS users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

CREATE TABLE IF NOT EXISTS hazards (
    hazard_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    device_id UUID NOT NULL,
    hazard_type VARCHAR(50) DEFAULT 'pothole',
    location GEOGRAPHY(POINT, 4326) NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    confidence FLOAT NOT NULL CHECK (confidence >= 0 AND confidence <= 1),
    image_url TEXT NOT NULL,
    original_image_url TEXT,
    detected_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_hazards_location ON hazards USING GIST(location);
CREATE INDEX IF NOT EXISTS idx_hazards_user_id ON hazards(user_id);
CREATE INDEX IF NOT EXISTS idx_hazards_detected_at ON hazards(detected_at DESC);
*/

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE safar_nexus TO safar_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO safar_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO safar_user;

-- Success message
DO $$
BEGIN
    RAISE NOTICE 'Database initialized successfully!';
    RAISE NOTICE 'PostGIS extension enabled';
    RAISE NOTICE 'UUID extension enabled';
END $$;
