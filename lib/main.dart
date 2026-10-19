import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'services/sp.dart';
import 'providers/settings_provider.dart';
import 'providers/iptv_provider.dart';
import 'providers/epg_provider.dart';
import 'providers/player_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await SP.init();
  try {
    await windowManager.ensureInitialized();
    const options = WindowOptions(size: Size(1280, 720), center: true, title: 'MyTV');
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  } catch (_) {}
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => IptvProvider()),
        ChangeNotifierProvider(create: (_) => EpgProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
      ],
      child: const MyTvApp(),
    ),
  );
}