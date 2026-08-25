import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../models/property_model.dart';
import '../../../../theme/app_theme.dart';

class DetailsImageCarousel extends StatefulWidget {
  final List<PropertyImage> images;
  const DetailsImageCarousel({super.key, required this.images});

  @override
  State<DetailsImageCarousel> createState() => _DetailsImageCarouselState();
}

class _DetailsImageCarouselState extends State<DetailsImageCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    //  التعامل مع القائمة الفارغة
    if (widget.images.isEmpty) return _buildPlaceholder();

    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 300,
            enlargeCenterPage: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            onPageChanged: (index, _) => setState(() => _currentIndex = index),
          ),
          // 2. إصلاح الخطأ عبر التأكد من النوع داخل الـ Map
          items: widget.images.map((PropertyImage img) {
            return _buildImageItem(img.imageUrl);
          }).toList(),
        ),
        _buildDotsIndicator(),
        _buildCounterLabel(),
      ],
    );
  }

  Widget _buildImageItem(String url) {
    if (url.isEmpty) return _buildPlaceholder();

    return GestureDetector(
      onTap: () => _openFullScreen(url),
      child: CachedNetworkImage(
        imageUrl: url,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: AppTheme.fieldBg,
          child: const Center(child: CircularProgressIndicator(color: AppTheme.goldAccent)),
        ),
        errorWidget: (_, __, ___) => _buildPlaceholder(),
      ),
    );
  }

  Widget _buildDotsIndicator() {
    return Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: widget.images.asMap().entries.map((entry) {
          return Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _currentIndex == entry.key ? AppTheme.goldAccent : Colors.white38,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCounterLabel() {
    return Positioned(
      bottom: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '${_currentIndex + 1}/${widget.images.length}',
          style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Cairo'),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: 300,
      color: AppTheme.fieldBg,
      child: const Center(
        child: Icon(Icons.image_not_supported, size: 64, color: Colors.white38),
      ),
    );
  }

  void _openFullScreen(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: const CloseButton(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: url,
                placeholder: (_, __) => const CircularProgressIndicator(color: Colors.white),
                errorWidget: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white, size: 50),
              ),
            ),
          ),
        ),
      ),
    );
  }
}