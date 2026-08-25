import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryDark,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        elevation: 0,
        title: const Text(
          'سياسة الخصوصية',
          style: TextStyle(
            color: AppTheme.goldAccent,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.goldAccent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionTitle('مقدمة'),
            _buildSectionText(
              'نحن نولّي أهمية كبيرة لخصوصية بياناتك. توضح هذه وثيقة سياسة الخصوصية أنواع المعلومات الشخصية التي نجمعها وكيفية استخدامها وحمايتها.',
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('البيانات التي نجمعها'),
            _buildSectionText(
              '• المعلومات الشخصية: مثل الاسم، رقم الهاتف، والبريد الإلكتروني عند تسجيل الحساب.\n'
                  '• معلومات العقارات: التفاصيل والموقع والجغرافي عند إضافة عقار.\n'
                  '• بيانات الاستخدام: كيفية تفاعلك مع التطبيق وتفضيلات البحث.',
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('كيفية استخدام المعلومات'),
            _buildSectionText(
              'نستخدم المعلومات المجمعة لتقديم خدماتنا وتحسينها، وتسهيل التواصل بين المشترين والبائعين، وإرسال التحديثات الهامة المتعلقة بحسابك.',
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('حماية البيانات'),
            _buildSectionText(
              'نحن نطبق إجراءات أمنية واستشعارية متقدمة لضمان حماية بياناتك من الوصول غير المصرح به أو التغيير أو الإفصاح.',
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('تواصل معنا'),
            _buildSectionText(
              'إذا كان لديك أي استفسارات حول سياسة الخصوصية، يمكنك التواصل معنا عبر خيار "اتصل بنا" في القائمة الجانبية.',
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.goldAccent,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        fontFamily: 'Cairo',
      ),
    );
  }

  Widget _buildSectionText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.textLight,
          fontSize: 14,
          height: 1.6,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}