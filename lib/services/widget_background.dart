import 'dart:io';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';

import '../firebase_options.dart';

const String kWidgetTextKey = 'home_widget_text';

// ✅ Galeria (Foto do dia)
const String kGalleryIndexKey = 'gallery_widget_index';
const int kGalleryCount = 34;

// ✅ Workmanager
const String kWorkName = 'poli_widget_update_work';
const String kTaskName = 'poli_widget_update_task';

int _fnv1a32(String input) {
  const int fnvPrime = 16777619;
  int hash = 2166136261;
  for (final c in input.codeUnits) {
    hash ^= c;
    hash = (hash * fnvPrime) & 0xFFFFFFFF;
  }
  return hash;
}

/// Escolhe uma foto “aleatória do dia”, mas estável no mesmo dia.
/// Retorna 1..34 (compatível com nos1..nos34)
int pickDailyPhotoIndex() {
  final now = DateTime.now();
  final ymd =
      '${now.year.toString().padLeft(4, '0')}-'
      '${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';

  final h = _fnv1a32(ymd);
  return (h % kGalleryCount) + 1; // 1..34
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // garante registro de plugins no isolate de background
    DartPluginRegistrant.ensureInitialized();

    // Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Remote Config (se você quiser mandar legenda/título pro widget no futuro,
    // já está aqui pronto)
    final rc = FirebaseRemoteConfig.instance;
    await rc.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        // ⚠️ não adianta ser menor que o intervalo do WorkManager
        minimumFetchInterval: const Duration(minutes: 15),
      ),
    );

    await rc.fetchAndActivate();

    // ----------------------------
    // Widget 1: Texto
    // ----------------------------
    final text = rc.getString(kWidgetTextKey).trim();
    final safeText = text.isEmpty ? 'Abra o app ❤️' : text;

    await HomeWidget.saveWidgetData<String>(kWidgetTextKey, safeText);
    await HomeWidget.updateWidget(name: 'PoliHomeWidgetProvider');

    // ----------------------------
    // Widget 2: Galeria (Foto do dia)
    // ----------------------------
    final int dailyIndex = pickDailyPhotoIndex();

    // salva o índice 1..34 pro provider Kotlin ler
    await HomeWidget.saveWidgetData<int>(kGalleryIndexKey, dailyIndex);

    // força o update do widget de galeria
    await HomeWidget.updateWidget(name: 'PoliGalleryWidgetProvider');

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

    // ⚠️ Android/WorkManager: periódico mínimo real é 15 minutos.
    // Se você deixar 1 minuto, o plugin pode aceitar, mas o SO não garante.
    frequency: const Duration(minutes: 15),

    constraints: Constraints(networkType: NetworkType.connected),

    // para tarefas periódicas
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
  );
}
