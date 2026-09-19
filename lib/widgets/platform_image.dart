import 'package:flutter/material.dart';

/// Imagem de rede única para todas as plataformas.
///
/// Os sprites da PokéAPI (raw.githubusercontent.com) enviam
/// `Access-Control-Allow-Origin: *`, então `Image.network` funciona
/// normalmente no Flutter Web sem precisar de workaround de CORS —
/// isso também permite toque direto na imagem (RF02) e animações
/// Hero entre o card e a tela de detalhes.
class PlatformImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final Widget Function()? placeholder;
  final VoidCallback? onTap;

  const PlatformImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (url.isEmpty) {
      child = placeholder?.call() ?? const SizedBox.shrink();
    } else {
      child = Image.network(
        url,
        fit: fit,
        errorBuilder: (_, __, ___) =>
            placeholder?.call() ?? const SizedBox.shrink(),
        loadingBuilder: (_, imgChild, progress) {
          if (progress == null) return imgChild;
          return const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          );
        },
      );
    }
    if (onTap == null) return child;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: child,
    );
  }
}
