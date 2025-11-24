import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

/// Widget para mostrar animación de confetti
class CelebrationConfetti extends StatefulWidget {
  final ConfettiController controller;
  final Alignment alignment;
  final double minBlastForce;
  final double maxBlastForce;
  final double emissionFrequency;
  final int numberOfParticles;
  final double gravity;

  const CelebrationConfetti({
    super.key,
    required this.controller,
    this.alignment = Alignment.center,
    this.minBlastForce = 5,
    this.maxBlastForce = 10,
    this.emissionFrequency = 0.05,
    this.numberOfParticles = 20,
    this.gravity = 0.1,
  });

  @override
  State<CelebrationConfetti> createState() => _CelebrationConfettiState();
}

class _CelebrationConfettiState extends State<CelebrationConfetti> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignment,
      child: ConfettiWidget(
        confettiController: widget.controller,
        blastDirectionality: BlastDirectionality.explosive,
        shouldLoop: false,
        colors: const [
          Colors.green,
          Colors.blue,
          Colors.pink,
          Colors.orange,
          Colors.purple,
          Colors.yellow,
        ],
        createParticlePath: drawStar,
        minBlastForce: widget.minBlastForce,
        maxBlastForce: widget.maxBlastForce,
        emissionFrequency: widget.emissionFrequency,
        numberOfParticles: widget.numberOfParticles,
        gravity: widget.gravity,
      ),
    );
  }

  /// Dibuja una estrella para el confetti
  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }
}
