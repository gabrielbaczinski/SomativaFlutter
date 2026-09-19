import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final _service = AuthService();

  String? _username;
  bool _loading = false;

  String? get username => _username;
  bool get isLoggedIn => _username != null;
  bool get loading => _loading;

  Future<void> checkSession() async {
    _username = await _service.getLoggedInUser();
    notifyListeners();
  }

  Future<String?> login(String username, String password) async {
    _loading = true;
    notifyListeners();
    final error = await _service.login(username, password);
    if (error == null) _username = username.trim();
    _loading = false;
    notifyListeners();
    return error;
  }

  Future<String?> register(String username, String password) async {
    _loading = true;
    notifyListeners();
    final error = await _service.register(username, password);
    _loading = false;
    notifyListeners();
    return error;
  }

  Future<void> logout() async {
    await _service.logout();
    _username = null;
    notifyListeners();
  }
}
