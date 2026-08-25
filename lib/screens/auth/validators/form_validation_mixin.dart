// mixins/form_validation_mixin.dart
import 'email_validator.dart';

mixin FormValidationMixin {
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'حقل $fieldName مطلوب';
    }
    return null;
  }

  String? validateEmail(String? value) {
    return EmailValidator.validate(value);
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (value.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على حروف وأرقام';
    }
    return null;
  }

  String? validatePasswordMatch(String? value, String password) {
    if (value != password) {
      return 'كلمتا المرور غير متطابقتين';
    }
    return null;
  }
}