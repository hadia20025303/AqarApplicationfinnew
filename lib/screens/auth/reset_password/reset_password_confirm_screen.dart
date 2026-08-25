import 'package:flutter/material.dart';
import '../../../services/auth_service.dart'; // استخدام AuthService المحدث
import '../../../theme/app_theme.dart';
import '../login_screen.dart';
import 'widgets/reset_confirm_header.dart';
import 'widgets/reset_confirm_form.dart';

class ResetPasswordConfirmScreen extends StatefulWidget {
  final String email;
  const ResetPasswordConfirmScreen({super.key, required this.email});

  @override
  State<ResetPasswordConfirmScreen> createState() => _ResetPasswordConfirmScreenState();
}

class _ResetPasswordConfirmScreenState extends State<ResetPasswordConfirmScreen> {
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _newPassword2Controller = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _codeController.dispose();
    _newPasswordController.dispose();
    _newPassword2Controller.dispose();
    super.dispose();
  }

  // --- Logic ---

  Future<void> _confirmReset() async {
    if (_codeController.text.trim().isEmpty || _newPasswordController.text.isEmpty) {
      _showSnack('الرجاء ملء جميع الحقول', Colors.orangeAccent);
      return;
    }
    if (_newPasswordController.text != _newPassword2Controller.text) {
      _showSnack('كلمتا المرور غير متطابقتين', Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _authService.confirmPasswordReset(
        email: widget.email,
        code: _codeController.text.trim(),
        newPassword: _newPasswordController.text,
        newPassword2: _newPassword2Controller.text,
      );

      if (mounted) {
        if (result.containsKey('error')) {
          _showSnack(result['error'] ?? 'فشل تحديث البيانات', Colors.redAccent);
        } else {
          _showSnack(result['message'] ?? 'تم تحديث كلمة المرور بنجاح', Colors.green);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: AppTheme.textLight)),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

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
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ResetConfirmHeader(email: widget.email),
                        ResetConfirmForm(
                          codeController: _codeController,
                          passController: _newPasswordController,
                          pass2Controller: _newPassword2Controller,
                          isLoading: _isLoading,
                          obscure1: _obscure1,
                          obscure2: _obscure2,
                          onToggle1: () => setState(() => _obscure1 = !_obscure1),
                          onToggle2: () => setState(() => _obscure2 = !_obscure2),
                          onSubmit: _confirmReset,
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
            icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textLight),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'تأكيد الهوية الجديدة',
            style: TextStyle(color: AppTheme.textLight, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}