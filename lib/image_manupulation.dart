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
      log(e.toString());
    }
    return imageData.buffer.asUint8List();
  }

  Future<void> _loadImage() async {
    Uint8List bgImagebytes;
    Uint8List clipperImagebytes;
    try {
      bgImagebytes = await _loadBytes(bgImageAssetsPath);
      clipperImagebytes = await _loadBytes(clipperImageAssetPath);
    } catch (e) {
      return Future.error('error');
    }
    _bgImage = img.decodePng(bgImagebytes)!;
    _clipperImage = img.decodePng(clipperImagebytes)!;
    if (_bgImage.height != _clipperImage.height || _bgImage.width != _clipperImage.width) {
      _bgImage = img.copyResize(_bgImage, height: _clipperImage.height, width: _clipperImage.width);
    }
    _clipperImage = _manupulateImage(_clipperImage);
  }

  img.Image _manupulateImage(img.Image image) {
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
    await _loadImage();
    log('message');
    ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(_clipperImage.getBytes());
    ui.ImageDescriptor id = ui.ImageDescriptor.raw(buffer,
        width: _clipperImage.width,
        height: _clipperImage.height,
        pixelFormat: ui.PixelFormat.rgba8888);
    ui.Codec codec = await id.instantiateCodec(
        targetHeight: _clipperImage.height, targetWidth: _clipperImage.width);
    ui.FrameInfo fi = await codec.getNextFrame();
    ui.Image uiImage = fi.image;
    return RawImage(image: uiImage,height: 100,width: 100,);
  }
}
