import 'package:flutter/material.dart';

class PlatformImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final Widget Function()? placeholder;

  const PlatformImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) return placeholder?.call() ?? const SizedBox.shrink();
    return Image.network(
      url,
      fit: fit,
      errorBuilder: (_, __, ___) =>
          placeholder?.call() ?? const SizedBox.shrink(),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
    );
  }
}
