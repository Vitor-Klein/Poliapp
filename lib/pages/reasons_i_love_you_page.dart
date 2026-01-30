import 'package:flutter/material.dart';

class ReasonsILoveYouPage extends StatelessWidget {
  const ReasonsILoveYouPage({super.key});

  // ======== CONFIGURE AQUI OS MOMENTOS =========
  // Para cada item, defina: título, texto e (opcional) imageAsset.
  List<_MomentItem> get _moments => const [
    _MomentItem(
      title: 'Quando estiver triste',
      text:
          'Ei, meu amor… em dias cinzas, lembra que eu sou seu abraço favorito. '
          'Eu te admiro tanto — sua força, seu coração enorme e o jeito lindo '
          'que você cuida do mundo. Se o dia pesar, encosta em mim. Eu te amo. 💜',
    ),
    _MomentItem(
      title: 'Quando estiver feliz',
      text:
          'Quero celebrar cada risada sua! Me chama pra viver essa alegria ao seu lado, '
          'pra dançar na sala, pra registrar mais um momento nosso. Sua felicidade me ilumina. ✨',
    ),
    _MomentItem(
      title: 'Quando estiver com saudades',
      text:
          'Fecha os olhos e sente meu cheiro te abraçando por dentro. '
          'A saudade é só o caminho até o próximo encontro — e eu estou indo na sua direção. 💌',
    ),
    _MomentItem(
      title: 'Quando estiver com medo',
      text:
          'Eu fico aqui, do seu lado. Respiramos juntos, passo a passo. '
          'Você é corajosa — e, com a minha mão na sua, tudo fica mais leve. 🤝',
    ),
    _MomentItem(
      title: 'Quando precisar de motivação',
      text:
          'Olha o tanto que você já conquistou! Você é capaz, talentosa e persistente. '
          'Vai em frente — eu acredito em você, hoje e sempre. 🚀',
    ),
    _MomentItem(
      title: 'Quando quiser lembrar do nosso amor',
      text:
          'Nosso amor é casa, é riso bobo, é cuidado e futuro. '
          'Obrigada por existir na minha vida. Te amo além do que cabe em palavras. 🏡💘',
    ),
    // Novas mensagens
    _MomentItem(
      title: 'Quando estiver nervosa ou estressada',
      text:
          'Lembre-se de respirar, meu amor. Eu tô aqui pra te acalmar, '
          'te dar força e te lembrar que você é capaz de superar tudo. Comigo, tudo fica mais tranquilo. 💙',
    ),
    _MomentItem(
      title: 'Quando precisar de um sorriso',
      text:
          'Sorrir é a melhor forma de espalhar luz, e você tem um brilho único que ilumina tudo ao seu redor. '
          'Seu sorriso me faz bem, mesmo nos dias mais difíceis. 😊',
    ),
    _MomentItem(
      title: 'Quando quiser relembrar um momento especial',
      text:
          'Lembra daquele dia em que tudo parecia perfeito? Eu guardo esse momento em mim com tanto carinho. '
          'Foi um dos nossos melhores capítulos! 📖✨',
    ),
    _MomentItem(
      title: 'Quando estiver se sentindo insegura',
      text:
          'Eu te amo do jeito que você é, com todas as suas qualidades e imperfeições. '
          'Você é incrível, e estarei sempre ao seu lado te lembrando disso. 💪❤️',
    ),
    _MomentItem(
      title: 'Quando sentir que o mundo está te cobrando demais',
      text:
          'Você não precisa ser tudo de uma vez, meu amor. '
          'Faça no seu tempo e saiba que estarei sempre te apoiando. Não tem pressa. 🌸',
    ),
    _MomentItem(
      title: 'Quando estiver se sentindo solitária',
      text:
          'Nosso amor está comigo a cada segundo, a cada passo. '
          'Mesmo de longe, eu estou sempre com você, te amando e te cuidando. 🌙💌',
    ),
    _MomentItem(
      title: 'Quando tiver dúvida sobre o futuro',
      text:
          'O futuro pode ser incerto, mas uma coisa é certa: eu quero estar ao seu lado em cada momento, não importa o que venha. Juntos, somos invencíveis. 🚀',
    ),
    _MomentItem(
      title: 'Quando precisar de carinho',
      text:
          'Sinta-se envolvida no meu abraço, mesmo que eu não esteja perto. '
          'Estou sempre te amando e te cuidando de qualquer forma. 💖',
    ),
    _MomentItem(
      title: 'Quando precisar de uma palavra de apoio',
      text:
          'Você tem uma força imensa dentro de si. E mesmo quando não souber o que fazer, saiba que não está sozinha. Eu estou com você em cada passo. 🌷',
    ),
    _MomentItem(
      title: 'Quando precisar relaxar',
      text:
          'Relaxa, amor. Nosso amor é o lugar mais tranquilo que você pode estar. '
          'Juntos, podemos enfrentar qualquer coisa com serenidade e amor. 🌙💖',
    ),
  ];
  // ============================================

  // Paleta (coerente com o app)
  static const kBg = Color(0xFFFCE4EC); // rosinha
  static const kPrimary = Color(0xFF7159c1); // roxo da barra
  static const kChip = Color(0xFFE1BEE7); // lilás suave

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: _moments.length,
        itemBuilder: (context, i) {
          final m = _moments[i];
          return _MomentCard(item: m);
        },
      ),
    );
  }
}

class _MomentItem {
  final String title;
  final String? text;
  final String? imageAsset;

  const _MomentItem({required this.title, this.text, this.imageAsset});
}

class _MomentCard extends StatelessWidget {
  const _MomentCard({required this.item});

  final _MomentItem item;

  static const kPrimary = Color(0xFF7159c1);
  static const kChip = Color(0xFFE1BEE7);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          colorScheme: Theme.of(
            context,
          ).colorScheme.copyWith(primary: kPrimary),
          splashColor: kChip.withOpacity(0.2),
          highlightColor: kChip.withOpacity(0.1),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          leading: const Icon(Icons.favorite, color: kPrimary),
          title: Text(
            item.title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: kPrimary,
            ),
          ),
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          children: [
            if (item.imageAsset != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.asset(
                    item.imageAsset!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: kChip.withOpacity(0.3),
                      alignment: Alignment.center,
                      child: const Text('Imagem não encontrada'),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (item.text != null)
              Text(
                item.text!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.35,
                ),
              ),
            if (item.text != null) const SizedBox(height: 8),
            // Rodapé sutil
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '❤ com amor',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black45,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
