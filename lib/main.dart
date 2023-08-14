import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:svg_shape_cliping/image_cliping.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {

    return  const MaterialApp(
        home: Scaffold(
            backgroundColor: ui.Color.fromARGB(255, 206, 206, 206),
            body: Center(
              child: ClipedImage(),
            )));
  }
}

