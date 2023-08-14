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
                    "https://drive.google.com/file/d/1qC3byDh5L7Prwatz5uDU9MTuAR27hnYe/view?usp=drive_link");
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
