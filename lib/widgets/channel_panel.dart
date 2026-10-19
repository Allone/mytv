import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/iptv_provider.dart';
import '../providers/player_provider.dart';

class ChannelPanel extends StatefulWidget {
  const ChannelPanel({super.key});

  @override
  State<ChannelPanel> createState() => _ChannelPanelState();
}

class _ChannelPanelState extends State<ChannelPanel> {
  final _search = TextEditingController();
  String? _group;

  @override
  Widget build(BuildContext context) {
    final iptv = context.watch<IptvProvider>();
    final player = context.read<PlayerProvider>();
    final groups = iptv.groupList?.groups ?? [];
    final channels = iptv.groupList?.groups
            .where((g) => _group == null || g.name == _group)
            .expand((g) => g.iptvList)
            .where((c) => _search.text.isEmpty || c.name.toLowerCase().contains(_search.text.toLowerCase()))
            .toList() ??
        [];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            controller: _search,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: '搜索频道', border: OutlineInputBorder(), isDense: true),
            onChanged: (_) => setState(() {}),
          ),
        ),
        if (groups.length > 1)
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                _chip(null, '全部'),
                ...groups.map((g) => _chip(g.name, g.name)),
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: channels.length,
            itemBuilder: (context, i) {
              final c = channels[i];
              final fav = iptv.isFavorite(c);
              return ListTile(
                leading: c.logo != null && c.logo!.isNotEmpty
                    ? CachedNetworkImage(imageUrl: c.logo!, width: 36, height: 36, fit: BoxFit.cover, errorWidget: (_, __, ___) => const Icon(Icons.tv))
                    : const Icon(Icons.tv),
                title: Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(c.group ?? '', maxLines: 1),
                trailing: IconButton(
                  icon: Icon(fav ? Icons.favorite : Icons.favorite_border, color: fav ? Colors.red : null),
                  onPressed: () => iptv.toggleFavorite(c),
                ),
                selected: iptv.current?.url == c.url,
                onTap: () {
                  iptv.select(c);
                  player.play(c);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _chip(String? value, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(label: Text(label), selected: _group == value, onSelected: (_) => setState(() => _group = value)),
    );
  }
}