import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:svg_shape_cliping/image_manupulation.dart';

class ClipedImage extends StatefulWidget {
  const ClipedImage({super.key});

  @override
  State<ClipedImage> createState() => _ClipedImageState();
}

class _ClipedImageState extends State<ClipedImage> {
  late ImageClipper _imageManupulation;

  @override
  void initState() {
    _imageManupulation = ImageClipper();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FutureBuilder(
          future: _imageManupulation.toUiImage(),
          builder: (context, snapshot) => snapshot.data ?? Text(snapshot.error.toString()),
        ),
        ElevatedButton(
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: false);
              if (result == null) return;
              try {
                await _imageManupulation.loadCliperImage(
                    "https://cdn.pixabay.com/photo/2017/09/03/00/44/png-2709031_1280.png");
              } catch (e) {
                log("ERROR:: $e");
              }
              await _imageManupulation.loadBackgroundImage(result.files.first.path!);
              setState(() {});
            },
            child: const Text("Load bg image"))
      ],
    );
  }
}
