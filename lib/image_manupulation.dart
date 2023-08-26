import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

class ImageClipper {
  // img.Image? _bgImage;
  img.Image? _clipperImage;
  ui.Image? uiImage;
  late img.Image _copyOfClipperImage;
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
      //uiImage = ui.Image()
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
    final buffer = await ui.ImmutableBuffer.fromUint8List(data);

    final id = await ui.ImageDescriptor.encoded(buffer);
    final codec = await id.instantiateCodec(targetHeight: id.height, targetWidth: id.width);

    final fi = await codec.getNextFrame();

    final uiImage = fi.image.clone();
    final uiBytes = await uiImage.toByteData();

    final image = img.Image.fromBytes(
        width: id.width, height: id.height, bytes: uiBytes!.buffer, numChannels: 4);

    return image;
  }

  Future<Uint8List> _svgToBytes(String url, BuildContext context) async {
    final PictureInfo pictureInfo = await vg.loadPicture(SvgNetworkLoader(url), context);
    final img = await pictureInfo.picture.toImage(500, 500);
    final ByteData? byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return Future.error("Failed to load svg image");
    img.dispose();





    
    return byteData.buffer.asUint8List();
  }

  Future<void> loadBackgroundImage(String filePath) async {
    try {
      log("Create bg image");
      Uint8List bytes = await _loadBytesFromFile(filePath);
      img.Image bgImage = await _loadImage(bytes);
      _clipperImage = _manupulateImage(_copyOfClipperImage, bgImage);
      await _toUiImage();
    } catch (e) {
      log("to create bg img $e");
    }
  }

  Future<void> clearBg() async {
    _clipperImage = _copyOfClipperImage;
    await _toUiImage();
  }

  Future<void> loadCliperImage(String baseUrl) async {
    log("loading clipper..");
    try {
      Uint8List bytes = await _loadBytesFromNetwork(baseUrl);
      _clipperImage = await _loadImage(bytes);
      _copyOfClipperImage = _clipperImage!.clone();
      await _toUiImage();
      log('copied');
    } catch (e) {
      return Future.error('To create clipper $e');
    }
    log("loaded clipper..");
  }

  Future<void> loadSvgCliperImage(String uri, BuildContext context) async {
    try {
      Uint8List uint8listOfSvg = await _svgToBytes(uri, context);
      _clipperImage = await _loadImage(uint8listOfSvg);
      _clipperImage = img.copyResize(_clipperImage!, width: 500, height: 500);
      _copyOfClipperImage = _clipperImage!.clone();
      await _toUiImage();
    } catch (e) {
      log("Failed to load svg $e");
    }
  }
  // Future<void> _loadImage() async {

  //   if (_bgImage.height != _clipperImage.height || _bgImage.width != _clipperImage.width) {
  //     log('Reasizing bg image', time: DateTime.now());
  //     _bgImage = img.copyResize(_bgImage, height: _clipperImage.height, width: _clipperImage.width);
  //   }
  //   _clipperImage = _manupulateImage(_clipperImage);
  // }

  img.Image _manupulateImage(img.Image mImage, img.Image bgImage) {
    log("manupulate start");
    img.Image mImageX = mImage.clone();
    for (final img.Pixel pixel in mImageX) {
      double grayScaleValue = ((pixel.current.r + pixel.current.g + pixel.current.b) / 3) / 255;
      //bool isCurrentPixelTransparent = pixel.current.a == 0;
      if (grayScaleValue > 0.1) {
        img.Pixel bgPixel = bgImage.getPixelSafe(pixel.current.x, pixel.current.y);
        // if (bgPixel == Pixel.undefined) continue;
        pixel.current.setRgba(bgPixel.r, bgPixel.g, bgPixel.b, bgPixel.a);
      }
    }
    return mImageX;
  }

// void addSticker(){
//   img.
// }
  Future<ui.Image?> _toUiImage() async {
    if (_clipperImage == null) return Future.error("Add clipper image");
    try {
      ui.ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(_clipperImage!.getBytes());
      ui.ImageDescriptor id = ui.ImageDescriptor.raw(buffer,
          width: _clipperImage!.width,
          height: _clipperImage!.height,
          pixelFormat: ui.PixelFormat.rgba8888);
      ui.Codec codec = await id.instantiateCodec(
          targetHeight: _clipperImage!.height, targetWidth: _clipperImage!.width);
      ui.FrameInfo fi = await codec.getNextFrame();
      uiImage = fi.image;
    } catch (e) {
      Future.error(e);
    }
    return uiImage;
  }

  Widget mainImage() {
    return RawImage(image: uiImage) ?? Text("Please Init");
  }
}
