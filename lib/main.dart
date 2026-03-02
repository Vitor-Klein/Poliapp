// lib/main.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import 'firebase_options.dart';
import 'services/message_storage.dart';
import 'services/widget_background.dart';

import 'pages/home_page.dart';
import 'pages/love_menu_page.dart';
import 'pages/splash_screen.dart';
import 'pages/gallery_page.dart';
import 'pages/our_day_page.dart';
import 'package:poli_app/pages/reasons_i_love_you_page.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await saveMessageLocally(message);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Background handler pode ficar aqui
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // WebView Android (evita crash no web)
  if (!kIsWeb && Platform.isAndroid) {
    WebViewPlatform.instance = AndroidWebViewPlatform();
  }

  // ✅ NÃO faça requestPermission / remoteConfig / subscribe aqui antes do runApp
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case '/home':
            builder = (_) => const HomePage();
            break;
          case '/card':
            builder = (_) => const LoveMenuPage();
            break;
          case '/gallery':
            builder = (_) => const GalleryPage();
            break;
          case '/reasons':
            builder = (_) => ReasonsILoveYouPage();
            break;
          case '/our_day':
            builder = (_) => OurDayPage();
            break;
          default:
            builder = (_) => const HomePage();
        }

        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 600),
          settings: settings,
        );
      },
    );
  }
}
