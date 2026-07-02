// lib/screens/property/map_picker_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:url_launcher/url_launcher.dart';
import '../../../services/nominatim_service.dart';
import '../../../theme/app_theme.dart';

class MapPickerScreen extends StatefulWidget {
  final latlng.LatLng? initialLocation;

  const MapPickerScreen({super.key, this.initialLocation});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late latlng.LatLng _selectedLocation;
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final NominatimService _nominatimService = NominatimService();

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _mapReady = false; // لتتبع جاهزية الخريطة

  @override
  void initState() {
    super.initState();
    _selectedLocation =
        widget.initialLocation ?? const latlng.LatLng(24.7136, 46.6753);

    // تأجيل تحريك الخريطة حتى يتم عرضها
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _mapController.move(_selectedLocation, 12);
        setState(() => _mapReady = true);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- البحث عن موقع باستخدام Nominatim ---
  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults.clear());
      return;
    }

    setState(() => _isSearching = true);
    try {
      final results = await _nominatimService.searchLocation(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (_) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  // --- اختيار نتيجة البحث ---
  void _selectSearchResult(Map<String, dynamic> result) {
    final lat = result['lat'] as double;
    final lon = result['lon'] as double;
    final location = latlng.LatLng(lat, lon);

    setState(() {
      _selectedLocation = location;
      _searchResults.clear();
      _searchController.clear();
    });

    // تحريك الخريطة إلى الموقع المختار
    _mapController.move(location, 14);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryDark,
      appBar: AppBar(
        title: const Text('اختر موقع العقار على الخريطة'),
        backgroundColor: AppTheme.primaryDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: AppTheme.goldAccent),
            onPressed: () => Navigator.pop(context, _selectedLocation),
          ),
        ],
      ),
      body: Column(
        children: [
          // --- حقل البحث ---
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: AppTheme.textLight),
              decoration: InputDecoration(
                hintText: 'ابحث عن مدينة، شارع، أو معلم',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: AppTheme.goldAccent),
                suffixIcon: _isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppTheme.goldAccent),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchResults.clear());
                        },
                      ),
                filled: true,
                fillColor: AppTheme.fieldBg,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppTheme.goldAccent)),
              ),
              onChanged: _searchLocation,
            ),
          ),

          // --- نتائج البحث (قائمة منسدلة) ---
          if (_searchResults.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                itemBuilder: (ctx, index) {
                  final result = _searchResults[index];
                  return ListTile(
                    title: Text(
                      result['display_name'] ?? '',
                      style: const TextStyle(
                          color: AppTheme.textLight, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${result['city'] ?? ''}, ${result['country'] ?? ''}',
                      style: const TextStyle(color: Colors.white54),
                    ),
                    leading: const Icon(Icons.location_on,
                        color: AppTheme.goldAccent),
                    onTap: () => _selectSearchResult(result),
                  );
                },
              ),
            ),

          // --- الخريطة ---
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedLocation,
                initialZoom: 12,
                onTap: (tapPos, latLng) {
                  setState(() {
                    _selectedLocation = latLng;
                    // إخفاء نتائج البحث عند النقر على الخريطة
                    _searchResults.clear();
                    _searchController.clear();
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.real_estate',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation,
                      width: 80,
                      height: 80,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 50,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- شريط المعلومات السفلي ---
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryDark,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('الإحداثيات المحددة:',
                        style: TextStyle(color: AppTheme.textLight)),
                    Text(
                      '${_selectedLocation.latitude.toStringAsFixed(6)}, ${_selectedLocation.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(
                          color: AppTheme.goldAccent,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final url =
                              'https://www.openstreetmap.org/?mlat=${_selectedLocation.latitude}&mlon=${_selectedLocation.longitude}&zoom=15';
                          launchUrl(Uri.parse(url),
                              mode: LaunchMode.externalApplication);
                        },
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('فتح في الخريطة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.goldAccent,
                          foregroundColor: AppTheme.secondaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context, _selectedLocation);
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('تأكيد الموقع'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}