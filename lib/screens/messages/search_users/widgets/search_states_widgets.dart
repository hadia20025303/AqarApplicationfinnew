import 'package:flutter/material.dart';

class SearchStatesWidgets {
  static Widget buildEmptyState() {
    return const Center(
      child: Text('ابحث عن مستخدم لبدء محادثة', style: TextStyle(color: Colors.white38)),
    );
  }

  static Widget buildNoResultsState(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_outlined, size: 64, color: Colors.white38),
          const SizedBox(height: 16),
          Text('لا توجد نتائج مطابقة لـ "$query"', style: const TextStyle(color: Colors.white38)),
        ],
      ),
    );
  }

  static Widget buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(error, style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}