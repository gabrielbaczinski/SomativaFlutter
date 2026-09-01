// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

class PlatformImage extends StatefulWidget {
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
  State<PlatformImage> createState() => _PlatformImageState();
}

class _PlatformImageState extends State<PlatformImage> {
  static final Set<String> _registered = {};

  late final String _viewId;

  @override
  void initState() {
    super.initState();
    // Combine hashCode + length para minimizar colisões
    _viewId = 'img_${widget.url.hashCode.abs()}_${widget.url.length}';
    if (!_registered.contains(_viewId)) {
      _registered.add(_viewId);
      final url = widget.url;
      final objectFit = widget.fit == BoxFit.cover ? 'cover' : 'contain';
      ui_web.platformViewRegistry.registerViewFactory(_viewId, (int id) {
        return html.ImageElement()
          ..src = url
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = objectFit;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.url.isEmpty) {
      return widget.placeholder?.call() ?? const SizedBox.shrink();
    }
    return HtmlElementView(viewType: _viewId);
  }
}
