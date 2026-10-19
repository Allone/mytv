import 'package:flutter/foundation.dart';
import '../models/epg.dart';
import '../models/iptv.dart';
import '../services/epg_repository.dart';
import '../services/sp.dart';

class EpgProvider extends ChangeNotifier {
  final EpgRepository _repo = EpgRepository();
  EpgList? _epgList;
  bool _loading = false;

  EpgList? get epgList => _epgList;
  bool get loading => _loading;

  Future<void> load(IptvGroupList? groupList) async {
    if (kIsWeb) return; // Web 端 EPG 受 CORS 限制，跳过
    if (!SP.epgEnable) return;
    _loading = true;
    notifyListeners();
    try {
      final channels = groupList?.iptvList.map((e) => e.name).toList() ?? [];
      _epgList = await _repo.getEpgList(SP.epgXmlUrl, filteredChannels: channels);
    } catch (_) {
      _epgList = const EpgList();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Epg? epgFor(String channelName) {
    return _epgList?.epgs.firstWhere(
      (e) => e.channelName == channelName,
      orElse: () => const Epg(channelName: '', programmes: EpgProgrammeList()),
    );
  }
}