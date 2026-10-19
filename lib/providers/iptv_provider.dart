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

  Future<void> load({bool forceRefresh = false}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _groupList = await _repo.getIptvGroupList(
        SP.iptvSourceUrl,
        simplify: SP.iptvSourceSimplify,
      );
      // restore last channel
      final last = SP.iptvLastChannel;
      if (last != null && _groupList != null) {
        for (final g in _groupList!.groups) {
          for (final c in g.iptvList) {
            if (c.url == last) _current = c;
          }
        }
      }
    } catch (e) {
      _error = e.toString();
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