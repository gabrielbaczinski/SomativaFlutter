import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _keyPrefix = 'user_pwd_';
  static const _loggedInKey = 'logged_in_user';

  Future<String?> register(String username, String password) async {
    if (username.trim().isEmpty || password.isEmpty) {
      return 'Preencha todos os campos';
    }
    if (password.length < 4) return 'Senha deve ter ao menos 4 caracteres';
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('$_keyPrefix${username.trim()}')) {
      return 'Usuário já existe';
    }
    await prefs.setString('$_keyPrefix${username.trim()}', password);
    return null;
  }

  Future<String?> login(String username, String password) async {
    if (username.trim().isEmpty || password.isEmpty) {
      return 'Preencha todos os campos';
    }
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('$_keyPrefix${username.trim()}');
    if (stored == null) return 'Usuário não encontrado';
    if (stored != password) return 'Senha incorreta';
    await prefs.setString(_loggedInKey, username.trim());
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInKey);
  }

  Future<String?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_loggedInKey);
  }
}
