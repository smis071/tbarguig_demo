import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class MarkerHelper {
  static final Map<String, BitmapDescriptor> _cache = {};

  static Future<BitmapDescriptor> fromNetworkImage(String url,
      {int size = 120}) async {
    if (_cache.containsKey(url)) return _cache[url]!;
    try {
      final resp = await http.get(Uri.parse(url));
      final bytes = resp.bodyBytes;
      final codec = await ui.instantiateImageCodec(bytes,
          targetWidth: size, targetHeight: size);
      final frame = await codec.getNextFrame();
      final byteData =
          await frame.image.toByteData(format: ui.ImageByteFormat.png);
      final resized = byteData!.buffer.asUint8List();
      final bd = BitmapDescriptor.fromBytes(resized);
      _cache[url] = bd;
      return bd;
    } catch (_) {
      return BitmapDescriptor.defaultMarker;
    }
  }
}
