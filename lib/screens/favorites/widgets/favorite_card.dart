import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../models/property_model.dart';
import '../../../../theme/app_theme.dart';
import '../../property/details/property_details_screen.dart';


class FavoriteCard extends StatelessWidget {
  final PropertyModel property;
  final VoidCallback onRemove;

  const FavoriteCard({super.key, required this.property, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PropertyDetailsScreen(property: property)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.fieldBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildDetails(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: property.images.isNotEmpty
          ? CachedNetworkImage(
        imageUrl: property.images[0].imageUrl,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, __) => _imagePlaceholder(),
        errorWidget: (_, __, ___) => _imageError(),
      )
          : _imagePlaceholder(icon: Icons.home_work_outlined),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${property.price.toStringAsFixed(0)} \$',
              style: const TextStyle(color: AppTheme.goldAccent, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.redAccent),
              onPressed: onRemove,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildInfoRow(),
      ],
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: [
        const Icon(Icons.crop_square, size: 14, color: Colors.white54),
        const SizedBox(width: 4),
        Text('${property.area.toStringAsFixed(0)} م²', style: const TextStyle(color: Colors.white54, fontSize: 13)),
        const SizedBox(width: 16),
        const Icon(Icons.location_on_outlined, size: 14, color: Colors.white54),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            property.location != null ? '${property.location!.city}، ${property.location!.region}' : 'موقع غير محدد',
            style: const TextStyle(color: Colors.white54, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _imagePlaceholder({IconData icon = Icons.image}) {
    return Container(
      height: 180,
      color: AppTheme.primaryDark,
      child: Center(child: Icon(icon, size: 50, color: Colors.white38)),
    );
  }

  Widget _imageError() => _imagePlaceholder(icon: Icons.broken_image);
}