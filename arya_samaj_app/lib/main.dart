import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'app.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase
  await Firebase.initializeApp();

  // Background audio service (must be called before runApp)
  await JustAudioBackground.init(
    androidNotificationChannelId: 'arya_samaj_channel',
    androidNotificationChannelName: 'Arya Samaj Audio',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
  );

  // Local storage
  await Hive.initFlutter();
  await Hive.openBox('cache');

  // FCM + local notifications
  await NotificationService.init();

  runApp(const ProviderScope(child: AryaSamajApp()));
}
