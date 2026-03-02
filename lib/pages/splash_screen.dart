import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../services/widget_background.dart';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static String routeName = 'SplashScreen';
  static String routePath = '/splashScreen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // roda bootstrap + garante splash por no mínimo 3s
      final minSplash = Future.delayed(const Duration(seconds: 3));
      final boot = _bootstrap();

      await Future.wait([minSplash, boot]);

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 2000),
          pageBuilder: (_, animation, __) => const HomePage(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  Future<void> _bootstrap() async {
    // Remote Config
    try {
      final rc = FirebaseRemoteConfig.instance;
      await rc.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          // em dev pode ser baixo; em produção recomendo minutos/horas
          minimumFetchInterval: const Duration(minutes: 1),
        ),
      );
      await rc.fetchAndActivate();
    } catch (e) {
      debugPrint('RemoteConfig falhou: $e');
    }

    // Push permission + topic
    try {
      final messaging = FirebaseMessaging.instance;

      await messaging.requestPermission(alert: true, badge: true, sound: true);

      // ⚠️ isso pode falhar (SERVICE_NOT_AVAILABLE). Não pode travar o app.
      await messaging
          .subscribeToTopic('all')
          .timeout(const Duration(seconds: 6));
    } catch (e) {
      debugPrint('FCM subscribe/permission falhou: $e');
    }

    // Widget background (se existir no seu app)
    try {
      await registerWidgetBackgroundSync();
    } catch (e) {
      debugPrint('Widget background falhou: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: const Color.fromRGBO(247, 242, 222, 1),
      body: SizedBox.expand(
        child: Image.asset('assets/splash.png', fit: BoxFit.cover),
      ),
    );
  }
}
