import 'package:flutter/foundation.dart';
import '../models/epg.dart';
import '../models/iptv.dart';
import '../services/epg_repository.dart';
import '../services/sp.dart';

class EpgProvider extends ChangeNotifier {
  final EpgRepository _repo = EpgRepository();
  EpgList? _epgList;
  bool _loading = false;
  String? _activeUrl;

  EpgList? get epgList => _epgList;
  bool get loading => _loading;
  String? get activeUrl => _activeUrl;

  Future<void> load(IptvGroupList? groupList) async {
    if (kIsWeb) return; // Web 端 EPG 受 CORS 限制，跳过
    if (!SP.epgEnable) return;
    // 优先使用 M3U 头部自带的 url-tvg；否则使用设置中的自定义地址
    final url = (groupList?.epgUrl != null && groupList!.epgUrl!.isNotEmpty)
        ? groupList.epgUrl!
        : SP.epgXmlUrl;
    if (url.isEmpty) return;
    _activeUrl = url;
    _loading = true;
    notifyListeners();
    try {
      final channels = <String>[];
      for (final c in groupList?.iptvList ?? <Iptv>[]) {
        channels.add(c.name);
        if (c.tvgId != null && c.tvgId!.isNotEmpty) channels.add(c.tvgId!);
      }
      _epgList = await _repo.getEpgList(url, filteredChannels: channels);
    } catch (_) {
      _epgList = const EpgList();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Epg? epgFor(Iptv channel) {
    final list = _epgList?.epgs ?? [];
    // 优先 tvg-id 匹配
    if (channel.tvgId != null && channel.tvgId!.isNotEmpty) {
      for (final e in list) {
        if (e.channelId == channel.tvgId) return e;
      }
    }
    // 其次频道名称匹配
    for (final e in list) {
      if (e.channelName == channel.name) return e;
    }
    return null;
  }
}