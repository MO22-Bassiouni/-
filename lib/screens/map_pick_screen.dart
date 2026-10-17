import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../core.dart';

// اختيار موقع بالدبوس (يرجّع LatLng)
class MapPickScreen extends StatefulWidget {
  final String title;
  final LatLng? start;
  const MapPickScreen({super.key, required this.title, this.start});
  @override
  State<MapPickScreen> createState() => _MapPickState();
}

class _MapPickState extends State<MapPickScreen> {
  final mc = MapController();
  late LatLng center = widget.start ?? const LatLng(30.0444, 31.2357);
  bool loading = false;

  Future<void> goMe() async {
    setState(() => loading = true);
    final p = await myLocation();
    if (!mounted) return;
    setState(() => loading = false);
    if (p == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('مقدرناش نجيب موقعك. فعّل الـ GPS والصلاحية')));
      return;
    }
    mc.move(p, 16);
    center = p;
  }

  @override
  Widget build(BuildContext context) => Shell(
        title: widget.title,
        subtitle: 'حرّك الخريطة لحد ما الدبوس يبقى على المكان بالظبط',
        child: Column(children: [
          Expanded(
            child: Stack(children: [
              FlutterMap(
                mapController: mc,
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: widget.start == null ? 12 : 16,
                  onPositionChanged: (cam, _) => center = cam.center,
                ),
                children: [
                  TileLayer(
                      urlTemplate: mapTiles,
                      userAgentPackageName: 'com.sehtak.app')
                ],
              ),
              const IgnorePointer(
                child: Center(
                    child: Padding(
                        padding: EdgeInsets.only(bottom: 48),
                        child: Icon(Icons.location_on,
                            size: 48, color: Colors.red))),
              ),
              Positioned(
                left: 12,
                bottom: 12,
                child: FloatingActionButton.small(
                  heroTag: null,
                  onPressed: loading ? null : goMe,
                  child: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.my_location),
                ),
              ),
            ]),
          ),
          Padding(
              padding: const EdgeInsets.all(16),
              child:
                  BigBtn('تأكيد الموقع', () => Navigator.pop(context, center))),
        ]),
      );
}
