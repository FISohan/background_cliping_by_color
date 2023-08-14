import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class ImageManupulation {
  final String bgImageAssetsPath;
  final String clipperImageAssetPath;
  final double height = 200;
  final double width = 200;
  ImageManupulation({required this.bgImageAssetsPath, required this.clipperImageAssetPath});
  late img.Image _bgImage;
  late img.Image _clipperImage;

  Future<Uint8List> _loadBytes(String assetPath) async {
    late ByteData imageData;
    try {
      imageData = await rootBundle.load(assetPath);
    } catch (e) {
      log("Failed to load bytes");
      return Future.error('Failed to load bytes');
    }
    return imageData.buffer.asUint8List();
  }

  Future<img.Image> decodeImage(String path) async {
  final data = await rootBundle.load(path);

  // Utilize flutter's built-in decoder to decode asset images as it will be
  // faster than the dart decoder.
  final buffer = await ui.ImmutableBuffer.fromUint8List(
      data.buffer.asUint8List());

  final id = await ui.ImageDescriptor.encoded(buffer);
  final codec = await id.instantiateCodec(
      targetHeight: id.height,
      targetWidth: id.width);

  final fi = await codec.getNextFrame();

  final uiImage = fi.image;
  final uiBytes = await uiImage.toByteData();

  final image = img.Image.fromBytes(width: id.width, height: id.height,
      bytes: uiBytes!.buffer, numChannels: 4);

  return image;
}

  Future<void> _loadImage() async {
    try {
      _bgImage = await decodeImage(bgImageAssetsPath);
      log("Create bg image", time: DateTime.now());
    } catch (e) {
      log("to create bg img $e", time: DateTime.now());
    }
    try {
      _clipperImage = await decodeImage(clipperImageAssetPath);
      log("create clipper Image", time: DateTime.now());
    } catch (e) {
      return Future.error(' create clipper $e');
    }
    if (_bgImage.height != _clipperImage.height || _bgImage.width != _clipperImage.width) {
      log('Reasizing bg image', time: DateTime.now());
      _bgImage = img.copyResize(_bgImage, height: _clipperImage.height, width: _clipperImage.width);
    }
    _clipperImage = _manupulateImage(_clipperImage);
  }

  img.Image _manupulateImage(img.Image image) {
    log("manupulate start", time: DateTime.now());
        final Stopwatch t = Stopwatch()..start();

    for (final img.Pixel pixel in image) {
      double grayScaleValue = ((pixel.current.r + pixel.current.g + pixel.current.b) / 3) / 255;
      if (grayScaleValue > 0.4) {
        img.Pixel bgPixel = _bgImage.getPixel(pixel.current.x, pixel.current.y);
        pixel.current.setRgba(bgPixel.r, bgPixel.g, bgPixel.b, bgPixel.a);
      }
    }
    log("manupulate end", time: DateTime.now());
        log("time:${t.elapsedMilliseconds.toString()}");

        t.stop();
    return image;
  }

  Future<Widget?> toUiImage() async {
    try {
      log("image loading start", time: DateTime.now());
      await _loadImage();
      log("image loading end", time: DateTime.now());
    } catch (e) {
      log("error toUiImage:$e", time: DateTime.now());
      return Future.error(e);
    }


    late ui.Image uiImage;
    try {
      ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(_clipperImage.getBytes());
      ui.ImageDescriptor id = ui.ImageDescriptor.raw(buffer,
          width: _clipperImage.width,
          height: _clipperImage.height,
          pixelFormat: ui.PixelFormat.rgba8888);
      ui.Codec codec = await id.instantiateCodec(
          targetHeight: _clipperImage.height, targetWidth: _clipperImage.width);
      ui.FrameInfo fi = await codec.getNextFrame();
      uiImage = fi.image;
      log("done", time: DateTime.now());
    } catch (e) {
      Future.error(e);
    }
    return RawImage(
      image: uiImage,
    );
  }
}
