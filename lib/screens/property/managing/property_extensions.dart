// property_extensions.dart
import 'property_enums.dart';

extension CategoryX on Category {
  String get displayName {
    switch (this) {
      case Category.residential: return 'سكني';
      case Category.commercial: return 'تجاري';
      case Category.industrial: return 'صناعي';
      case Category.land: return 'أرض';
    }
  }
}

extension TransactionTypeX on TransactionType {
  String get displayName {
    switch (this) {
      case TransactionType.sale: return 'بيع';
      case TransactionType.rent: return 'إيجار';
    }
  }
}

extension OwnershipTypeX on OwnershipType {
  String get displayName {
    switch (this) {
      case OwnershipType.freehold: return 'تملك حر';
      case OwnershipType.leasehold: return 'إيجار طويل الأجل';
    }
  }
}

extension LegalStatusX on LegalStatus {
  String get displayName {
    switch (this) {
      case LegalStatus.registered: return 'مسجل';
      case LegalStatus.unregistered: return 'غير مسجل';
      case LegalStatus.pending: return 'قيد التسجيل';
    }
  }
}