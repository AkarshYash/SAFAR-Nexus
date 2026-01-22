#!/usr/bin/env python
"""
SAFAR-Nexus Backend Server Launcher
Run this file to start the backend API server
"""
import sys
import os

# Add backend to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'backend'))

if __name__ == "__main__":
    import uvicorn
    
    print("=" * 60)
    print("🚀 Starting SAFAR-Nexus Backend Server")
    print("=" * 60)
    print()
    print("Server will be available at:")
    print("  📖 API Docs:    http://localhost:8000/docs")
    print("  🌐 API Root:    http://localhost:8000")
    print("  🏥 Health:      http://localhost:8000/health")
    print()
    print("Press Ctrl+C to stop the server")
    print("=" * 60)
    print()
    
    try:
        uvicorn.run(
            "backend.app.main:app",
            host="127.0.0.1",
            port=8000,
            reload=True,
            log_level="info"
        )
    except KeyboardInterrupt:
        print("\n\n✅ Server stopped successfully!")
    except Exception as e:
        print(f"\n❌ Error starting server: {e}")
        print("\nTry installing dependencies:")
        print("  pip install fastapi uvicorn sqlalchemy aiosqlite pydantic")
        sys.exit(1)
