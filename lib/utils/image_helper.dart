import 'package:flutter/foundation.dart';

String proxyImage(String url) {
  if (url.isEmpty) return url;
  if (kIsWeb) return 'https://corsproxy.io/?${Uri.encodeComponent(url)}';
  return url;
}
