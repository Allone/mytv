import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/iptv_provider.dart';
import '../providers/player_provider.dart';
import '../providers/epg_provider.dart';
import '../models/epg.dart';

/// 经典选台界面：分组 / 频道 / 节目单 三栏
class ClassicPanel extends StatefulWidget {
  final VoidCallback? onClose;
  const ClassicPanel({super.key, this.onClose});

  @override
  State<ClassicPanel> createState() => _ClassicPanelState();
}

class _ClassicPanelState extends State<ClassicPanel> {
  String? _group;

  @override
  Widget build(BuildContext context) {
    final iptv = context.watch<IptvProvider>();
    final epg = context.watch<EpgProvider>();
    final groups = iptv.groupList?.groups ?? [];
    final selectedGroup = _group ?? (groups.isNotEmpty ? groups.first.name : null);
    final channels = groups.where((g) => g.name == selectedGroup).expand((g) => g.iptvList).toList();
    final current = iptv.current;
    final currentEpg = current == null ? null : epg.epgFor(current);

    return Container(
      color: Colors.black.withValues(alpha: 0.92),
      child: Row(
        children: [
          // 分组
          SizedBox(
            width: 150,
            child: ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, i) {
                final g = groups[i];
                final selected = g.name == selectedGroup;
                return ListTile(
                  dense: true,
                  selected: selected,
                  title: Text(g.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  onTap: () => setState(() => _group = g.name),
                );
              },
            ),
          ),
          const VerticalDivider(width: 1, color: Colors.white24),
          // 频道
          SizedBox(
            width: 240,
            child: ListView.builder(
              itemCount: channels.length,
              itemBuilder: (context, i) {
                final c = channels[i];
                final selected = current?.url == c.url;
                return ListTile(
                  dense: true,
                  selected: selected,
                  leading: const Icon(Icons.tv, size: 18),
                  title: Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                  onTap: () {
                    iptv.select(c);
                    context.read<PlayerProvider>().play(c);
                    widget.onClose?.call();
                  },
                );
              },
            ),
          ),
          const VerticalDivider(width: 1, color: Colors.white24),
          // 节目单
          Expanded(
            child: current == null
                ? const Center(child: Text('请选择频道', style: TextStyle(color: Colors.white54)))
                : _EpgColumn(channelName: current.name, epg: currentEpg),
          ),
        ],
      ),
    );
  }
}

class _EpgColumn extends StatelessWidget {
  final String channelName;
  final Epg? epg;
  const _EpgColumn({required this.channelName, required this.epg});

  @override
  Widget build(BuildContext context) {
    final programmes = epg?.programmes.programmes ?? [];
    final now = DateTime.now().millisecondsSinceEpoch;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(channelName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: programmes.isEmpty
              ? const Center(child: Text('暂无节目单', style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  itemCount: programmes.length,
                  itemBuilder: (context, i) {
                    final p = programmes[i];
                    final isNow = p.startAt <= now && p.endAt >= now;
                    return ListTile(
                      dense: true,
                      selected: isNow,
                      leading: Text(
                        _fmt(p.startAt),
                        style: TextStyle(color: isNow ? Colors.indigoAccent : Colors.white54, fontSize: 12),
                      ),
                      title: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _fmt(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}