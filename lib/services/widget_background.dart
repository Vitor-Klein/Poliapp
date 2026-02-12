import 'dart:io';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';

import '../firebase_options.dart';

const String kWidgetTextKey = 'home_widget_text';
const String kWorkName = 'poli_widget_update_work';
const String kTaskName = 'poli_widget_update_task';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // garante registro de plugins no isolate de background
    DartPluginRegistrant.ensureInitialized();

    // Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Remote Config
    final rc = FirebaseRemoteConfig.instance;
    await rc.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        // ⚠️ não adianta ser menor que o intervalo do WorkManager
        minimumFetchInterval: const Duration(minutes: 15),
      ),
    );

    await rc.fetchAndActivate();

    final text = rc.getString(kWidgetTextKey).trim();
    final safeText = text.isEmpty ? 'Abra o app ❤️' : text;

    // salva no storage que o widget Android lê
    await HomeWidget.saveWidgetData<String>(kWidgetTextKey, safeText);

    // força o update do widget
    await HomeWidget.updateWidget(
      name: 'PoliHomeWidgetProvider',
      // iOSName não precisa (você não vai ter iOS)
    );

    return Future.value(true);
  });
}

/// chama isso UMA VEZ quando o app abre (pra agendar o job)
Future<void> registerWidgetBackgroundSync() async {
  if (!Platform.isAndroid) return;

  Workmanager().initialize(callbackDispatcher);

  await Workmanager().registerPeriodicTask(
    kWorkName,
    kTaskName,
    frequency: const Duration(minutes: 1),
    constraints: Constraints(networkType: NetworkType.connected),

    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
}
