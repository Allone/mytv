import 'package:flutter/material.dart';

class WebVideoPlayer extends StatelessWidget {
  final String url;
  const WebVideoPlayer({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.black,
      child: Center(child: Text('Web 播放器', style: TextStyle(color: Colors.white70))),
    );
  }
}