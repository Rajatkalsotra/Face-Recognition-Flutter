import 'dart:ui';
// import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(this.imageSize, this.results);
  final Size imageSize;
  late double scaleX;

  late double scaleY;
  late dynamic results;
  late Face face;
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.greenAccent;
    for (String label in results.keys) {
      for (Face face in results[label]) {
        // face = results[label];
        scaleX = size.width / imageSize.width;
        scaleY = size.height / imageSize.height;
        canvas.drawRRect(
            _scaleRect(
                rect: face.boundingBox,
                imageSize: imageSize,
                widgetSize: size,
                scaleX: scaleX,
                scaleY: scaleY),
            paint);
        TextSpan span = new TextSpan(
            style: new TextStyle(color: Colors.orange[300], fontSize: 15),
            text: label);
        TextPainter textPainter = new TextPainter(
            text: span,
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr);
        textPainter.layout();
        textPainter.paint(
            canvas,
            new Offset(
                size.width - (60 + face.boundingBox.left.toDouble()) * scaleX,
                (face.boundingBox.top.toDouble() - 10) * scaleY));
      }
    }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.results != results;
  }
}

RRect _scaleRect(
    {@required Rect? rect,
    @required Size? imageSize,
    @required Size? widgetSize,
    double? scaleX,
    double? scaleY}) {
  return RRect.fromLTRBR(
      (widgetSize!.width - rect!.left.toDouble() * scaleX!),
      rect.top.toDouble() * scaleY!,
      widgetSize.width - rect.right.toDouble() * scaleX,
      rect.bottom.toDouble() * scaleY,
      Radius.circular(10));
}
