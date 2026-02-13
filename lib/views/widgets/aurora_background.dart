import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AuroraBackground extends StatelessWidget {
  final Widget child;

  const AuroraBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.appGradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -140,
            right: -120,
            child: _glow(const Color(0x66F7B500), 300),
          ),
          Positioned(
            bottom: -180,
            left: -140,
            child: _glow(const Color(0x552EE6D6), 340),
          ),
          Positioned(
            top: 220,
            left: -80,
            child: _glow(const Color(0x334D6BFF), 220),
          ),
          child,
        ],
      ),
    );
  }

  Widget _glow(Color color, double size) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(color: color, blurRadius: 120, spreadRadius: 40),
          ],
        ),
      ),
    );
  }
}
