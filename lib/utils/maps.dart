import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:url_launcher/url_launcher.dart';

const mapTiles = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

Future<LatLng?> myLocation() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) return null;
    var p = await Geolocator.checkPermission();
    if (p == LocationPermission.denied) {
      p = await Geolocator.requestPermission();
    }
    if (p == LocationPermission.denied || p == LocationPermission.deniedForever) {
      return null;
    }
    final pos = await Geolocator.getCurrentPosition();
    return LatLng(pos.latitude, pos.longitude);
  } catch (_) {
    return null;
  }
}

Future<void> openGoogleMaps(BuildContext c, double lat, double lng,
    {bool directions = false}) async {
  final url = directions
      ? 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng'
      : 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
  bool ok = false;
  try {
    ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (_) {}
  if (!ok && c.mounted) {
    ScaffoldMessenger.of(c)
        .showSnackBar(const SnackBar(content: Text('تعذر فتح الخريطة')));
  }
}
