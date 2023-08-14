import 'package:flutter/material.dart';
import 'package:svg_shape_cliping/image_manupulation.dart';

class ImageClipper extends StatefulWidget {
  final String clipBackgroundImageAssetPath;
  final String clipperImageAssetPath;
  const ImageClipper(
      {super.key, required this.clipBackgroundImageAssetPath, required this.clipperImageAssetPath});

  @override
  State<ImageClipper> createState() => _ImageClipperState();
}

class _ImageClipperState extends State<ImageClipper> {
  late ImageManupulation _imageManupulation;

  @override
  void initState() {
    _imageManupulation = ImageManupulation(clipperImageAssetPath: 'assets/d.png',bgImageAssetsPath: 'assets/bg3.jpg');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder(
        future: _imageManupulation.toUiImage(),
        builder: (context, snapshot) => snapshot.data ?? Text(snapshot.error.toString()),
      ),
    );
  }
}
