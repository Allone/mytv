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
      _epgList = await _repo.getEpgList(url);
    } catch (_) {
      _epgList = const EpgList();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Epg? epgFor(Iptv channel) {
    final list = _epgList?.epgs ?? [];
    // 1. tvg-id 精确匹配
    if (channel.tvgId != null && channel.tvgId!.isNotEmpty) {
      for (final e in list) {
        if (e.channelId == channel.tvgId) return e;
      }
    }
    // 2. 频道名称精确匹配
    for (final e in list) {
      if (e.channelName == channel.name) return e;
    }
    // 3. 归一化模糊匹配（去空格、连字符、HD/高清等）
    final target = _normalize(channel.name);
    for (final e in list) {
      if (_normalize(e.channelName) == target) return e;
    }
    return null;
  }

  String _normalize(String s) {
    return s
        .toLowerCase()
        .replaceAll(RegExp(r'[\s\-_]+'), '')
        .replaceAll('高清', '')
        .replaceAll('标清', '')
        .replaceAll('超清', '')
        .replaceAll('频道', '')
        .replaceAll('hd', '')
        .replaceAll('sd', '')
        .replaceAll('cctv', 'cctv');
  }
}