// validators/email_validator.dart
class EmailValidator {
  static const String _pattern = 
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

  static bool isValid(String email) {
    if (email.isEmpty) return false;
    final regExp = RegExp(_pattern);
    return regExp.hasMatch(email);
  }

  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    if (!isValid(value)) {
      return 'صيغة البريد الإلكتروني غير صحيحة';
    }
    return null;
  }
}