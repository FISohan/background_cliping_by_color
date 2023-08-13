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
  ImageManupulation({required this.bgImageAssetsPath, required this.clipperImageAssetPath}) {}
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

  Future<void> _loadImage() async {
    Uint8List bgImagebytes;
    Uint8List clipperImagebytes;
    try {
      bgImagebytes = await _loadBytes(bgImageAssetsPath);
      _bgImage = img.decodePng(bgImagebytes)!;
      log("Create bg image");
    } catch (e) {
      log("error$e");
    }
    try {
      clipperImagebytes = await _loadBytes(clipperImageAssetPath);
      _clipperImage = img.decodePng(clipperImagebytes)!;
      log("create clipper Image");
    } catch (e) {
      return Future.error('error$e');
    }
    if (_bgImage.height != _clipperImage.height || _bgImage.width != _clipperImage.width) {
      log('Reasizing bg image');
      _bgImage = img.copyResize(_bgImage, height: _clipperImage.height, width: _clipperImage.width);
    }
    _clipperImage = _manupulateImage(_clipperImage);
  }

  img.Image _manupulateImage(img.Image image) {
    log("manupulate start");
    for (final img.Pixel pixel in image) {
      double grayScaleValue = ((pixel.current.r + pixel.current.g + pixel.current.b) / 3) / 255;
      if (grayScaleValue > 0.4) {
        img.Pixel bgPixel = _bgImage.getPixel(pixel.current.x, pixel.current.y);
        pixel.current.setRgba(bgPixel.r, bgPixel.g, bgPixel.b, bgPixel.a);
      }
    }
    log("manupulate end");

    return image;
  }

  Future<Widget?> toUiImage() async {
    try {
      log("image loading start");
      await _loadImage();
      log("image loading end");
    } catch (e) {
      log("error:$e");
      return Future.error(e);
    }

    try {
      ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(_clipperImage.getBytes());
      ui.ImageDescriptor id = ui.ImageDescriptor.raw(buffer,
          width: _clipperImage.width,
          height: _clipperImage.height,
          pixelFormat: ui.PixelFormat.rgba8888);
      ui.Codec codec = await id.instantiateCodec(
          targetHeight: _clipperImage.height, targetWidth: _clipperImage.width);
      ui.FrameInfo fi = await codec.getNextFrame();
      ui.Image uiImage = fi.image;
      log("done");
      return RawImage(
        image: uiImage,
      );
    } catch (e) {
      Future.error(e);
    }
  }
}
