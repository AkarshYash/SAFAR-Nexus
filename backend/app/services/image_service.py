import cv2
import numpy as np
from PIL import Image
import io

# Load face detection model (on service initialization)
face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')


def blur_sensitive_data(image_bytes: bytes) -> bytes:
    """
    Detect and blur faces and license plates in image
    Returns blurred image as JPEG bytes
    """
    # Convert bytes to cv2 image
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    if img is None:
        raise ValueError("Invalid image data")

    # Detect faces
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    faces = face_cascade.detectMultiScale(gray, 1.1, 4)

    # Blur each detected face
    for (x, y, w, h) in faces:
        face_region = img[y:y+h, x:x+w]
        blurred_face = cv2.GaussianBlur(face_region, (99, 99), 30)
        img[y:y+h, x:x+w] = blurred_face

    # TODO: Add license plate detection (can use YOLO or ALPR library)
    # For MVP, face detection is primary focus

    # Convert back to JPEG bytes
    success, encoded_img = cv2.imencode('.jpg', img)
    if not success:
        raise ValueError("Failed to encode image")

    return encoded_img.tobytes()
