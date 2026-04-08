import 'package:flutter/material.dart';
import 'dart:math';

class CardPage extends StatefulWidget {
  const CardPage({super.key});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage>
    with SingleTickerProviderStateMixin {
  static const Color kPageBg = Color(0xFFFCE4EC);

  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;
  bool _animating = false; // evita toque durante o flip

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.addStatusListener((status) {
      setState(
        () => _animating =
            status == AnimationStatus.forward ||
            status == AnimationStatus.reverse,
      );
    });
  }

  void _flipCard() {
    if (_animating) return;
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kPageBg,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: _flipCard,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final angle = _animation.value * pi;
            final isUnder = angle > pi / 2;
            final transform = Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle);

            return Transform(
              alignment: Alignment.center,
              transform: transform,
              child: isUnder
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(pi),
                      child: _buildBackCard(),
                    )
                  : _buildFrontCard(),
            );
          },
        ),
      ),
    );
  }

  // ————————————————————————————————
  // FRENTE: imagem com loader sutil + fade-in
  // ————————————————————————————————
  Widget _buildFrontCard() {
    return Container(
      width: 340,
      height: 500,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.deepPurple.shade200,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: _AssetImageWithLoader(
        path: 'assets/nos35.jpg',
        // Mantém BoxFit.cover e o mesmo raio já aplicado acima
        borderRadius: BorderRadius.zero,
      ),
    );
  }

  // ————————————————————————————————
  // VERSO: mensagem
  // ————————————————————————————————
  Widget _buildBackCard() {
    return Container(
      width: 340,
      height: 500,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: Text(
          'Desde o momento em que te conheci, meu mundo ficou mais bonito. '
          'Seu sorriso ilumina meus dias, seu abraço é meu lugar favorito, '
          'e cada instante ao seu lado é um presente. '
          'Eu te amo mais do que palavras podem expressar, então fiz esse cartãozinho! 💕',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.35),
        ),
      ),
    );
  }
}

/// ————————————————————————————————
/// Reutilizável: mostra spinner até a imagem carregar e depois faz fade-in
/// ————————————————————————————————
class _AssetImageWithLoader extends StatefulWidget {
  final String path;
  final BorderRadius borderRadius;

  const _AssetImageWithLoader({
    required this.path,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  State<_AssetImageWithLoader> createState() => _AssetImageWithLoaderState();
}

class _AssetImageWithLoaderState extends State<_AssetImageWithLoader> {
  late final ImageProvider _provider;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _provider = AssetImage(widget.path);

    final stream = _provider.resolve(const ImageConfiguration());
    ImageStreamListener? listener;
    listener = ImageStreamListener(
      (_, __) {
        if (mounted) setState(() => _loaded = true);
        stream.removeListener(listener!);
      },
      onError: (_, __) {
        if (mounted)
          setState(() => _loaded = true); // evita loader infinito em erro
        stream.removeListener(listener!);
      },
    );
    stream.addListener(listener);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Fundo suave enquanto carrega
        Container(color: const Color(0xFFE1BEE7).withOpacity(0.25)),

        // Loader sutil
        if (!_loaded)
          const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator.adaptive(strokeWidth: 2.4),
            ),
          ),

        // Imagem com fade-in
        AnimatedOpacity(
          opacity: _loaded ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          child: ClipRRect(
            borderRadius: widget.borderRadius,
            child: Image(image: _provider, fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }
}
