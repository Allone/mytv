import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../models/iptv.dart';

class PlayerProvider extends ChangeNotifier {
  late final Player player;
  late final VideoController controller;

  Iptv? _current;
  bool _buffering = false;
  String? _error;
  bool _playing = false;

  PlayerProvider() {
    player = Player();
    controller = VideoController(player);
    player.stream.playing.listen((v) { _playing = v; notifyListeners(); });
    player.stream.buffering.listen((v) { _buffering = v; notifyListeners(); });
    player.stream.error.listen((e) { if (e.isNotEmpty) { _error = e; notifyListeners(); } });
  }

  Iptv? get current => _current;
  bool get buffering => _buffering;
  String? get error => _error;
  bool get playing => _playing;

  Future<void> play(Iptv c) async {
    _current = c;
    _error = null;
    notifyListeners();
    try {
      await player.open(Media(c.url)).timeout(const Duration(seconds: 15));
      await player.play().timeout(const Duration(seconds: 15));
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggle() async {
    if (_playing) {
      await player.pause();
    } else {
      await player.play();
    }
  }

  Future<void> stop() async {
    await player.stop();
    _current = null;
    notifyListeners();
  }

  Future<void> setVolume(double v) async {
    if (kIsWeb) {
      return;
    }
    try {
      await player.setVolume(v * 100).timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}