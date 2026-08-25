import 'package:flutter/material.dart';
import '../../../../../theme/app_theme.dart';
import 'account_type_card.dart';

class RegisterStepOne extends StatelessWidget {
  final String accountType;
  final Function(String) onTypeSelected;
  final VoidCallback onNext;

  const RegisterStepOne({
    super.key,
    required this.accountType,
    required this.onTypeSelected,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('step1'),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('مرحباً بك معنا', style: TextStyle(color: AppTheme.textLight, fontSize: 22, fontWeight: FontWeight.bold)),
          const Text('اختر فئة الحساب المناسبة لك للمتابعة', style: TextStyle(color: Colors.white60, fontSize: 13)),
          const SizedBox(height: 40),
          AccountTypeCard(
            type: 'normal',
            currentType: accountType,
            title: 'مستخدم عادي',
            subtitle: 'بحث، شراء واستئجار العقارات بسهولة',
            icon: Icons.roofing_outlined,
            onTap: onTypeSelected,
          ),
          const SizedBox(height: 16),
          AccountTypeCard(
            type: 'agent',
            currentType: accountType,
            title: 'وكيل عقاري',
            subtitle: 'إدارة، إضافة وعرض العقارات للعملاء',
            icon: Icons.business_center_outlined,
            onTap: onTypeSelected,
          ),
          const SizedBox(height: 50),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.goldAccent,
          foregroundColor: AppTheme.secondaryDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('التالي', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ),
      ),
    );
  }
}