// property_extensions.dart
import 'add_property_screen.dart';

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
  String get displayName => this == TransactionType.sale ? 'بيع' : 'إيجار';
}

extension OwnershipTypeX on OwnershipType {
  String get displayName => this == OwnershipType.freehold ? 'تملك حر' : 'إيجار طويل الأجل';
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