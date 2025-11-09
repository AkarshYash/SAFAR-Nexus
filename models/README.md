# AI Models for SAFAR-Nexus

This directory contains AI models and training resources for road hazard detection.

## Model Requirements

### Pothole Detection Model
- **Type**: YOLOv11 (nano variant for mobile)
- **Format**: TensorFlow Lite (.tflite)
- **Input**: 320x320 RGB image
- **Output**: Bounding boxes + confidence scores
- **Target Accuracy**: >85% mAP
- **Target Speed**: <50ms inference on mobile

## Acquiring the Model

### Option 1: Pre-trained Model (Recommended for MVP)

1. Visit Roboflow Universe: https://universe.roboflow.com/
2. Search for "pothole detection" datasets
3. Look for models with high accuracy (>90% mAP)
4. Export as:
   - Format: TensorFlow Lite
   - Quantization: INT8 or Float16 (for mobile)

**Recommended datasets:**
- "Pothole Detection Computer Vision Project" on Roboflow
- Public pothole datasets on Kaggle

### Option 2: Train Custom Model

#### Dataset Collection

**Minimum Requirements:**
- 500 images (recommended: 2000+)
- Various conditions: day, night, wet, dry
- Multiple angles and distances
- Diverse road types

**Data Sources:**
1. Team members record driving videos
2. Extract frames from dashcam footage
3. Download public datasets (Kaggle, Roboflow)
4. Synthetic data generation (Unity/Unreal Engine)

#### Annotation

Use annotation tools to label potholes with bounding boxes:

**Recommended Tools:**
- Roboflow (online, free tier available)
- LabelImg (offline, free)
- CVAT (open source)

**Annotation Guidelines:**
- Draw tight bounding boxes around potholes
- Include partial potholes at image edges
- Label only clear, visible potholes
- Consistent naming: class = "pothole"

#### Training

**Using Ultralytics YOLOv11:**

```bash
# Install Ultralytics
pip install ultralytics

# Prepare dataset in YOLO format:
# dataset/
#   ├── images/
#   │   ├── train/
#   │   └── val/
#   └── labels/
#       ├── train/
#       └── val/

# Create data.yaml:
# path: ./dataset
# train: images/train
# val: images/val
# names:
#   0: pothole

# Train YOLOv11n (nano)
yolo train model=yolov11n.pt data=data.yaml epochs=100 imgsz=320
```

**Training Parameters:**
- Epochs: 100-200
- Image size: 320x320 (for mobile)
- Batch size: 16 (adjust based on GPU)
- Augmentation: enabled (flip, rotate, brightness)

**Validation:**
- Target mAP@0.5: >85%
- Test on various conditions
- Check for false positives

## Model Conversion

### Step 1: Export to ONNX

```bash
yolo export model=best.pt format=onnx
```

### Step 2: Convert ONNX to TensorFlow

```bash
pip install onnx-tf

onnx-tf convert -i best.onnx -o yolov11_tf
```

### Step 3: Convert to TensorFlow Lite

```bash
tflite_convert \
  --saved_model_dir=yolov11_tf \
  --output_file=pothole_detector.tflite \
  --optimizations=DEFAULT
```

**Quantization Options:**
- `--optimizations=DEFAULT`: Dynamic range quantization
- INT8 quantization: Requires representative dataset
- Float16 quantization: Good balance of size/accuracy

### Step 4: Test Inference

```python
import tensorflow as tf
import numpy as np

# Load model
interpreter = tf.lite.Interpreter(model_path="pothole_detector.tflite")
interpreter.allocate_tensors()

# Get input/output details
input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

# Prepare input (320x320 RGB, normalized)
input_data = np.random.rand(1, 320, 320, 3).astype(np.float32)

# Run inference
interpreter.set_tensor(input_details[0]['index'], input_data)
interpreter.invoke()

# Get output
output = interpreter.get_tensor(output_details[0]['index'])
print(f"Output shape: {output.shape}")
```

## Model Deployment

### Mobile App Integration

1. Copy `pothole_detector.tflite` to `mobile_app/assets/models/`
2. Model is loaded automatically by `AIService` on app startup
3. Inference runs on background thread to avoid UI blocking

### Performance Optimization

**Mobile Inference:**
- Use GPU delegate on supported devices
- Process every 3rd frame (reduces CPU load)
- Async processing with isolates

**Model Size:**
- Original: ~10MB
- Quantized INT8: ~3-4MB
- Target: <10MB for fast download/loading

## Dataset Recommendations

### Training Data Requirements

**Diversity:**
- Road types: asphalt, concrete, gravel
- Lighting: day, night, dusk, overcast
- Weather: dry, wet, rainy
- Angles: front view, angled, close-up

**Quality:**
- Resolution: Minimum 640x480
- Clear visibility of potholes
- Avoid extreme blur or overexposure

**Quantity:**
- Minimum: 500 images
- Recommended: 2000+ images
- Split: 80% train, 10% validation, 10% test

### Data Augmentation

Applied automatically during training:
- Horizontal flip
- Rotation (±15°)
- Brightness adjustment (±20%)
- Zoom (0.9x - 1.1x)
- Mosaic augmentation (YOLO-specific)

## Model Evaluation

### Metrics

**Primary Metric:**
- mAP@0.5 (mean Average Precision at IoU 0.5)
- Target: >85%

**Additional Metrics:**
- Precision: True positives / (True positives + False positives)
- Recall: True positives / (True positives + False negatives)
- Inference time: <50ms on mid-range mobile device

### Test Scenarios

1. **Daytime Clear**: Standard conditions
2. **Nighttime**: Low light conditions
3. **Rainy**: Wet roads, reflections
4. **Various Sizes**: Small to large potholes
5. **Edge Cases**: Shadows, road markings, manhole covers

## Future Enhancements

### Additional Hazard Types
- Speed breakers
- Road debris
- Stalled vehicles
- Construction zones

### Advanced Models
- YOLOv11 medium/large (for higher accuracy on server)
- Segmentation models (precise pothole boundaries)
- Temporal models (video-based detection)

### Multi-Modal Detection
- Audio: Thud sound detection (CNN audio model)
- Sensors: Accelerometer patterns (LSTM model)

## Resources

**Datasets:**
- Roboflow Universe: https://universe.roboflow.com/
- Kaggle Pothole Datasets: https://www.kaggle.com/search?q=pothole
- DIY: Record your own driving footage

**Training:**
- Ultralytics YOLOv11: https://docs.ultralytics.com/
- Google Colab: Free GPU for training
- Roboflow Train: Managed training service

**Tools:**
- LabelImg: https://github.com/tzutalin/labelImg
- CVAT: https://github.com/opencv/cvat
- Netron: Visualize model architecture

## Notes

- The current implementation has a placeholder AI service
- Actual TFLite integration requires the model file
- Model can be hot-swapped by replacing the .tflite file
- Consider A/B testing different models for best performance
