import 'dart:html' as html;
import 'dart:js_util' as js_util;

import 'package:flutter/material.dart';

/// Web 端使用原生 <video> + hls.js 播放，直接挂载到 body 并覆盖在播放器区域上。
class WebVideoPlayer extends StatefulWidget {
  final String url;
  const WebVideoPlayer({super.key, required this.url});

  @override
  State<WebVideoPlayer> createState() => _WebVideoPlayerState();
}

class _WebVideoPlayerState extends State<WebVideoPlayer> {
  final GlobalKey _key = GlobalKey();
  late final html.VideoElement _video;
  dynamic _hls;

  @override
  void initState() {
    super.initState();
    _video = html.VideoElement()
      ..controls = true
      ..autoplay = true
      ..setAttribute('playsinline', '')
      ..style.position = 'absolute'
      ..style.objectFit = 'contain'
      ..style.background = '#000'
      ..style.zIndex = '9999';
    html.document.body?.append(_video);
    _load(widget.url);
    // 用户点击频道属于用户手势，尝试自动播放
    _video.play().catchError((_) {});
    WidgetsBinding.instance.addPostFrameCallback((_) => _updatePosition());
  }

  void _load(String url) {
    final isHls = url.toLowerCase().contains('.m3u8');
    final hlsCtor = js_util.getProperty(js_util.globalThis, 'Hls');
    if (isHls && hlsCtor != null && js_util.callMethod(hlsCtor, 'isSupported', <dynamic>[])) {
      _hls = js_util.callConstructor(hlsCtor, <dynamic>[]);
      js_util.callMethod(_hls, 'loadSource', <dynamic>[url]);
      js_util.callMethod(_hls, 'attachMedia', <dynamic>[_video]);
    } else {
      _video.src = url;
    }
  }

  void _updatePosition() {
    final ctx = _key.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    final offset = box.localToGlobal(Offset.zero);
    _video.style
      ..left = '${offset.dx}px'
      ..top = '${offset.dy}px'
      ..width = '${box.size.width}px'
      ..height = '${box.size.height}px';
  }

  @override
  void didUpdateWidget(covariant WebVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      if (_hls != null) {
        try {
          js_util.callMethod(_hls, 'destroy', <dynamic>[]);
        } catch (_) {}
        _hls = null;
      }
      _video.removeAttribute('src');
      _load(widget.url);
    }
  }

  @override
  void dispose() {
    if (_hls != null) {
      try {
        js_util.callMethod(_hls, 'destroy', <dynamic>[]);
      } catch (_) {}
    }
    _video.pause();
    _video.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _updatePosition());
    return SizedBox.expand(
      key: _key,
      child: const ColoredBox(color: Colors.black),
    );
  }
}