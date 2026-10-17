import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../core.dart';

// عرض مكان (عيادة / بيت) مع فتحه في جوجل ماب
class PlaceScreen extends StatelessWidget {
  final String title;
  final double lat, lng;
  final String? note;
  const PlaceScreen(
      {super.key,
      required this.title,
      required this.lat,
      required this.lng,
      this.note});
  @override
  Widget build(BuildContext context) {
    final p = LatLng(lat, lng);
    return Shell(
      title: title,
      subtitle: note,
      child: Column(children: [
        Expanded(
          child: FlutterMap(
            options: MapOptions(initialCenter: p, initialZoom: 16),
            children: [
              TileLayer(
                  urlTemplate: mapTiles,
                  userAgentPackageName: 'com.sehtak.app'),
              MarkerLayer(markers: [
                Marker(
                    point: p,
                    width: 50,
                    height: 50,
                    alignment: Alignment.topCenter,
                    child: const Icon(Icons.location_on,
                        size: 48, color: Colors.red))
              ]),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            BigBtn('الاتجاهات في خرائط جوجل',
                () => openGoogleMaps(context, lat, lng, directions: true)),
            const SizedBox(height: 10),
            BigBtn(
                'افتح في خرائط جوجل', () => openGoogleMaps(context, lat, lng),
                outline: true),
          ]),
        ),
      ]),
    );
  }
}
