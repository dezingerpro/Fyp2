import 'dart:ui';

import 'package:flutter/material.dart';

class GlassContainer extends StatefulWidget {
  final double height;
  final double width;
  final BorderRadius borderRadius;
  final double blur;
  final Alignment alignment;
  final Widget child;

  const GlassContainer({
    Key? key,
    required this.height,
    required this.width,
    required this.borderRadius,
    required this.blur,
    required this.alignment,
    required this.child,
  }) : super(key: key);

  @override
  State<GlassContainer> createState() => _GlassContainerState();
}

class _GlassContainerState extends State<GlassContainer> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
          ),
          child: Stack(
            children: [
              // Blur Effect
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
                child: Container(),
              ),
              // Gradient Effect
              Container(
                decoration: BoxDecoration(
                  borderRadius: widget.borderRadius,
                  border: Border.all(color: Colors.white.withOpacity(0.20)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.purple.shade200,
                    ],
                  ),
                ),
              ),
              // Child
              Align(
                alignment: widget.alignment,
                child: widget.child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
