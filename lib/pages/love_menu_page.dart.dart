import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'package:poli_app/pages/gallery_page.dart';
import 'package:poli_app/pages/reasons_i_love_you_page.dart';
import 'package:poli_app/pages/our_day_page.dart';
import 'package:poli_app/pages/card_page.dart';
import 'package:poli_app/pages/our_places_page.dart';

class LoveMenuPage extends StatefulWidget {
  const LoveMenuPage({super.key});

  @override
  State<LoveMenuPage> createState() => _LoveMenuPageState();
}

class _LoveMenuPageState extends State<LoveMenuPage> {
  // Cores do tema do menu
  static const Color kBarColor = Color(0xFF7159c1); // cor da barra
  static const Color kSelectedBg = Color(
    0xFF8E7BEF,
  ); // fundo do item selecionado
  static const Color kPageBg = Color(0xFFFCE4EC); // rosinha do body
  static const Color kIconColor = Colors.white; // ícones

  int _index = 0;

  final List<Widget> _pages = <Widget>[
    CardPage(),
    const GalleryPage(),
    ReasonsILoveYouPage(),
    const OurDayPage(),
    const OurPlacesPage(),
  ];

  final List<String> _titles = const <String>[
    'Meu cartão para você',
    'Nossa galeria',
    'Para cada momento',
    'Nosso dia',
    'Lugares importantes',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPageBg,
      appBar: AppBar(
        backgroundColor: kBarColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _titles[_index],
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _pages[_index],
        ),
      ),
      // CURVED NAV BAR
      bottomNavigationBar: CurvedNavigationBar(
        index: _index,
        height: 75,
        backgroundColor: Colors.transparent, // evita “círculo sobre círculo”
        color: kBarColor, // cor da barra
        buttonBackgroundColor: kSelectedBg, // cor do item selecionado
        animationDuration: const Duration(milliseconds: 250),
        items: const [
          Icon(Icons.style, color: Colors.white, size: 28),
          Icon(Icons.photo_library, color: kIconColor),
          Icon(Icons.favorite, color: kIconColor),
          Icon(Icons.calendar_today, color: kIconColor),
          Icon(Icons.place, color: Colors.white),
        ],
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
