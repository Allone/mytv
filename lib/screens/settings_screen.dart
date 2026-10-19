import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/iptv_provider.dart';
import '../providers/epg_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _iptvCtrl;
  late final TextEditingController _epgCtrl;

  @override
  void initState() {
    super.initState();
    final sp = context.read<SettingsProvider>();
    _iptvCtrl = TextEditingController(text: sp.iptvSourceUrl);
    _epgCtrl = TextEditingController(text: sp.epgXmlUrl);
  }

  @override
  void dispose() {
    _iptvCtrl.dispose();
    _epgCtrl.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final sp = context.read<SettingsProvider>();
    sp.iptvSourceUrl = _iptvCtrl.text.trim();
    sp.epgXmlUrl = _epgCtrl.text.trim();
    final iptv = context.read<IptvProvider>();
    await iptv.load();
    if (mounted) await context.read<EpgProvider>().load(iptv.groupList);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已重新加载')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SettingsProvider>();
    final epg = context.watch<EpgProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('直播源', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _iptvCtrl,
            decoration: const InputDecoration(
              labelText: 'M3U / Tvbox 地址',
              border: OutlineInputBorder(),
            ),
          ),
          SwitchListTile(
            title: const Text('直播源精简'),
            value: sp.iptvSourceSimplify,
            onChanged: (v) => sp.iptvSourceSimplify = v,
          ),
          const Divider(height: 32),
          const Text('节目单', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _epgCtrl,
            decoration: const InputDecoration(
              labelText: '自定义 EPG 地址（xml / xml.gz）',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '提示：默认优先使用 M3U 头部自带的 url-tvg / x-tvg-url；未提供时使用此处填写的地址。',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
          ),
          SwitchListTile(
            title: const Text('优先使用 M3U 自带节目单'),
            subtitle: const Text('关闭后始终使用上方自定义地址'),
            value: sp.epgPreferM3u,
            onChanged: (v) => sp.epgPreferM3u = v,
          ),
          if (epg.activeUrl != null)
            ListTile(
              title: const Text('当前节目单来源'),
              subtitle: Text(epg.activeUrl!, style: const TextStyle(fontSize: 12)),
            ),
          SwitchListTile(
            title: const Text('启用节目单'),
            value: sp.epgEnable,
            onChanged: (v) => sp.epgEnable = v,
          ),
          const Divider(height: 32),
          const Text('界面', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SwitchListTile(
            title: const Text('经典选台界面'),
            subtitle: const Text('三栏选台面板：分组 / 频道 / 节目单'),
            value: sp.uiUseClassicPanel,
            onChanged: (v) => sp.uiUseClassicPanel = v,
          ),
          const Divider(height: 32),
          const Text('播放器', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ListTile(
            title: const Text('画面比例'),
            subtitle: Text(sp.videoPlayerAspectRatio),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
            label: const Text('保存并重新加载'),
          ),
        ],
      ),
    );
  }
}