import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SettingsProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          ListTile(title: const Text('直播源地址'), subtitle: Text(sp.iptvSourceUrl)),
          SwitchListTile(title: const Text('直播源精简'), value: sp.iptvSourceSimplify, onChanged: (v) => sp.iptvSourceSimplify = v),
          ListTile(title: const Text('节目单地址'), subtitle: Text(sp.epgXmlUrl)),
          SwitchListTile(title: const Text('启用节目单'), value: sp.epgEnable, onChanged: (v) => sp.epgEnable = v),
          ListTile(title: const Text('画面比例'), subtitle: Text(sp.videoPlayerAspectRatio)),
          SwitchListTile(title: const Text('经典选台界面'), value: sp.uiUseClassicPanel, onChanged: (v) => sp.uiUseClassicPanel = v),
        ],
      ),
    );
  }
}