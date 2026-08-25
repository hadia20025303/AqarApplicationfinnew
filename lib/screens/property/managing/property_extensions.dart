
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
      case OwnershipType.systemic_tabo: return 'طابو نظامي';
      case OwnershipType.agricultural_tabo: return 'طابو زراعي';
      case OwnershipType.notary: return 'كاتب عدل';
      case OwnershipType.court_judgment: return 'حكم محكمة';
    }
  }
}
