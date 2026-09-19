import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/page_transitions.dart';
import '../widgets/animated_background.dart';
import '../widgets/tap_scale.dart';
import 'catalog_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  String? _error;

  late final AnimationController _entrance;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _fade = CurvedAnimation(parent: _entrance, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic));
    _entrance.forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _openRegister() {
    Navigator.of(context).push(fadeSlideRoute(const RegisterScreen()));
  }

  Future<void> _login() async {
    setState(() => _error = null);
    final auth = context.read<AuthProvider>();
    final error =
        await auth.login(_usernameCtrl.text.trim(), _passwordCtrl.text);
    if (!mounted) return;
    if (error == null) {
      HapticFeedback.mediumImpact();
      Navigator.of(context)
          .pushReplacement(fadeSlideRoute(const CatalogScreen()));
    } else {
      HapticFeedback.heavyImpact();
      setState(() => _error = 'Usuário ou senha incorretos.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().loading;
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: AnimatedBackground(
              baseColor: Color(0xFFFFF0F5),
              blobColors: [
                Color(0xFFFF8FAB),
                Color(0xFFE8D5F5),
                Color(0xFFB8A9D9),
                Color(0xFFD5EAF5),
              ],
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // RF-UX — a "foto"/avatar também abre o cadastro
                        Semantics(
                          label: 'Criar conta nova',
                          button: true,
                          child: TapScale(
                            onTap: _openRegister,
                            child: Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF8FAB)
                                    .withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFFF8FAB)
                                      .withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.catching_pokemon_rounded,
                                size: 46,
                                color: Color(0xFFFF8FAB),
                              ),
                            ),
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
                            color: Color(0xFF7A6D93),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF8FAB)
                                    .withValues(alpha: 0.15),
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
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 220),
                                child: _error != null
                                    ? Container(
                                        key: ValueKey(_error),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 10),
                                        margin:
                                            const EdgeInsets.only(bottom: 14),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFE4EC),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: const Color(0xFFFF8FAB)
                                                  .withValues(alpha: 0.4)),
                                        ),
                                        child: Text(
                                          _error!,
                                          style: const TextStyle(
                                              color: Color(0xFFB71C1C),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    : const SizedBox.shrink(
                                        key: ValueKey('no-error')),
                              ),
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
                                  // RF10 — tooltip vira o semanticLabel do botão
                                  suffixIcon: IconButton(
                                    tooltip: _obscure
                                        ? 'Mostrar senha'
                                        : 'Ocultar senha',
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: const Color(0xFF7A6D93),
                                      size: 20,
                                    ),
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                ),
                                onSubmitted: (_) => _login(),
                              ),
                              const SizedBox(height: 22),
                              ElevatedButton(
                                // RF10 — minimumSize (não altura fixa): cresce
                                // se a fonte do sistema aumentar, sem cortar texto
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                ),
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
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextButton(
                          onPressed: _openRegister,
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
          ),
        ],
      ),
    );
  }
}
