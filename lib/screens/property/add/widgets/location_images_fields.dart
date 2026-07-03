// widgets/location_images_fields.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' as latlng;
import '../../../../theme/app_theme.dart';
import '../../location/map_picker_screen.dart';
import 'shared_property_widgets.dart';

class LocationImagesFields extends StatelessWidget {
  final TextEditingController countryCtrl;
  final TextEditingController cityCtrl;
  final TextEditingController regionCtrl;
  final latlng.LatLng? selectedLocation;
  final List<File> selectedImages;
  
  final VoidCallback onPickImages;
  final VoidCallback onClearImages;
  final ValueChanged<latlng.LatLng?> onLocationChanged;

  const LocationImagesFields({
    super.key,
    required this.countryCtrl,
    required this.cityCtrl,
    required this.regionCtrl,
    required this.selectedLocation,
    required this.selectedImages,
    required this.onPickImages,
    required this.onClearImages,
    required this.onLocationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PropertyTextField(controller: countryCtrl, label: 'الدولة', icon: Icons.location_on),
        const SizedBox(height: 16),
        PropertyTextField(controller: cityCtrl, label: 'المدينة', icon: Icons.location_city),
        const SizedBox(height: 16),
        PropertyTextField(controller: regionCtrl, label: 'المنطقة (اختياري)', icon: Icons.location_city_outlined, optional: true),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push<latlng.LatLng>(
                    context,
                    MaterialPageRoute(builder: (_) => MapPickerScreen(initialLocation: selectedLocation)),
                  );
                  if (result != null) onLocationChanged(result);
                },
                icon: const Icon(Icons.map_outlined),
                label: const Text('اختر الموقع على الخريطة'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.goldAccent, foregroundColor: AppTheme.secondaryDark),
              ),
            ),
            if (selectedLocation != null)
              IconButton(onPressed: () => onLocationChanged(null), icon: const Icon(Icons.clear, color: Colors.red)),
          ],
        ),
        if (selectedLocation != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'الإحداثيات: ${selectedLocation!.latitude.toStringAsFixed(6)}, ${selectedLocation!.longitude.toStringAsFixed(6)}',
              style: const TextStyle(color: AppTheme.textLight),
            ),
          ),
        const SizedBox(height: 24),
        const Text('الصور', style: TextStyle(color: AppTheme.goldAccent, fontSize: 16)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onPickImages,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(color: AppTheme.fieldBg, borderRadius: BorderRadius.circular(16)),
            child: selectedImages.isEmpty
                ? const Icon(Icons.add_a_photo_outlined, color: AppTheme.goldAccent, size: 40)
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: selectedImages.length,
                    itemBuilder: (ctx, i) => Padding(
                      padding: const EdgeInsets.all(4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(selectedImages[i], width: 100, fit: BoxFit.cover),
                      ),
                    ),
                  ),
          ),
        ),
        if (selectedImages.isNotEmpty)
          TextButton(onPressed: onClearImages, child: const Text('حذف الكل', style: TextStyle(color: Colors.red))),
      ],
    );
  }
}