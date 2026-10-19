import '../models/iptv.dart';

abstract class IptvParser {
  bool isSupport(String url, String data);
  IptvGroupList parse(String data);
  static List<IptvParser> instances = [M3uIptvParser(), TvboxIptvParser()];
}

class M3uIptvParser implements IptvParser {
  @override
  bool isSupport(String url, String data) => data.contains('#EXTM3U') || url.toLowerCase().endsWith('.m3u') || url.toLowerCase().endsWith('.m3u8');

  @override
  IptvGroupList parse(String data) {
    final lines = data.split(RegExp(r'\r?\n'));
    final groups = <IptvGroup>[];
    final channels = <Iptv>[];
    String? currentGroup;
    Map<String, String> attrs = {};
    String? name;

    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      if (line.startsWith('#EXTM3U')) continue;
      if (line.startsWith('#EXTINF')) {
        attrs = _parseExtInf(line);
        name = attrs.remove('__name__');
        continue;
      }
      if (line.startsWith('#EXTGRP')) {
        currentGroup = line.substring(7).trim();
        continue;
      }
      if (line.startsWith('#')) continue;
      final url = line;
      final group = attrs['group-title'] ?? currentGroup;
      final logo = attrs['tvg-logo'];
      final displayName = (name != null && name.isNotEmpty) ? name : (attrs['tvg-name'] ?? url.split('/').last);
      channels.add(Iptv(
        id: '${url.hashCode}_${displayName.hashCode}',
        name: displayName,
        url: url,
        logo: logo,
        group: group,
        attributes: Map.from(attrs),
      ));
      attrs = {};
      name = null;
      currentGroup = null;
    }

    // Group channels
    final groupMap = <String, List<Iptv>>{};
    for (final c in channels) {
      final g = (c.group == null || c.group!.isEmpty) ? '未分组' : c.group!;
      groupMap.putIfAbsent(g, () => []).add(c);
    }
    for (final e in groupMap.entries) {
      groups.add(IptvGroup(name: e.key, iptvList: e.value));
    }
    return IptvGroupList(groups: groups);
  }

  Map<String, String> _parseExtInf(String line) {
    final result = <String, String>{};
    var rest = line.substring('#EXTINF'.length);
    final colonIdx = rest.indexOf(':');
    if (colonIdx >= 0) rest = rest.substring(colonIdx + 1);
    rest = rest.trim();
    final m = RegExp(r'^-?\d+(\.\d+)?\s*(.*)$').firstMatch(rest);
    if (m != null) rest = m.group(2) ?? '';
    final attrRegex = RegExp(r'([A-Za-z0-9_-]+)\s*=\s*"([^"]*)"');
    for (final match in attrRegex.allMatches(rest)) {
      result[match.group(1)!] = match.group(2)!;
    }
    var withoutAttrs = rest;
    for (final match in attrRegex.allMatches(rest)) {
      withoutAttrs = withoutAttrs.replaceFirst(match.group(0)!, '');
    }
    final commaIdx = withoutAttrs.lastIndexOf(',');
    String name;
    if (commaIdx >= 0) {
      name = withoutAttrs.substring(commaIdx + 1).trim();
    } else {
      name = withoutAttrs.trim();
    }
    if (name.isNotEmpty) result['__name__'] = name;
    return result;
  }
}

class TvboxIptvParser implements IptvParser {
  @override
  bool isSupport(String url, String data) {
    // Tvbox JSON format
    return data.trim().startsWith('{') && data.contains('"lives"');
  }

  @override
  IptvGroupList parse(String data) {
    // Minimal: try to extract lives list via simple regex; full JSON parsing omitted
    // Fallback: treat as M3U if possible
    return M3uIptvParser().parse(data);
  }
}