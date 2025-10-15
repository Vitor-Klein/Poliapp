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
  }

  void _flipCard() {
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
      color: kPageBg, // mesmo fundo do Scaffold pai
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
                      child: _buildBackCard(), // verso = MENSAGEM
                    )
                  : _buildFrontCard(), // frente = IMAGEM
            );
          },
        ),
      ),
    );
  }

  // FRENTE: apenas a imagem (sem texto/botões)
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
      child: Image.asset(
        'assets/euiela.jpg', // tua imagem
        fit: BoxFit.cover,
      ),
    );
  }

  // VERSO: somente a mensagem (o texto que antes estava junto da imagem)
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
