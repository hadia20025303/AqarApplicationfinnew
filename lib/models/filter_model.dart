class PropertyFilter {
  double? priceMin;
  double? priceMax;
  double? areaMin;
  double? areaMax;
  String? category;
  String? transactionType;
  String? ownershipType;
  String? status; // حالة العقار (متاح، مؤجر، مباع، مؤرشف)
  int? rooms; // عدد الغرف (للسكني)
  String? country;
  String? region;
  String? city;

  PropertyFilter({
    this.priceMin,
    this.priceMax,
    this.areaMin,
    this.areaMax,
    this.category,
    this.transactionType,
    this.ownershipType,
    this.status,
    this.rooms,
    this.country,
    this.region,
    this.city,
  });

  /// تحويل الفلترة إلى Map لتمريرها إلى الـ API
  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    if (priceMin != null) params['price_min'] = priceMin!.toString();
    if (priceMax != null) params['price_max'] = priceMax!.toString();
    if (areaMin != null) params['area_min'] = areaMin!.toString();
    if (areaMax != null) params['area_max'] = areaMax!.toString();
    if (category != null && category != 'all') params['category'] = category!;
    if (transactionType != null && transactionType != 'all')
      params['transaction_type'] = transactionType!;
    if (ownershipType != null && ownershipType != 'all')
      params['ownership_type'] = ownershipType!;
    if (status != null && status != 'all') params['status'] = status!;
    if (rooms != null && rooms! > 0) params['rooms'] = rooms!.toString();
    if (country != null && country!.isNotEmpty) params['country'] = country!;
    if (region != null && region!.isNotEmpty) params['region'] = region!;
    if (city != null && city!.isNotEmpty) params['city'] = city!;
    return params;
  }

  /// إنشاء نسخة من الفلترة مع تعديل بعض الحقول
  PropertyFilter copyWith({
    double? priceMin,
    double? priceMax,
    double? areaMin,
    double? areaMax,
    String? category,
    String? transactionType,
    String? ownershipType,
    String? status,
    int? rooms,
    String? country,
    String? region,
    String? city,
  }) {
    return PropertyFilter(
      priceMin: priceMin ?? this.priceMin,
      priceMax: priceMax ?? this.priceMax,
      areaMin: areaMin ?? this.areaMin,
      areaMax: areaMax ?? this.areaMax,
      category: category ?? this.category,
      transactionType: transactionType ?? this.transactionType,
      ownershipType: ownershipType ?? this.ownershipType,
      status: status ?? this.status,
      rooms: rooms ?? this.rooms,
      country: country ?? this.country,
      region: region ?? this.region,
      city: city ?? this.city,
    );
  }

  /// معرفة ما إذا كانت الفلترة فارغة (لا توجد شروط)
  bool get isEmpty {
    return priceMin == null &&
        priceMax == null &&
        areaMin == null &&
        areaMax == null &&
        (category == null || category == 'all') &&
        (transactionType == null || transactionType == 'all') &&
        (ownershipType == null || ownershipType == 'all') &&
        (status == null || status == 'all') &&
        (rooms == null || rooms == 0) &&
        (country == null || country!.isEmpty) &&
        (region == null || region!.isEmpty) &&
        (city == null || city!.isEmpty);
  }
}
