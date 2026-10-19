import 'package:flutter/foundation.dart';
import '../models/iptv.dart';
import '../services/iptv_repository.dart';
import '../services/sp.dart';

class IptvProvider extends ChangeNotifier {
  final IptvRepository _repo = IptvRepository();
  IptvGroupList? _groupList;
  bool _loading = false;
  String? _error;

  IptvGroupList? get groupList => _groupList;
  bool get loading => _loading;
  String? get error => _error;

  Iptv? _current;
  Iptv? get current => _current;

  static const String defaultSourceHint =
      '当前使用的是默认示例直播源，无法加载。\n请点击「导入直播源」添加你的 M3U 列表地址。';

  Future<void> load({bool forceRefresh = false}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _groupList = await _repo.getIptvGroupList(
        SP.iptvSourceUrl,
        simplify: SP.iptvSourceSimplify,
      );
      // 恢复上次播放的频道；找不到时默认播放列表第一个频道
      _current = null;
      final last = SP.iptvLastChannel;
      Iptv? first;
      if (_groupList != null) {
        outer:
        for (final g in _groupList!.groups) {
          for (final c in g.iptvList) {
            first ??= c;
            if (last != null && c.url == last) {
              _current = c;
              break outer;
            }
          }
        }
      }
      _current ??= first;
      if (_current != null) SP.iptvLastChannel = _current!.url;

      if (_groupList == null || _groupList!.groups.isEmpty) {
        _error = SP.isDefaultSource
            ? defaultSourceHint
            : '直播源解析成功，但没有可用频道，请检查列表内容。';
      }
    } catch (e) {
      _current = null;
      _error = SP.isDefaultSource
          ? defaultSourceHint
          : '加载失败：$e\n请检查直播源地址是否可访问。';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void select(Iptv c) {
    _current = c;
    SP.iptvLastChannel = c.url;
    notifyListeners();
  }

  bool isFavorite(Iptv c) => SP.favoriteChannels.contains(c.url);

  void toggleFavorite(Iptv c) {
    final set = Set<String>.from(SP.favoriteChannels);
    if (set.contains(c.url)) {
      set.remove(c.url);
    } else {
      set.add(c.url);
    }
    SP.favoriteChannels = set;
    notifyListeners();
  }
}