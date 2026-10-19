import 'package:http/http.dart' as http;
import 'iptv_parser.dart';
import '../models/iptv.dart';

class IptvRepository {
  Future<IptvGroupList> getIptvGroupList(String sourceUrl, {bool simplify = false}) async {
    final resp = await http.get(Uri.parse(sourceUrl));
    if (resp.statusCode != 200) throw Exception('HTTP ${resp.statusCode}');
    final parser = IptvParser.instances.firstWhere((p) => p.isSupport(sourceUrl, resp.body));
    final groupList = parser.parse(resp.body);
    if (simplify) {
      // keep cctv and 卫视
      final filtered = groupList.groups.map((g) {
        final list = g.iptvList.where((i) => i.name.toLowerCase().startsWith('cctv') || i.name.endsWith('卫视')).toList();
        return IptvGroup(name: g.name, iptvList: list);
      }).where((g) => g.iptvList.isNotEmpty).toList();
      return IptvGroupList(groups: filtered, epgUrl: groupList.epgUrl);
    }
    return groupList;
  }
}