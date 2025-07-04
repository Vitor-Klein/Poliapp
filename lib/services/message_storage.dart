import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> saveMessageLocally(RemoteMessage message) async {
  final prefs = await SharedPreferences.getInstance();
  final existing = prefs.getStringList('push_messages') ?? [];

  final notification = message.notification;
  final data = message.data;

  final title = notification?.title ?? data['title'] ?? '';
  final body = notification?.body ?? data['body'] ?? '';
  final imageUrl =
      notification?.android?.imageUrl ??
      notification?.apple?.imageUrl ??
      data['imageUrl'] ??
      '';

  // 🔍 Filtro: salva só se tiver algum conteúdo
  final hasContent =
      title.trim().isNotEmpty ||
      body.trim().isNotEmpty ||
      imageUrl.trim().isNotEmpty;

  if (!hasContent) return;

  final newMessage = jsonEncode({
    'title': title,
    'body': body,
    'imageUrl': imageUrl,
    'timestamp': DateTime.now().toIso8601String(),
  });

  existing.add(newMessage);
  await prefs.setStringList('push_messages', existing);
}
