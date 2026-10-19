import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

import '../models/epg.dart';

class EpgRepository {
  Future<EpgList> getEpgList(String xmlUrl, {List<String> filteredChannels = const []}) async {
    final resp = await http.get(Uri.parse(xmlUrl));
    if (resp.statusCode != 200) throw Exception('HTTP ${resp.statusCode}');

    String body;
    final bytes = resp.bodyBytes;
    if (bytes.length > 2 && bytes[0] == 0x1f && bytes[1] == 0x8b) {
      // .xml.gz 文件：gzip 压缩内容
      final decompressed = GZipDecoder().decodeBytes(bytes);
      body = utf8.decode(decompressed);
    } else {
      body = utf8.decode(bytes);
    }

    final doc = XmlDocument.parse(body);
    final epgMap = <String, Epg>{};

    for (final ch in doc.findAllElements('channel')) {
      final id = ch.getAttribute('id') ?? '';
      final name = ch.getElement('display-name')?.innerText ?? id;
      epgMap[id] = Epg(
        channelName: name,
        channelId: id,
        programmes: const EpgProgrammeList(),
      );
    }

    for (final prog in doc.findAllElements('programme')) {
      final channelId = prog.getAttribute('channel') ?? '';
      if (!epgMap.containsKey(channelId)) continue;
      final start = prog.getAttribute('start') ?? '';
      final stop = prog.getAttribute('stop') ?? '';
      final title = prog.getElement('title')?.innerText ?? '';
      final epg = epgMap[channelId]!;
      final programmes = List<EpgProgramme>.from(epg.programmes.programmes)
        ..add(EpgProgramme(
          startAt: _parseTime(start),
          endAt: _parseTime(stop),
          title: title,
        ));
      epgMap[channelId] = Epg(
        channelName: epg.channelName,
        channelId: epg.channelId,
        programmes: EpgProgrammeList(programmes: programmes),
      );
    }

    return EpgList(epgs: epgMap.values.toList());
  }

  int _parseTime(String time) {
    if (time.length < 14) return 0;
    try {
      final core = time.substring(0, 14);
      final y = int.parse(core.substring(0, 4));
      final mo = int.parse(core.substring(4, 6));
      final d = int.parse(core.substring(6, 8));
      final h = int.parse(core.substring(8, 10));
      final mi = int.parse(core.substring(10, 12));
      final s = int.parse(core.substring(12, 14));
      // 优先按 XML 中的时区偏移解析
      final dt = DateTime.utc(y, mo, d, h, mi, s);
      final offsetMatch = RegExp(r'([+-]\d{4})').firstMatch(time);
      if (offsetMatch != null) {
        final off = offsetMatch.group(1)!;
        final sign = off[0] == '-' ? -1 : 1;
        final oh = int.parse(off.substring(1, 3));
        final om = int.parse(off.substring(3, 5));
        final offset = Duration(hours: oh, minutes: om) * sign;
        return dt.subtract(offset).millisecondsSinceEpoch;
      }
      return dt.millisecondsSinceEpoch;
    } catch (_) {
      return 0;
    }
  }
}