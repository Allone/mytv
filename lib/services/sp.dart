import 'package:shared_preferences/shared_preferences.dart';

class SP {
  static late SharedPreferences _sp;
  static Future<void> init() async => _sp = await SharedPreferences.getInstance();

  static String _s(String k, String d) => _sp.getString(k) ?? d;
  static Future<void> _ss(String k, String v) => _sp.setString(k, v);
  static bool _b(String k, bool d) => _sp.getBool(k) ?? d;
  static Future<void> _sb(String k, bool v) => _sp.setBool(k, v);
  static int _i(String k, int d) => _sp.getInt(k) ?? d;
  static Future<void> _si(String k, int v) => _sp.setInt(k, v);
  static double _d(String k, double d) => _sp.getDouble(k) ?? d;
  static Future<void> _sd(String k, double v) => _sp.setDouble(k, v);

  // IPTV
  static String get iptvSourceUrl => _s('iptv_source_url', 'http://1.2.3.4/live.m3u');
  static set iptvSourceUrl(String v) => _ss('iptv_source_url', v);

  static int get iptvSourceCacheTime => _i('iptv_source_cache_time', 86400000);
  static set iptvSourceCacheTime(int v) => _si('iptv_source_cache_time', v);

  static bool get iptvSourceSimplify => _b('iptv_source_simplify', false);
  static set iptvSourceSimplify(bool v) => _sb('iptv_source_simplify', v);

  static String? get iptvLastChannel => _sp.getString('iptv_last_channel');
  static set iptvLastChannel(String? v) {
    if (v == null) {
      _sp.remove('iptv_last_channel');
    } else {
      _sp.setString('iptv_last_channel', v);
    }
  }

  // EPG
  static bool get epgEnable => _b('epg_enable', true);
  static set epgEnable(bool v) => _sb('epg_enable', v);

  static String get epgXmlUrl => _s('epg_xml_url', 'http://epg.51zmt.top:8000/e.xml.gz');
  static set epgXmlUrl(String v) => _ss('epg_xml_url', v);

  static bool get epgPreferM3u => _b('epg_prefer_m3u', true);
  static set epgPreferM3u(bool v) => _sb('epg_prefer_m3u', v);

  // UI
  static double get uiDensityScale => _d('ui_density_scale', 1.0);
  static set uiDensityScale(double v) => _sd('ui_density_scale', v);

  static double get uiFontScale => _d('ui_font_scale', 1.0);
  static set uiFontScale(double v) => _sd('ui_font_scale', v);

  static bool get uiUseClassicPanel => _b('ui_use_classic_panel', false);
  static set uiUseClassicPanel(bool v) => _sb('ui_use_classic_panel', v);

  // Player
  static String get videoPlayerUserAgent => _s('video_player_ua', 'ExoPlayer');
  static set videoPlayerUserAgent(String v) => _ss('video_player_ua', v);

  static int get videoPlayerLoadTimeout => _i('video_player_load_timeout', 15000);
  static set videoPlayerLoadTimeout(int v) => _si('video_player_load_timeout', v);

  static String get videoPlayerAspectRatio => _s('video_player_aspect_ratio', 'default');
  static set videoPlayerAspectRatio(String v) => _ss('video_player_aspect_ratio', v);

  // Favorites
  static Set<String> get favoriteChannels => _sp.getStringList('favorite_channels')?.toSet() ?? {};
  static set favoriteChannels(Set<String> v) => _sp.setStringList('favorite_channels', v.toList());
}