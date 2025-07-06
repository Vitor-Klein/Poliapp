import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const FlowerApp());

class FlowerApp extends StatelessWidget {
  const FlowerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: FlowerBouquet()),
      ),
    );
  }
}

class FlowerBouquet extends StatelessWidget {
  const FlowerBouquet({super.key});

  @override
  Widget build(BuildContext context) {
    const int flowerCount = 10;
    const double angleSpread = pi / 3;
    final random = Random();

    // 🌼 Intercalar flores pequenas e grandes
    final List<_FlowerData> flowers = List.generate(flowerCount, (index) {
      final angleOffset =
          -angleSpread / 2 + (angleSpread / (flowerCount - 1)) * index;

      final bool isSmall =
          index % 2 == 0; // pares = pequenas, ímpares = grandes
      final stemLength = isSmall
          ? 120 +
                random.nextDouble() *
                    50 // 100–130
          : 200 + random.nextDouble() * 50; // 150–180

      return _FlowerData(index, angleOffset, stemLength);
    });

    return SizedBox(
      width: 500,
      height: 500,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: flowers.map((data) {
          return FlowerAnimation(
            delay: Duration(milliseconds: data.index * 150),
            angleOffset: data.angleOffset,
            stemLength: data.stemLength,
          );
        }).toList(),
      ),
    );
  }
}

class _FlowerData {
  final int index;
  final double angleOffset;
  final double stemLength;

  _FlowerData(this.index, this.angleOffset, this.stemLength);
}

class FlowerAnimation extends StatefulWidget {
  final Duration delay;
  final double angleOffset;
  final double stemLength;

  const FlowerAnimation({
    super.key,
    required this.delay,
    required this.angleOffset,
    required this.stemLength,
  });

  @override
  State<FlowerAnimation> createState() => _FlowerAnimationState();
}

class _FlowerAnimationState extends State<FlowerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _stemAnimation;
  late Animation<double> _bloomAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _stemAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _bloomAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.elasticOut),
      ),
    );

    Future.delayed(widget.delay, () => _controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => CustomPaint(
        painter: FlowerPainter(
          _stemAnimation.value,
          _bloomAnimation.value,
          widget.angleOffset,
          widget.stemLength,
        ),
        size: const Size(100, 300),
      ),
    );
  }
}

class FlowerPainter extends CustomPainter {
  final double stemProgress;
  final double bloomProgress;
  final double angleOffset;
  final double stemLength;

  FlowerPainter(
    this.stemProgress,
    this.bloomProgress,
    this.angleOffset,
    this.stemLength,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final Paint stemPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final Paint petalPaint = Paint()
      ..color = Colors.purple
      ..style = PaintingStyle.fill;

    final Paint leafPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    final double centerX = size.width / 2;
    final double bottomY = size.height;
    final double length = stemLength * stemProgress;

    final Offset start = Offset(centerX, bottomY);
    final Offset end = Offset(
      centerX + length * sin(angleOffset),
      bottomY - length * cos(angleOffset),
    );

    // 1. Caule
    canvas.drawLine(start, end, stemPaint);

    // 2. Folhas
    if (stemProgress > 0.3) {
      final midX = (start.dx + end.dx) / 2;
      final midY = (start.dy + end.dy) / 2;

      Path leftLeaf = Path()
        ..moveTo(midX, midY)
        ..quadraticBezierTo(midX - 10, midY - 10, midX - 20, midY);
      Path rightLeaf = Path()
        ..moveTo(midX, midY + 10)
        ..quadraticBezierTo(midX + 10, midY + 5, midX + 20, midY + 10);

      canvas.drawPath(leftLeaf, leafPaint);
      canvas.drawPath(rightLeaf, leafPaint);
    }

    // 3. Flor
    if (stemProgress == 1.0) {
      final double radius = 20 * bloomProgress;

      for (int i = 0; i < 6; i++) {
        final angle = (pi / 3) * i;
        final dx = end.dx + radius * cos(angle);
        final dy = end.dy + radius * sin(angle);
        canvas.drawCircle(Offset(dx, dy), 10 * bloomProgress, petalPaint);
      }

      // Miolo
      canvas.drawCircle(end, 8 * bloomProgress, Paint()..color = Colors.yellow);
    }
  }

  @override
  bool shouldRepaint(covariant FlowerPainter oldDelegate) {
    return oldDelegate.stemProgress != stemProgress ||
        oldDelegate.bloomProgress != bloomProgress ||
        oldDelegate.angleOffset != angleOffset ||
        oldDelegate.stemLength != stemLength;
  }
}
