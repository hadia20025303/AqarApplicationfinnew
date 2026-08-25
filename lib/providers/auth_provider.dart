import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  AuthProvider() { _initialize(); }

  Future<void> _initialize() async { await refreshUser(); }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    _setLoading(true);
    _error = null;
    try {
      _user = await _userService.getProfile();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _error = null;
    try {
      if (await _authService.login(email, password)) {
        await refreshUser();
        return true;
      }
      _error = "بيانات الدخول غير صحيحة";
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally { _setLoading(false); }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _user = null;
    } finally { _setLoading(false); }
  }
}