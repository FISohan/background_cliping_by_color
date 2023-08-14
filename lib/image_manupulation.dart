import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class ImageClipper {
  late img.Image _bgImage;
  late img.Image _clipperImage;

  // Future<Uint8List> _loadBytes(String assetPath) async {
  //   late ByteData imageData;
  //   try {
  //     imageData = await rootBundle.load(assetPath);
  //   } catch (e) {
  //     log("Failed to load bytes");
  //     return Future.error('Failed to load bytes');
  //   }
  //   return imageData.buffer.asUint8List();
  // }

  Future<Uint8List> _loadBytesFromNetwork(String baseUrl) async {
    Uint8List? data;
    try {
      ByteData fileBytes = await NetworkAssetBundle(Uri.parse(baseUrl)).load('');
      data = fileBytes.buffer.asUint8List();
    } catch (e) {
      log("Failed to load bytes from network");
      return Future.error(e);
    }

    return data;
  }

  Future<Uint8List> _loadBytesFromFile(String filePath) async {
    Uint8List? data;
    try {
      data = await File(filePath).readAsBytes();
    } catch (e) {
      log("Failed to load bytes from file");
      return Future.error(e);
    }
    return data;
  }

  Future<img.Image> _loadImage(Uint8List data) async {
    // Utilize flutter's built-in decoder to decode asset images as it will be
    // faster than the dart decoder.
    final buffer = await ui.ImmutableBuffer.fromUint8List(data);

    final id = await ui.ImageDescriptor.encoded(buffer);
    final codec = await id.instantiateCodec(targetHeight: id.height, targetWidth: id.width);

    final fi = await codec.getNextFrame();

    final uiImage = fi.image;
    final uiBytes = await uiImage.toByteData();

    final image = img.Image.fromBytes(
        width: id.width, height: id.height, bytes: uiBytes!.buffer, numChannels: 4);

    return image;
  }

  Future<void> loadBackgroundImage(String filePath) async {
    try {
      log("Create bg image");
      Uint8List bytes = await _loadBytesFromFile(filePath);
      _bgImage = await _loadImage(bytes);
    } catch (e) {
      log("to create bg img $e", time: DateTime.now());
    }
  }

  Future<void> loadCliperImage(String baseUrl) async {
    try {
      Uint8List bytes = await _loadBytesFromNetwork(baseUrl);
      _clipperImage = await _loadImage(bytes);
      log("create clipper Image", time: DateTime.now());
    } catch (e) {
      return Future.error(' create clipper $e');
    }
  }
  // Future<void> _loadImage() async {

  //   if (_bgImage.height != _clipperImage.height || _bgImage.width != _clipperImage.width) {
  //     log('Reasizing bg image', time: DateTime.now());
  //     _bgImage = img.copyResize(_bgImage, height: _clipperImage.height, width: _clipperImage.width);
  //   }
  //   _clipperImage = _manupulateImage(_clipperImage);
  // }

  img.Image _manupulateImage(img.Image image) {
    log("manupulate start");

    for (final img.Pixel pixel in image) {
      double grayScaleValue = ((pixel.current.r + pixel.current.g + pixel.current.b) / 3) / 255;
      if (grayScaleValue > 0.4) {
        img.Pixel bgPixel = _bgImage.getPixel(pixel.current.x, pixel.current.y);
        pixel.current.setRgba(bgPixel.r, bgPixel.g, bgPixel.b, bgPixel.a);
      }
    }
    return image;
  }

  Future<Widget?> toUiImage() async {
    _clipperImage = _manupulateImage(_clipperImage);
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
      height: 400,
      width: 400,
    );
  }
}
