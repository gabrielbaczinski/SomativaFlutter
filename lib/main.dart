import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/played_provider.dart';
import 'screens/login_screen.dart';
import 'screens/catalog_screen.dart';

void main() {
  runApp(const PokedexApp());
}

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => PlayedProvider()),
      ],
      child: MaterialApp(
        title: 'Pokédex',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const _AppStartup(),
      ),
    );
  }

  ThemeData _buildTheme() {
    const Color primaryPink = Color(0xFFFF8FAB);
    const Color mintGreen = Color(0xFF97C8A0);
    const Color softLavender = Color(0xFFB8A9D9);
    const Color creamBg = Color(0xFFFFF0F5);
    const Color surfaceWhite = Color(0xFFFFFFFF);
    const Color deepText = Color(0xFF4A3F55);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPink,
        brightness: Brightness.light,
      ).copyWith(
        primary: primaryPink,
        secondary: mintGreen,
        tertiary: softLavender,
        surface: surfaceWhite,
        surfaceContainerHighest: creamBg,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: deepText,
      ),
      scaffoldBackgroundColor: creamBg,
      textTheme: const TextTheme().copyWith(
        displayLarge: TextStyle(
            fontSize: 32, fontWeight: FontWeight.w800, color: deepText),
        headlineMedium: TextStyle(
            fontSize: 22, fontWeight: FontWeight.w700, color: deepText),
        titleLarge: TextStyle(
            fontSize: 18, fontWeight: FontWeight.w700, color: deepText),
        titleMedium: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600, color: deepText),
        bodyLarge: TextStyle(fontSize: 15, color: deepText),
        bodyMedium: TextStyle(
            fontSize: 14, color: deepText.withValues(alpha: 0.75)),
        labelLarge: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: deepText,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: deepText,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPink,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          elevation: 2,
          shadowColor: primaryPink.withValues(alpha: 0.35),
          textStyle:
              TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryPink.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryPink.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryPink, width: 2),
        ),
        labelStyle: TextStyle(color: const Color(0xFF7A6D93)),
        hintStyle: TextStyle(
            color: const Color(0xFF7A6D93).withValues(alpha: 0.7)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 3,
        shadowColor: primaryPink.withValues(alpha: 0.18),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.all(0),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: creamBg,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _AppStartup extends StatefulWidget {
  const _AppStartup();

  @override
  State<_AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<_AppStartup> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await Future.wait([
      context.read<AuthProvider>().checkSession(),
      context.read<FavoritesProvider>().load(),
      context.read<PlayedProvider>().load(),
    ]);
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Scaffold(
        backgroundColor: const Color(0xFFFFF0F5),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.movie_filter_rounded,
                size: 64,
                color: Color(0xFFFF8FAB),
              ),
              const SizedBox(height: 16),
              Text(
                'Pokédex',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4A3F55),
                ),
              ),
              const SizedBox(height: 28),
              const CircularProgressIndicator(
                color: Color(0xFFFF8FAB),
                strokeWidth: 2.5,
              ),
            ],
          ),
        ),
      );
    }
    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;
    return isLoggedIn ? const CatalogScreen() : const LoginScreen();
  }
}
