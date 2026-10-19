import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../models/epg.dart';

class EpgRepository {
  Future<EpgList> getEpgList(String xmlUrl, {List<String> filteredChannels = const []}) async {
    final resp = await http.get(Uri.parse(xmlUrl));
    if (resp.statusCode != 200) throw Exception('HTTP ${resp.statusCode}');
    String body = resp.body;
    // handle gz? assume text
    final doc = XmlDocument.parse(body);
    final epgMap = <String, Epg>{};

    for (final ch in doc.findAllElements('channel')) {
      final id = ch.getAttribute('id') ?? '';
      final name = ch.getElement('display-name')?.innerText ?? id;
      if (filteredChannels.isNotEmpty && !filteredChannels.contains(name)) continue;
      epgMap[id] = Epg(channelName: name, programmes: const EpgProgrammeList());
    }

    for (final prog in doc.findAllElements('programme')) {
      final channelId = prog.getAttribute('channel') ?? '';
      if (!epgMap.containsKey(channelId)) continue;
      final start = prog.getAttribute('start') ?? '';
      final stop = prog.getAttribute('stop') ?? '';
      final title = prog.getElement('title')?.innerText ?? '';
      final epg = epgMap[channelId]!;
      final programmes = List<EpgProgramme>.from(epg.programmes.programmes)
        ..add(EpgProgramme(startAt: _parseTime(start), endAt: _parseTime(stop), title: title));
      epgMap[channelId] = Epg(channelName: epg.channelName, programmes: EpgProgrammeList(programmes: programmes));
    }

    return EpgList(epgs: epgMap.values.toList());
  }

  int _parseTime(String time) {
    if (time.length < 14) return 0;
    // format: yyyyMMddHHmmss +0800
    try {
      final core = time.substring(0, 14);
      // manual parse
      final y = int.parse(core.substring(0, 4));
      final mo = int.parse(core.substring(4, 6));
      final d = int.parse(core.substring(6, 8));
      final h = int.parse(core.substring(8, 10));
      final mi = int.parse(core.substring(10, 12));
      final s = int.parse(core.substring(12, 14));
      final dt = DateTime(y, mo, d, h, mi, s);
      return dt.millisecondsSinceEpoch;
    } catch (_) {
      return 0;
    }
  }
}