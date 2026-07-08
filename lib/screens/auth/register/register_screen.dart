import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../theme/app_theme.dart';
import '../verify_code/verify_code_screen.dart';

import '../widgets/email_form_field.dart';
import '../validators/form_validation_mixin.dart';
import 'widgets/register_step_one.dart';
import 'widgets/register_step_two.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with FormValidationMixin {
  int _currentStep = 1;
  final AuthService _authService = AuthService();

  // Controllers
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController();
  String? _usernameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _password2Error;
  String? _generalError;
  String _accountType = 'normal';
  bool _isLoading = false;
  bool _obscure1 = true, _obscure2 = true;

  @override
  void dispose() {
    for (var c in [_usernameController, _emailController, _phoneController, _passwordController, _password2Controller]) {
      c.dispose();
    }
    super.dispose();
  }

  // -- error handling --
  // --- Clear all errors ---
void _clearErrors() {
  setState(() {
    _usernameError = null;
    _emailError = null;
    _phoneError = null;
    _passwordError = null;
    _password2Error = null;
    _generalError = null;
  });
}

// --- Set field-specific errors from API response ---
void _setFieldErrors(Map<String, dynamic> errors) {
  setState(() {
    errors.forEach((key, value) {
      String errorMessage = value is List ? value.join(', ') : value.toString();
      
      switch (key) {
        case 'username':
          _usernameError = errorMessage;
          break;
        case 'email':
          _emailError = errorMessage;
          break;
        case 'phone':
          _phoneError = errorMessage;
          break;
        case 'password':
          _passwordError = errorMessage;
          break;
        case 'password2':
          _password2Error = errorMessage;
          break;
        case 'non_field_errors':
          _generalError = errorMessage;
          break;
        default:
          _generalError = errorMessage;
      }
    });
  });
}
  // --- Logic ---
Future<void> _handleRegister() async {
  _clearErrors();

  if (!_validate()) return;

  setState(() => _isLoading = true);

  try {
    final result = await _authService.register(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      password2: _password2Controller.text,
      phone: _phoneController.text.isNotEmpty ? _phoneController.text.trim() : null,
      accountType: _accountType,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.containsKey('errors')) {
      _setFieldErrors(result['errors']);
      return;
    }

    if (result.containsKey('error')) {
      setState(() => _generalError = result['error']);
      return;
    }

    _showSnack('تم إنشاء الحساب بنجاح!', Colors.green);
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => VerifyCodeScreen(email: _emailController.text.trim()))
    );
  } catch (e) {
    if (!mounted) return;
    setState(() => _isLoading = false);
    setState(() => _generalError = 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.');
  }
}

bool _validate() {
  bool isValid = true;

  if (_usernameController.text.trim().isEmpty) {
    setState(() => _usernameError = 'اسم المستخدم مطلوب');
    isValid = false;
  } else if (_usernameController.text.trim().length < 3) {
    setState(() => _usernameError = 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل');
    isValid = false;
  } else {
    setState(() => _usernameError = null);
  }

  final emailError = validateEmail(_emailController.text);
  if (emailError != null) {
    setState(() => _emailError = emailError);
    isValid = false;
  } else {
    setState(() => _emailError = null);
  }

  final passwordError = validatePassword(_passwordController.text);
  if (passwordError != null) {
    setState(() => _passwordError = passwordError);
    isValid = false;
  } else {
    setState(() => _passwordError = null);
  }

  final matchError = validatePasswordMatch(
    _password2Controller.text,
    _passwordController.text
  );
  if (matchError != null) {
    setState(() => _password2Error = matchError);
    isValid = false;
  } else {
    setState(() => _password2Error = null);
  }

  final phoneText = _phoneController.text.trim();
  if (phoneText.isNotEmpty && phoneText.length < 8) {
    setState(() => _phoneError = 'رقم الهاتف يجب أن يكون 8 أرقام على الأقل');
    isValid = false;
  } else {
    setState(() => _phoneError = null);
  }

  return isValid;
}

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [AppTheme.primaryDark, AppTheme.secondaryDark], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _currentStep == 1
                        ? RegisterStepOne(
                      accountType: _accountType,
                      onTypeSelected: (val) => setState(() => _accountType = val),
                      onNext: () => setState(() => _currentStep = 2),
                    )
                        : RegisterStepTwo(
                      accountType: _accountType,
                      isLoading: _isLoading,
                      onSubmit: _handleRegister,
                      fields: _buildFields(),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textLight, size: 20),
            onPressed: () => _currentStep == 2 ? setState(() => _currentStep = 1) : Navigator.pop(context),
          ),
          Text(_currentStep == 1 ? 'نوع العضوية' : 'بيانات الحساب', style: const TextStyle(color: AppTheme.textLight, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

List<Widget> _buildFields() {
  return [
    _input(
      _usernameController,
      'اسم المستخدم',
      Icons.person_outline,
      errorText: _usernameError,
    ),
    const SizedBox(height: 16),
    _input(
      _emailController,
      'البريد الإلكتروني',
      Icons.email_outlined,
      errorText: _emailError,
    ),
    const SizedBox(height: 16),
    _input(
      _phoneController,
      'رقم الهاتف (اختياري)',
      Icons.phone_android_outlined,
      type: TextInputType.phone,
      errorText: _phoneError,
    ),
    const SizedBox(height: 16),
    _input(
      _passwordController,
      'كلمة المرور',
      Icons.lock_outline,
      isPass: true,
      obs: _obscure1,
      onToggle: () => setState(() => _obscure1 = !_obscure1),
      errorText: _passwordError,
    ),
    const SizedBox(height: 16),
    _input(
      _password2Controller,
      'تأكيد كلمة المرور',
      Icons.lock_person_outlined,
      isPass: true,
      obs: _obscure2,
      onToggle: () => setState(() => _obscure2 = !_obscure2),
      errorText: _password2Error,
    ),
  ];
}

Widget _input(
  TextEditingController ctrl,
  String label,
  IconData icon, {
  bool isPass = false,
  bool? obs,
  VoidCallback? onToggle,
  TextInputType type = TextInputType.text,
  String? errorText,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextFormField(
        controller: ctrl,
        obscureText: obs ?? false,
        keyboardType: type,
        style: const TextStyle(color: AppTheme.textLight),
        onChanged: (_) {
          if (errorText != null) {
            setState(() {
              if (ctrl == _usernameController) _usernameError = null;
              else if (ctrl == _emailController) _emailError = null;
              else if (ctrl == _phoneController) _phoneError = null;
              else if (ctrl == _passwordController) _passwordError = null;
              else if (ctrl == _password2Controller) _password2Error = null;
              _generalError = null;
            });
          }
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: errorText != null ? Colors.redAccent : Colors.white60,
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: AppTheme.goldAccent, size: 20),
          suffixIcon: isPass
              ? IconButton(
                  icon: Icon(
                    obs! ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white38,
                  ),
                  onPressed: onToggle,
                )
              : null,
          filled: true,
          fillColor: AppTheme.fieldBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.goldAccent),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          errorText: errorText,
          errorStyle: const TextStyle(
            color: Colors.redAccent,
            fontSize: 12,
          ),
        ),
      ),
    ],
  );
}
}