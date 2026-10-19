import 'package:flutter/foundation.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import '../models/iptv.dart';

class PlayerProvider extends ChangeNotifier {
  Player? _player;
  VideoController? _controller;

  Player get player => _player!;
  VideoController get controller => _controller!;

  Iptv? _current;
  bool _buffering = false;
  String? _error;
  bool _playing = false;
  bool _webVideoVisible = true;

  bool get webVideoVisible => _webVideoVisible;
  void setWebVideoVisible(bool v) {
    if (_webVideoVisible == v) return;
    _webVideoVisible = v;
    notifyListeners();
  }

  PlayerProvider() {
    if (!kIsWeb) {
      _player = Player();
      _controller = VideoController(_player!);
      _player!.stream.playing.listen((v) { _playing = v; notifyListeners(); });
      _player!.stream.buffering.listen((v) { _buffering = v; notifyListeners(); });
      _player!.stream.error.listen((e) {
        if (e.isEmpty) return;
        // mpv 对不可 seek 流的提示，不影响正常播放，不作为致命错误展示
        if (e.contains('force-seekable') || e.contains('Cannot seek')) return;
        _error = e;
        notifyListeners();
      });
    }
  }

  Iptv? get current => _current;
  bool get buffering => _buffering;
  String? get error => _error;
  bool get playing => _playing;

  Future<void> play(Iptv c) async {
    _current = c;
    _error = null;
    notifyListeners();
    if (kIsWeb) return; // Web 使用 <video> 组件播放
    try {
      // 允许对不可 seek 的直播流进行 seek，避免 mpv 报错
      final platform = _player!.platform;
      if (platform != null) {
        await (platform as dynamic).setProperty('force-seekable', 'yes');
      }
    } catch (_) {}
    try {
      await _player!.open(Media(c.url)).timeout(const Duration(seconds: 15));
      await _player!.play().timeout(const Duration(seconds: 15));
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggle() async {
    if (kIsWeb || _player == null) return;
    if (_playing) {
      await _player!.pause();
    } else {
      await _player!.play();
    }
  }

  Future<void> stop() async {
    if (!kIsWeb && _player != null) await _player!.stop();
    _current = null;
    notifyListeners();
  }

  Future<void> setVolume(double v) async {
    if (kIsWeb || _player == null) return;
    try {
      await _player!.setVolume(v * 100).timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }
}