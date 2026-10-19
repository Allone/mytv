import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';

class PlayerArea extends StatelessWidget {
  const PlayerArea({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerProvider>();
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (player.current != null)
            Video(controller: player.controller, controls: MaterialVideoControls)
          else
            const Center(child: Text('请选择频道', style: TextStyle(color: Colors.white70))),
          if (player.current != null)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                child: Text(player.current!.name, style: const TextStyle(color: Colors.white)),
              ),
            ),
          if (player.buffering)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          if (player.error != null)
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.red.shade700,
                child: Text('播放错误：${player.error}', style: const TextStyle(color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}