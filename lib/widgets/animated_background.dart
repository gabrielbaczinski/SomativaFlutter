import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Fundo decorativo com manchas de gradiente flutuando lentamente.
/// Não usa BackdropFilter/blur — o efeito de "brilho" vem só do
/// degradê radial (bordas suaves), então nunca borra o conteúdo por cima.
class AnimatedBackground extends StatefulWidget {
  final Color baseColor;
  final List<Color> blobColors;

  const AnimatedBackground({
    super.key,
    required this.baseColor,
    required this.blobColors,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.blobColors;
    return IgnorePointer(
      child: ClipRect(
        child: Container(
          color: widget.baseColor,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value * 2 * math.pi;
              return Stack(
                children: [
                  _blob(t, phase: 0.0, ax: 0.15, ay: 0.18, size: 260,
                      color: colors[0 % colors.length]),
                  _blob(t, phase: 2.4, ax: 0.88, ay: 0.12, size: 220,
                      color: colors[1 % colors.length]),
                  _blob(t, phase: 4.6, ax: 0.80, ay: 0.85, size: 300,
                      color: colors[2 % colors.length]),
                  _blob(t, phase: 1.2, ax: 0.10, ay: 0.82, size: 200,
                      color: colors[3 % colors.length]),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _blob(double t,
      {required double phase,
      required double ax,
      required double ay,
      required double size,
      required Color color}) {
    final dx = math.sin(t + phase) * 26;
    final dy = math.cos(t * 0.82 + phase) * 26;
    return Align(
      alignment: Alignment(ax * 2 - 1, ay * 2 - 1),
      child: Transform.translate(
        offset: Offset(dx, dy),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.38),
                color.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
