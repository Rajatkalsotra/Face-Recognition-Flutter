import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
// import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as imglib;

typedef HandleDetection = Future<dynamic> Function(InputImage image);
enum Choice { view, delete }

Future<CameraDescription> getCamera(CameraLensDirection dir) async {
  return await availableCameras().then(
    (List<CameraDescription> cameras) => cameras.firstWhere(
      (CameraDescription camera) => camera.lensDirection == dir,
    ),
  );
}

InputImageData buildMetaData(
  CameraImage image,
  InputImageRotation rotation,
) {
  return InputImageData(
    inputImageFormat: InputImageFormat.BGRA8888,
    size: Size(image.width.toDouble(), image.height.toDouble()),
    imageRotation: rotation,
    planeData: image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList(),
  );
}

Future<dynamic> detect(
  CameraImage image,
  HandleDetection handleDetection,
  InputImageRotation rotation,
) async {
  return handleDetection(
    InputImage.fromBytes(
      bytes: image.planes[0].bytes,
      inputImageData: buildMetaData(image, rotation),
    ),
  );
}

InputImageRotation rotationIntToImageRotation(int rotation) {
  switch (rotation) {
    case 0:
      return InputImageRotation.Rotation_0deg;
    case 90:
      return InputImageRotation.Rotation_90deg;
    case 180:
      return InputImageRotation.Rotation_180deg;
    default:
      assert(rotation == 270);
      return InputImageRotation.Rotation_270deg;
  }
}

Float32List imageToByteListFloat32(
    imglib.Image image, int inputSize, double mean, double std) {
  var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
  var buffer = Float32List.view(convertedBytes.buffer);
  int pixelIndex = 0;
  for (var i = 0; i < inputSize; i++) {
    for (var j = 0; j < inputSize; j++) {
      var pixel = image.getPixel(j, i);
      buffer[pixelIndex++] = (imglib.getRed(pixel) - mean) / std;
      buffer[pixelIndex++] = (imglib.getGreen(pixel) - mean) / std;
      buffer[pixelIndex++] = (imglib.getBlue(pixel) - mean) / std;
    }
  }
  return convertedBytes.buffer.asFloat32List();
}

double euclideanDistance(List e1, List e2) {
  double sum = 0.0;
  for (int i = 0; i < e1.length; i++) {
    sum += pow((e1[i] - e2[i]), 2);
  }
  return sqrt(sum);
}
