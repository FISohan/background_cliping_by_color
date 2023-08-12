import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:svg_shape_cliping/image_cliping.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {

    return const MaterialApp(
        home: Scaffold(
            backgroundColor: ui.Color.fromARGB(255, 105, 105, 105),
            body: Center(
              child: ImageClipper(clipBackgroundImageAssetPath: "clipBackgroundImageAssetPath", clipperImageAssetPath: 'clipperImageAssetPath'),
            )));
  }
}

class SvgClipper extends CustomClipper<Path> {
  @override
  ui.Path getClip(ui.Size size) {
    String svgPath1 =
        '''m 480.87 313.68 H 19.01 c 0 -2.04 0 -3.82 0 -5.6 c 0 -79.52 0.14 -159.04 -0.14 -238.56 c -0.05 -12.94 7.65 -21.69 21.78 -21.67 c 139.34 0.21 278.69 0.12 418.03 0.14 c 12.78 0 18.92 3.88 21.67 13.86 c 0.65 2.35 0.69 4.91 0.7 7.37 c 0.03 80.02 0.03 160.04 0.02 240.06 c 0 1.32 -0.11 2.63 -0.2 4.41 Z m -231.4 -15.88 c 69.15 0 138.31 0 207.46 0 c 6.87 0 7.42 -0.57 7.42 -7.36 c 0 -73 0 -146 0 -219 c 0 -6.73 -0.6 -7.31 -7.51 -7.31 c -137.64 0 -275.28 0.01 -412.93 0.02 c -7.88 0 -8.18 0.28 -8.18 8.14 c 0 72.5 0 145 0 217.5 c 0 7.7 0.34 8.03 8.28 8.03 c 68.49 0 136.97 0 205.46 0 Z''';
    String svgPath2 =
        '''m 19.01 322.4 h 462.06 c -0.73 11.41 2.28 22.88 -4.04 33.58 c -4.23 7.17 -9.74 11.1 -18.5 11.07 c -51.17 -0.19 -102.34 -0.09 -153.51 -0.09 c -87.84 0 -175.68 -0.18 -263.52 0.14 c -14.84 0.05 -23.06 -7.79 -22.54 -22.43 c 0.26 -7.28 0.05 -14.59 0.05 -22.27 Z''';
    String svgPath3 =
        '''m 165.52 451.15 c 2.57 -9.89 4.11 -18.91 7.31 -27.29 c 3.56 -9.31 11.99 -13.38 21.44 -13.46 c 37.17 -0.31 74.34 -0.19 111.51 -0.09 c 11.16 0.03 20.32 7.34 23.19 18.2 c 1.65 6.22 2.88 12.56 4.44 18.8 c 0.67 2.67 -0.24 3.8 -2.86 3.82 c -1.5 0.01 -3 0.02 -4.5 0.02 c -48.17 0 -96.35 0 -144.52 0 h -16.02 Z''';
    String svgPath4 = '''m 304.65 370.51 v 35.21 h -109.22 v -35.21 h 109.22 Z''';
    String svgPath5 =
        '''m 249.48 297.81 c -68.49 0 -136.97 0 -205.46 0 c -7.94 0 -8.28 -0.33 -8.28 -8.03 c 0 -72.5 0 -145 0 -217.5 c 0 -7.85 0.3 -8.13 8.18 -8.14 c 137.64 0 275.28 -0.01 412.93 -0.02 c 6.91 0 7.51 0.58 7.51 7.31 c 0 73 0 146 0 219 c 0 6.79 -0.55 7.36 -7.42 7.36 c -69.15 0.01 -138.31 0 -207.46 0.01 Z m -206.19 -7.75 c 2.25 0 4.04 0 5.82 0 c 133.97 0 267.95 -0.02 401.92 0.12 c 4.89 0 6.04 -1.45 6.03 -6.16 c -0.13 -69.17 -0.07 -138.33 -0.07 -207.5 c 0 -1.47 -0.12 -2.94 -0.2 -4.71 H 43.29 v 218.25 Z''';
    String svgPath6 =
        '''m 43.29 290.06 V 71.81 h 413.51 c 0.08 1.77 0.2 3.24 0.2 4.71 c 0 69.17 -0.06 138.33 0.07 207.5 c 0 4.71 -1.14 6.17 -6.03 6.16 c -133.97 -0.14 -267.95 -0.11 -401.92 -0.12 c -1.79 0 -3.57 0 -5.82 0 Z''';

    final Path path = parseSvgPathData(svgPath1)
      ..addPath(parseSvgPathData(svgPath2), Offset.zero)
      ..addPath(parseSvgPathData(svgPath3), Offset.zero)
      ..addPath(parseSvgPathData(svgPath4), Offset.zero)
      ..addPath(parseSvgPathData(svgPath5), Offset.zero)
      ..addPath(parseSvgPathData(svgPath6), Offset.zero);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<ui.Path> oldClipper) {
    return false;
  }
}
