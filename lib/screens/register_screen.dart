import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/played_provider.dart';
import 'catalog_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() => _error = null);
    if (_passwordCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'As senhas não coincidem.');
      return;
    }
    final auth = context.read<AuthProvider>();
    final error =
        await auth.register(_usernameCtrl.text.trim(), _passwordCtrl.text);
    if (!mounted) return;
    if (error == null) {
      await auth.login(_usernameCtrl.text.trim(), _passwordCtrl.text);
      if (!mounted) return;
      await Future.wait([
        context.read<FavoritesProvider>().load(),
        context.read<PlayedProvider>().load(),
      ]);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const CatalogScreen()),
        (_) => false,
      );
    } else {
      setState(() => _error = error);
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
              Color(0xFFE8D5F5),
              Color(0xFFFFF0F5),
              Color(0xFFFFD6E7),
              Color(0xFFD5F0E8),
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
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB8A9D9).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add_rounded,
                      size: 36,
                      color: Color(0xFFB8A9D9),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Criar Conta',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4A3F55),
                    ),
                  ),
                  const Text(
                    'Crie sua conta na Pokédex',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9E91B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB8A9D9).withValues(alpha: 0.2),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                                color: Color(0xFFB8A9D9)),
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
                                color: Color(0xFFB8A9D9)),
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
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _confirmCtrl,
                          obscureText: _obscure,
                          decoration: const InputDecoration(
                            labelText: 'Confirmar Senha',
                            prefixIcon: Icon(Icons.lock_outline_rounded,
                                color: Color(0xFFB8A9D9)),
                          ),
                          onSubmitted: (_) => _register(),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: loading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB8A9D9),
                            ),
                            child: loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5),
                                  )
                                : const Text('Criar Conta'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Já tenho conta · Entrar',
                      style: TextStyle(
                        color: Color(0xFF9E91B8),
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
