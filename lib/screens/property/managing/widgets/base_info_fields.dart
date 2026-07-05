// widgets/base_info_fields.dart
import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../property_extensions.dart';
import 'shared_property_widgets.dart';
import '../property_enums.dart';

class BaseInfoFields extends StatelessWidget {
  final Category selectedCategory;
  final TransactionType selectedTransaction;
  final OwnershipType selectedOwnership;
  final LegalStatus selectedLegalStatus;
  final TextEditingController priceCtrl;
  final TextEditingController areaCtrl;
  final TextEditingController descriptionCtrl;
  
  final ValueChanged<Category?> onCategoryChanged;
  final ValueChanged<TransactionType?> onTransactionChanged;
  final ValueChanged<OwnershipType?> onOwnershipChanged;
  final ValueChanged<LegalStatus?> onLegalStatusChanged;

  const BaseInfoFields({
    super.key,
    required this.selectedCategory,
    required this.selectedTransaction,
    required this.selectedOwnership,
    required this.selectedLegalStatus,
    required this.priceCtrl,
    required this.areaCtrl,
    required this.descriptionCtrl,
    required this.onCategoryChanged,
    required this.onTransactionChanged,
    required this.onOwnershipChanged,
    required this.onLegalStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<Category>(
          value: selectedCategory,
          dropdownColor: AppTheme.primaryDark,
          style: const TextStyle(color: AppTheme.textLight),
          items: Category.values.map((e) => DropdownMenuItem(value: e, child: Text(e.displayName))).toList(),
          onChanged: onCategoryChanged,
          decoration: const InputDecoration(labelText: 'فئة العقار', filled: true, fillColor: AppTheme.fieldBg),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<TransactionType>(
          value: selectedTransaction,
          dropdownColor: AppTheme.primaryDark,
          style: const TextStyle(color: AppTheme.textLight),
          items: TransactionType.values.map((e) => DropdownMenuItem(value: e, child: Text(e.displayName))).toList(),
          onChanged: onTransactionChanged,
          decoration: const InputDecoration(labelText: 'نوع المعاملة', filled: true, fillColor: AppTheme.fieldBg),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<OwnershipType>(
          value: selectedOwnership,
          dropdownColor: AppTheme.primaryDark,
          style: const TextStyle(color: AppTheme.textLight),
          items: OwnershipType.values.map((e) => DropdownMenuItem(value: e, child: Text(e.displayName))).toList(),
          onChanged: onOwnershipChanged,
          decoration: const InputDecoration(labelText: 'نوع الملكية', filled: true, fillColor: AppTheme.fieldBg),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<LegalStatus>(
          value: selectedLegalStatus,
          dropdownColor: AppTheme.primaryDark,
          style: const TextStyle(color: AppTheme.textLight),
          items: LegalStatus.values.map((e) => DropdownMenuItem(value: e, child: Text(e.displayName))).toList(),
          onChanged: onLegalStatusChanged,
          decoration: const InputDecoration(labelText: 'الحالة القانونية', filled: true, fillColor: AppTheme.fieldBg),
        ),
        const SizedBox(height: 16),
        PropertyTextField(controller: priceCtrl, label: 'السعر (ريال)', icon: Icons.attach_money, isNumber: true),
        const SizedBox(height: 16),
        PropertyTextField(controller: areaCtrl, label: 'المساحة (م²)', icon: Icons.crop_square, isNumber: true),
        const SizedBox(height: 16),
        PropertyTextField(controller: descriptionCtrl, label: 'الوصف', icon: Icons.description),
      ],
    );
  }
}