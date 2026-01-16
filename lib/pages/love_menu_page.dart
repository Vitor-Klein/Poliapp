import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'package:poli_app/pages/gallery_page.dart';
import 'package:poli_app/pages/reasons_i_love_you_page.dart';
import 'package:poli_app/pages/our_day_page.dart';
import 'package:poli_app/pages/card_page.dart';
import 'package:poli_app/pages/our_places_page.dart';

// ✅ ajuste os caminhos conforme seus arquivos
// import 'package:poli_app/pages/our_songs_page.dart';
import 'package:poli_app/pages/messages_page.dart';

class LoveMenuPage extends StatefulWidget {
  const LoveMenuPage({super.key});

  @override
  State<LoveMenuPage> createState() => _LoveMenuPageState();
}

class _LoveMenuPageState extends State<LoveMenuPage> {
  static const Color kBarColor = Color(0xFF7159c1);
  static const Color kSelectedBg = Color(0xFF8E7BEF);
  static const Color kPageBg = Color(0xFFFCE4EC);
  static const Color kIconColor = Colors.white;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

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

  void _openEndDrawer() => _scaffoldKey.currentState?.openEndDrawer();

  void _goTo(Widget page) {
    Navigator.pop(context); // fecha o drawer
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: kPageBg,

      // ✅ SIDEBAR (direita)
      endDrawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                color: kBarColor,
                child: const Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.music_note),
                title: const Text('Nossas músicas'),
                // onTap: () => _goTo(const OurSongsPage()),
              ),
              ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('Mensagens secretas'),
                onTap: () => _goTo(const MessagesPage()),
              ),
            ],
          ),
        ),
      ),

      appBar: AppBar(
        backgroundColor: kBarColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _titles[_index],
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Menu',
            icon: const Icon(Icons.menu),
            onPressed: _openEndDrawer,
          ),
        ],
      ),

      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _pages[_index],
        ),
      ),

      bottomNavigationBar: CurvedNavigationBar(
        index: _index,
        height: 75,
        backgroundColor: Colors.transparent,
        color: kBarColor,
        buttonBackgroundColor: kSelectedBg,
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
