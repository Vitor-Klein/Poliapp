import 'package:flutter/material.dart';

class ReasonsILoveYouPage extends StatelessWidget {
  final List<String> reasons = [
    "Seu sorriso ilumina meu dia 🌞",
    "Você sempre se importa comigo 💖",
    "Nos seus braços, me sinto em casa 🏡",
    "Você me entende como ninguém 🧠💫",
    "Nosso jeitinho juntos é único 😍",
    "Seu pé preto é a coisa mais fofa! 🐾",
    "Seu corpo é uma obra de arte 🎨",
    "Seu bom dia é meu combustível diário ☀️",
    "Seu boa noite é meu sonho mais doce 🌙",
    "Sem você, meu mundo seria cinza 🌧️",
    // Adicione mais aqui!
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Motivos pelos quais eu te amo"),
        backgroundColor: Colors.pinkAccent,
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFFCE4EC),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reasons.length,
        itemBuilder: (context, index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            child: Text(
              reasons[index],
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }
}
