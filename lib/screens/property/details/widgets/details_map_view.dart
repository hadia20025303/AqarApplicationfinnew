import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import '../../../../theme/app_theme.dart';

class DetailsMapView extends StatelessWidget {
  final double lat;
  final double lng;
  final String address;
  final VoidCallback onOpenMap;

  const DetailsMapView({
    super.key,
    required this.lat,
    required this.lng,
    required this.address,
    required this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('الموقع على الخريطة', style: TextStyle(color: AppTheme.textLight, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
        const SizedBox(height: 12),
        Container(
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.goldAccent.withValues(alpha: 0.3)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FlutterMap(
              options: MapOptions(initialCenter: latlng.LatLng(lat, lng), initialZoom: 14),
              children: [
                TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                MarkerLayer(markers: [
                  Marker(point: latlng.LatLng(lat, lng), child: const Icon(Icons.location_pin, color: Colors.red, size: 40)),
                ]),
              ],
            ),
          ),
        ),
        Row(
          children: [
            Expanded(child: Text(address, style: const TextStyle(color: Colors.white60, fontSize: 12, fontFamily: 'Cairo'))),
            TextButton.icon(onPressed: onOpenMap, icon: const Icon(Icons.open_in_new, size: 16), label: const Text('فتح الخريطة'), style: TextButton.styleFrom(foregroundColor: AppTheme.goldAccent)),
          ],
        ),
      ],
    );
  }
}