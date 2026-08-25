import 'package:flutter/material.dart';
import '../../../../../theme/app_theme.dart';

class ResetConfirmForm extends StatelessWidget {
  final TextEditingController codeController;
  final TextEditingController passController;
  final TextEditingController pass2Controller;
  final bool isLoading;
  final bool obscure1;
  final bool obscure2;
  final VoidCallback onToggle1;
  final VoidCallback onToggle2;
  final VoidCallback onSubmit;

  const ResetConfirmForm({
    super.key,
    required this.codeController,
    required this.passController,
    required this.pass2Controller,
    required this.isLoading,
    required this.obscure1,
    required this.obscure2,
    required this.onToggle1,
    required this.onToggle2,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // حقل الـ OTP
        TextFormField(
          controller: codeController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppTheme.textLight, letterSpacing: 2.0),
          decoration: _buildInputDecoration('رمز الـ OTP (6 أرقام)', Icons.domain_verification_outlined),
        ),
        const SizedBox(height: 16),

        // حقل كلمة المرور 1
        _buildPasswordField(passController, 'كلمة المرور الجديدة', obscure1, onToggle1),
        const SizedBox(height: 16),

        // حقل كلمة المرور 2
        _buildPasswordField(pass2Controller, 'تأكيد كلمة المرور الجديدة', obscure2, onToggle2),
        const SizedBox(height: 35),

        // زر التأكيد
        isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.goldAccent))
            : SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldAccent,
              foregroundColor: AppTheme.secondaryDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('تحديث واعتماد كلمة المرور', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(TextEditingController ctrl, String label, bool obs, VoidCallback toggle) {
    return TextFormField(
      controller: ctrl,
      obscureText: obs,
      style: const TextStyle(color: AppTheme.textLight),
      decoration: _buildInputDecoration(label, Icons.lock_outline).copyWith(
        suffixIcon: IconButton(
          icon: Icon(obs ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white38),
          onPressed: toggle,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white60),
      prefixIcon: Icon(icon, color: AppTheme.goldAccent),
      filled: true,
      fillColor: AppTheme.fieldBg,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.goldAccent, width: 1)),
    );
  }
}