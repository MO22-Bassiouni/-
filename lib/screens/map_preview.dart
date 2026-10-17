import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../core.dart';

// خريطة صغيرة (فاتورة / تسجيل دكتور)
class MapPreview extends StatelessWidget {
  final double lat, lng;
  const MapPreview({super.key, required this.lat, required this.lng});
  @override
  Widget build(BuildContext context) {
    final p = LatLng(lat, lng);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 170,
        child: Stack(children: [
          FlutterMap(
            options: MapOptions(
                initialCenter: p,
                initialZoom: 15,
                interactionOptions:
                    const InteractionOptions(flags: InteractiveFlag.none)),
            children: [
              TileLayer(
                  urlTemplate: mapTiles,
                  userAgentPackageName: 'com.sehtak.app'),
              MarkerLayer(markers: [
                Marker(
                    point: p,
                    width: 44,
                    height: 44,
                    alignment: Alignment.topCenter,
                    child: const Icon(Icons.location_on,
                        size: 42, color: Colors.red))
              ]),
            ],
          ),
          Positioned.fill(
              child: Material(
                  color: Colors.transparent,
                  child:
                      InkWell(onTap: () => openGoogleMaps(context, lat, lng)))),
        ]),
      ),
    );
  }
}
