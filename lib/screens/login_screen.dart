import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'catalog_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _error = null);
    final auth = context.read<AuthProvider>();
    final error =
        await auth.login(_usernameCtrl.text.trim(), _passwordCtrl.text);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const CatalogScreen()),
      );
    } else {
      setState(() => _error = 'Usuário ou senha incorretos.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().loading;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFD6E7),
              Color(0xFFFFF0F5),
              Color(0xFFE8D5F5),
              Color(0xFFD5EAF5),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF8FAB).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.movie_filter_rounded,
                      size: 44,
                      color: Color(0xFFFF8FAB),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pokédex',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4A3F55),
                    ),
                  ),
                  const Text(
                    'Sua Pokédex pessoal',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9E91B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF8FAB).withValues(alpha: 0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Entrar',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF4A3F55),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        if (_error != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE4EC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: const Color(0xFFFF8FAB)
                                      .withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                  color: Color(0xFFD4607E),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        TextField(
                          controller: _usernameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Usuário',
                            prefixIcon: Icon(Icons.person_outline_rounded,
                                color: Color(0xFFFF8FAB)),
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _passwordCtrl,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: const Icon(Icons.lock_outline_rounded,
                                color: Color(0xFFFF8FAB)),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF9E91B8),
                                size: 20,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          onSubmitted: (_) => _login(),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: loading ? null : _login,
                            child: loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5),
                                  )
                                : const Text('Entrar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const RegisterScreen()),
                    ),
                    child: const Text(
                      'Não tem conta? Criar conta',
                      style: TextStyle(
                        color: Color(0xFFFF8FAB),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
