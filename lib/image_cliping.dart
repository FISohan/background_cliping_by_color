import 'package:image/image.dart' as img;
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
    // TODO: implement initState
    _imageManupulation = ImageManupulation(clipperImageAssetPath: 'assets/cw.png',bgImageAssetsPath: 'assets/xx.jpg');
    super.initState();
  }

  img.Image _processImage(img.Image? image) {
    //process the image
    for (final img.Pixel pixel in image!) {
      pixel.current.a = 255;
    }
    return image;
  }

  //late final ui.Image _uiImage;

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
