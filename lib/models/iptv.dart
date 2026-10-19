class Iptv {
  final String id;
  final String name;
  final String url;
  final String? logo;
  final String? group;
  final Map<String, String> attributes;

  const Iptv({
    required this.id,
    required this.name,
    required this.url,
    this.logo,
    this.group,
    this.attributes = const {},
  });
}

class IptvGroup {
  final String name;
  final List<Iptv> iptvList;
  const IptvGroup({required this.name, required this.iptvList});
}

class IptvGroupList {
  final List<IptvGroup> groups;
  const IptvGroupList({this.groups = const []});
  List<Iptv> get iptvList => groups.expand((g) => g.iptvList).toList();
  int get size => groups.length;
}