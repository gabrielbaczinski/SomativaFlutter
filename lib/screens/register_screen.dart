import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'catalog_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() => _error = null);
    if (_passwordController.text != _confirmController.text) {
      setState(() => _error = 'As senhas não coincidem');
      return;
    }
    final auth = context.read<AuthProvider>();
    final error = await auth.register(
      _usernameController.text,
      _passwordController.text,
    );
    if (!mounted) return;
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    await auth.login(_usernameController.text, _passwordController.text);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const CatalogScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().loading;
    return Scaffold(
      backgroundColor: const Color(0xff1a1a2e),
      appBar: AppBar(
        title: const Text('Criar Conta'),
        backgroundColor: const Color(0xff16213e),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Icon(Icons.person_add, size: 72, color: Color(0xffe94560)),
              const SizedBox(height: 24),
              if (_error != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade700),
                  ),
                  child: Text(_error!,
                      style: const TextStyle(color: Colors.redAccent)),
                ),
              Semantics(
                label: 'Campo de usuário para cadastro',
                child: TextField(
                  controller: _usernameController,
                  decoration: _inputDecoration('Usuário', Icons.person),
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 14),
              Semantics(
                label: 'Campo de senha para cadastro',
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _inputDecoration('Senha', Icons.lock),
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 14),
              Semantics(
                label: 'Campo confirmar senha',
                child: TextField(
                  controller: _confirmController,
                  obscureText: true,
                  decoration: _inputDecoration('Confirmar Senha', Icons.lock_outline),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _register(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 28),
              Semantics(
                label: 'Botão cadastrar',
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: loading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffe94560),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Text('Cadastrar',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white54),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xffe94560)),
        ),
        filled: true,
        fillColor: const Color(0xff16213e),
      );
}
