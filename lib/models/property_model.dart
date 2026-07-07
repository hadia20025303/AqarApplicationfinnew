/// الموديل الرئيسي للعقار - نسخة معدلة لحل مشكلة النوع (String vs num)
class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final String? nextPageUrl;

  PaginatedResponse({required this.items, required this.total, this.nextPageUrl});
}
class PropertyCardModel {
  
  final int id;
  final String category;
  final String transactionType;
  final double price;
  final double area;
  final String description;
  final String coverImageUrl;
  final PropertyLocation? location;

  PropertyCardModel({
    required this.id,
    required this.category,
    required this.transactionType,
    required this.price,
    required this.area,
    required this.description,
    required this.coverImageUrl,
    this.location,
  });

  factory PropertyCardModel.fromJson(Map<String, dynamic> json) {
    return PropertyCardModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      category: (json['category'] ?? '').toString(),
      transactionType: (json['transaction_type'] ?? '').toString(),
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      area: double.tryParse(json['area']?.toString() ?? '0') ?? 0.0,
      description: (json['description'] ?? '').toString(),
      coverImageUrl: (json['cover_image'] ?? '').toString().isNotEmpty
          ? (json['cover_image'] ?? '').toString()
          : '',
      location: json['location'] != null
          ? PropertyLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PropertyModel {
  final int id;
  final int ownerId;
  final String category;
  final String ownershipType;
  final String legalStatus;
  final String transactionType;
  final String status;
  final double price;
  final double area;
  final String description;
  final PropertyLocation? location;
  final List<PropertyImage> images;

  final ResidentialDetails? residentialDetails;
  final CommercialDetails? commercialDetails;
  final IndustrialDetails? industrialDetails;
  final LandDetails? landDetails;

  final String? ownerUsername;
  final String? ownerPhone;
  final String? ownerAvatar;

  const PropertyModel({
    required this.id,
    required this.ownerId,
    required this.category,
    required this.ownershipType,
    required this.legalStatus,
    required this.transactionType,
    required this.status,
    required this.price,
    required this.area,
    required this.description,
    this.location,
    required this.images,
    this.residentialDetails,
    this.commercialDetails,
    this.industrialDetails,
    this.landDetails,
    this.ownerUsername,
    this.ownerPhone,
    this.ownerAvatar,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    return PropertyModel(
      // استخدام tryParse لضمان عدم حدوث خطأ إذا كانت القيمة نصاً
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      ownerId: int.tryParse(json['owner']?.toString() ?? '0') ?? 0,
      category: (json['category'] ?? '').toString(),
      ownershipType: (json['ownership_type'] ?? '').toString(),
      legalStatus: (json['legal_status'] ?? '').toString(),
      transactionType: (json['transaction_type'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      // معالجة السعر والمساحة بشكل آمن جداً
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      area: double.tryParse(json['area']?.toString() ?? '0') ?? 0.0,

      description: (json['description'] ?? '').toString(),
      location: json['location'] != null
          ? PropertyLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      images: (json['images'] as List? ?? [])
          .map((i) => PropertyImage.fromJson(i as Map<String, dynamic>))
          .toList(),
      residentialDetails: json['residential_details'] != null
          ? ResidentialDetails.fromJson(json['residential_details'] as Map<String, dynamic>)
          : null,
      commercialDetails: json['commercial_details'] != null
          ? CommercialDetails.fromJson(json['commercial_details'] as Map<String, dynamic>)
          : null,
      industrialDetails: json['industrial_details'] != null
          ? IndustrialDetails.fromJson(json['industrial_details'] as Map<String, dynamic>)
          : null,
      landDetails: json['land_details'] != null
          ? LandDetails.fromJson(json['land_details'] as Map<String, dynamic>)
          : null,
      ownerUsername: json['owner_username']?.toString(),
      ownerPhone: json['owner_phone']?.toString(),
      ownerAvatar: json['owner_avatar']?.toString(),
    );
  }
}

/// موديل موقع العقار
class PropertyLocation {
  final String country;
  final String region;
  final String city;
  final String neighborhood;
  final double? latitude;
  final double? longitude;

  const PropertyLocation({
    required this.country,
    required this.region,
    required this.city,
    required this.neighborhood,
    this.latitude,
    this.longitude,
  });

  factory PropertyLocation.fromJson(Map<String, dynamic> json) {
    return PropertyLocation(
      country: (json['country'] ?? '').toString(),
      region: (json['region'] ?? '').toString(),
      city: (json['city'] ?? '').toString(),
      neighborhood: (json['neighborhood'] ?? '').toString(),
      // تحويل الإحداثيات بشكل آمن من String إلى double
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
    );
  }
}

/// موديل صورة العقار
class PropertyImage {
  final int id;
  final String imageUrl;
  final bool isCover;

  const PropertyImage({
    required this.id,
    required this.imageUrl,
    this.isCover = false,
  });

  factory PropertyImage.fromJson(Map<String, dynamic> json) {
    return PropertyImage(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      imageUrl: (json['image_url'] ?? '').toString(),
      isCover: json['is_cover'] == true,
    );
  }
}

// ========== تفاصيل إضافية (تعديل الأرقام لتكون آمنة) ==========

class ResidentialDetails {
  final int bedrooms;
  final int bathrooms;
  final int floors;
  final bool hasGarden;
  final bool hasPool;
  final int parkingSpaces;

  const ResidentialDetails({
    required this.bedrooms,
    required this.bathrooms,
    required this.floors,
    required this.hasGarden,
    required this.hasPool,
    required this.parkingSpaces,
  });

  factory ResidentialDetails.fromJson(Map<String, dynamic> json) {
    return ResidentialDetails(
      bedrooms: int.tryParse(json['bedrooms']?.toString() ?? '0') ?? 0,
      bathrooms: int.tryParse(json['bathrooms']?.toString() ?? '0') ?? 0,
      floors: int.tryParse(json['floors']?.toString() ?? '1') ?? 1,
      hasGarden: json['has_garden'] == true,
      hasPool: json['has_pool'] == true,
      parkingSpaces: int.tryParse(json['parking_spaces']?.toString() ?? '0') ?? 0,
    );
  }
}

class CommercialDetails {
  final String propertyType;
  final int floorNumber;
  final bool hasElevator;
  final int meetingRooms;
  final int parkingSpaces;

  const CommercialDetails({
    required this.propertyType,
    required this.floorNumber,
    required this.hasElevator,
    required this.meetingRooms,
    required this.parkingSpaces,
  });

  factory CommercialDetails.fromJson(Map<String, dynamic> json) {
    return CommercialDetails(
      propertyType: (json['property_type'] ?? 'office').toString(),
      floorNumber: int.tryParse(json['floor_number']?.toString() ?? '1') ?? 1,
      hasElevator: json['has_elevator'] == true,
      meetingRooms: int.tryParse(json['meeting_rooms']?.toString() ?? '0') ?? 0,
      parkingSpaces: int.tryParse(json['parking_spaces']?.toString() ?? '0') ?? 0,
    );
  }
}

class IndustrialDetails {
  final double warehouseSize;
  final String powerCapacity;
  final double ceilingHeight;
  final int loadingDocks;

  const IndustrialDetails({
    required this.warehouseSize,
    required this.powerCapacity,
    required this.ceilingHeight,
    required this.loadingDocks,
  });

  factory IndustrialDetails.fromJson(Map<String, dynamic> json) {
    return IndustrialDetails(
      warehouseSize: double.tryParse(json['warehouse_size']?.toString() ?? '0') ?? 0.0,
      powerCapacity: (json['power_capacity'] ?? '').toString(),
      ceilingHeight: double.tryParse(json['ceiling_height']?.toString() ?? '0') ?? 0.0,
      loadingDocks: int.tryParse(json['loading_docks']?.toString() ?? '0') ?? 0,
    );
  }
}

class LandDetails {
  final String landType;
  final bool roadAccess;
  final bool waterSource;
  final bool electricityAvailable;

  const LandDetails({
    required this.landType,
    required this.roadAccess,
    required this.waterSource,
    required this.electricityAvailable,
  });

  factory LandDetails.fromJson(Map<String, dynamic> json) {
    return LandDetails(
      landType: (json['land_type'] ?? 'residential_plot').toString(),
      roadAccess: json['road_access'] == true,
      waterSource: json['water_source'] == true,
      electricityAvailable: json['electricity_available'] == true,
    );
  }
}