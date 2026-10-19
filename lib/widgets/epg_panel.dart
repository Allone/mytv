import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/epg_provider.dart';

class EpgPanel extends StatelessWidget {
  final String channelName;
  const EpgPanel({super.key, required this.channelName});

  @override
  Widget build(BuildContext context) {
    final epg = context.watch<EpgProvider>().epgFor(channelName);
    final now = DateTime.now().millisecondsSinceEpoch;
    final programmes = epg?.programmes.programmes ?? [];
    final current = programmes.where((p) => p.startAt <= now && p.endAt >= now).firstOrNull;

    return Container(
      color: Colors.black12,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(channelName, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (current != null) Text('正在播放：${current.title}', maxLines: 1, overflow: TextOverflow.ellipsis),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: programmes.length,
              itemBuilder: (context, i) {
                final p = programmes[i];
                final isNow = p == current;
                return Container(
                  width: 160,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isNow ? Colors.indigo : Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_fmt(p.startAt), style: const TextStyle(fontSize: 10, color: Colors.white70)),
                      Text(p.title, style: const TextStyle(color: Colors.white, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}