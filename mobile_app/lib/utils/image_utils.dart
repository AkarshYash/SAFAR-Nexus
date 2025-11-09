import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';

/// Helper functions for image processing
class ImageUtils {
  /// Convert CameraImage to Image
  static img.Image? convertCameraImage(CameraImage cameraImage) {
    try {
      if (cameraImage.format.group == ImageFormatGroup.yuv420) {
        return _convertYUV420ToImage(cameraImage);
      } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
        return _convertBGRA8888ToImage(cameraImage);
      }
      return null;
    } catch (e) {
      print('Error converting camera image: $e');
      return null;
    }
  }

  static img.Image _convertYUV420ToImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;

    final img.Image image = img.Image(width: width, height: height);

    final yPlane = cameraImage.planes[0];
    final uPlane = cameraImage.planes[1];
    final vPlane = cameraImage.planes[2];

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final yIndex = y * yPlane.bytesPerRow + x;
        final uvIndex = (y ~/ 2) * uPlane.bytesPerRow + (x ~/ 2);

        final yValue = yPlane.bytes[yIndex];
        final uValue = uPlane.bytes[uvIndex];
        final vValue = vPlane.bytes[uvIndex];

        // YUV to RGB conversion
        final r = (yValue + 1.370705 * (vValue - 128)).clamp(0, 255).toInt();
        final g = (yValue - 0.337633 * (uValue - 128) - 0.698001 * (vValue - 128))
            .clamp(0, 255)
            .toInt();
        final b = (yValue + 1.732446 * (uValue - 128)).clamp(0, 255).toInt();

        image.setPixelRgba(x, y, r, g, b, 255);
      }
    }

    return image;
  }

  static img.Image _convertBGRA8888ToImage(CameraImage cameraImage) {
    return img.Image.fromBytes(
      width: cameraImage.width,
      height: cameraImage.height,
      bytes: cameraImage.planes[0].bytes.buffer,
      order: img.ChannelOrder.bgra,
    );
  }

  /// Resize image to target size
  static img.Image resizeImage(img.Image image, int targetSize) {
    return img.copyResize(image, width: targetSize, height: targetSize);
  }

  /// Crop image to bounding box with padding
  static img.Image cropToBoundingBox(
    img.Image image,
    double x,
    double y,
    double width,
    double height, {
    double paddingPercent = 0.2,
  }) {
    // Add padding
    final paddingX = (width * paddingPercent).toInt();
    final paddingY = (height * paddingPercent).toInt();

    final cropX = (x - paddingX).clamp(0, image.width - 1).toInt();
    final cropY = (y - paddingY).clamp(0, image.height - 1).toInt();
    final cropWidth =
        (width + 2 * paddingX).clamp(1, image.width - cropX).toInt();
    final cropHeight =
        (height + 2 * paddingY).clamp(1, image.height - cropY).toInt();

    return img.copyCrop(image,
        x: cropX, y: cropY, width: cropWidth, height: cropHeight);
  }

  /// Convert image to JPEG bytes
  static Uint8List imageToJpeg(img.Image image, {int quality = 85}) {
    return Uint8List.fromList(img.encodeJpg(image, quality: quality));
  }
}
