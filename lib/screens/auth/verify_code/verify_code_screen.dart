import 'package:flutter/material.dart';
import '../../../services/auth_service.dart'; // استخدام الخدمة المحدثة
import '../../../theme/app_theme.dart';
import '../login_screen.dart';
import 'widgets/verify_header.dart';
import 'widgets/verify_form.dart';
import 'widgets/verify_resend_section.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;
  const VerifyCodeScreen({super.key, required this.email});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _codeController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  // --- المنطق (Logic) ---

  Future<void> _handleVerification() async {
    String code = _codeController.text.trim();

    if (code.isEmpty || code.length < 6) {
      _showSnack('الرجاء إدخال الرمز المكون من 6 أرقام كاملاً', Colors.orangeAccent);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _authService.verifyCode(widget.email, code);
      if (mounted) {
        if (result.containsKey('error')) {
          _showSnack(result['error'], Colors.redAccent);
        } else {
          _showSnack(result['message'] ?? 'تم تفعيل الحساب بنجاح!', Colors.green);
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            }
          });
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleResendCode() async {
    setState(() => _isResending = true);
    try {
      final result = await _authService.resendActivationCode(widget.email);
      if (mounted) {
        if (result.containsKey('error')) {
          _showSnack(result['error'], Colors.redAccent);
        } else {
          _showSnack('تم إعادة إرسال الرمز بنجاح', Colors.green);
        }
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: AppTheme.textLight)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- واجهة المستخدم ---

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.primaryDark, AppTheme.secondaryDark],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                    child: Column(
                      children: [
                        VerifyHeader(email: widget.email),
                        VerifyForm(
                          controller: _codeController,
                          isLoading: _isLoading,
                          onVerify: _handleVerification,
                        ),
                        const SizedBox(height: 30),
                        VerifyResendSection(
                          isResending: _isResending,
                          onResend: _handleResendCode,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textLight, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Text('تفعيل الحساب الجديد', style: TextStyle(color: AppTheme.textLight, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}