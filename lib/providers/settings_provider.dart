import 'package:flutter/foundation.dart';
import '../services/sp.dart';

class SettingsProvider extends ChangeNotifier {
  String get iptvSourceUrl => SP.iptvSourceUrl;
  set iptvSourceUrl(String v) { SP.iptvSourceUrl = v; notifyListeners(); }

  int get iptvSourceCacheTime => SP.iptvSourceCacheTime;
  set iptvSourceCacheTime(int v) { SP.iptvSourceCacheTime = v; notifyListeners(); }

  bool get iptvSourceSimplify => SP.iptvSourceSimplify;
  set iptvSourceSimplify(bool v) { SP.iptvSourceSimplify = v; notifyListeners(); }

  bool get epgEnable => SP.epgEnable;
  set epgEnable(bool v) { SP.epgEnable = v; notifyListeners(); }

  String get epgXmlUrl => SP.epgXmlUrl;
  set epgXmlUrl(String v) { SP.epgXmlUrl = v; notifyListeners(); }

  bool get epgPreferM3u => SP.epgPreferM3u;
  set epgPreferM3u(bool v) { SP.epgPreferM3u = v; notifyListeners(); }

  double get uiDensityScale => SP.uiDensityScale;
  set uiDensityScale(double v) { SP.uiDensityScale = v; notifyListeners(); }

  double get uiFontScale => SP.uiFontScale;
  set uiFontScale(double v) { SP.uiFontScale = v; notifyListeners(); }

  bool get uiUseClassicPanel => SP.uiUseClassicPanel;
  set uiUseClassicPanel(bool v) { SP.uiUseClassicPanel = v; notifyListeners(); }

  String get videoPlayerUserAgent => SP.videoPlayerUserAgent;
  set videoPlayerUserAgent(String v) { SP.videoPlayerUserAgent = v; notifyListeners(); }

  int get videoPlayerLoadTimeout => SP.videoPlayerLoadTimeout;
  set videoPlayerLoadTimeout(int v) { SP.videoPlayerLoadTimeout = v; notifyListeners(); }

  String get videoPlayerAspectRatio => SP.videoPlayerAspectRatio;
  set videoPlayerAspectRatio(String v) { SP.videoPlayerAspectRatio = v; notifyListeners(); }

  Set<String> get favoriteChannels => SP.favoriteChannels;
  set favoriteChannels(Set<String> v) { SP.favoriteChannels = v; notifyListeners(); }
}