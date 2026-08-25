import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});


  final String appVersion = "1.0.0";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryDark,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryDark,
        elevation: 0,
        title: const Text(
          'عن التطبيق',
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),


              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.goldAccent, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.goldAccent.withOpacity(0.15),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: const Icon(
                  Icons.home_work_rounded,
                  size: 50,
                  color: AppTheme.goldAccent,
                ),
              ),

              const SizedBox(height: 20),


              const Text(
                'تطبيق العقارات',
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),

              const SizedBox(height: 6),


              Text(
                'الإصدار $appVersion',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontFamily: 'Cairo',
                ),
              ),

              const SizedBox(height: 30),
              const Divider(color: Colors.white12),
              const SizedBox(height: 20),


              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Column(
                  children: [
                    Text(
                      'رؤيتنا ورسالتنا',
                      style: TextStyle(
                        color: AppTheme.goldAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'تطبيق العقارات هو منصتك المتكاملة للبحث عن العقارات المتاحة للبيع أو للإيجار بسهولة وسرعة. نهدف لتسهيل عملية التواصل بين المالك والباحث عن العقار بأسلوب حديث وتجربة مريحة.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textLight,
                        fontSize: 14,
                        height: 1.6,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),


              const Text(
                'جميع الحقوق محفوظة © 2026',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}