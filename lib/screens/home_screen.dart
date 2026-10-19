import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/iptv_provider.dart';
import '../providers/epg_provider.dart';
import '../widgets/channel_panel.dart';
import '../widgets/player_area.dart';
import '../widgets/epg_panel.dart';
import 'import_dialog.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final iptv = context.read<IptvProvider>();
      final epg = context.read<EpgProvider>();
      iptv.load().then((_) => epg.load(iptv.groupList));
    });
  }

  @override
  Widget build(BuildContext context) {
    final iptv = context.watch<IptvProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('MyTV'),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add),
            tooltip: '导入直播源',
            onPressed: () => showDialog(context: context, builder: (_) => const ImportDialog()),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: '设置',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 900;
          if (iptv.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (iptv.error != null) {
            return Center(child: Text('加载失败: ${iptv.error}'));
          }
          if (wide) {
            return Row(
              children: [
                SizedBox(width: 320, child: ChannelPanel()),
                const VerticalDivider(width: 1),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(child: PlayerArea()),
                      if (iptv.current != null) EpgPanel(channelName: iptv.current!.name),
                    ],
                  ),
                ),
              ],
            );
          }
          return Column(
            children: [
              SizedBox(height: 240, child: PlayerArea()),
              if (iptv.current != null) SizedBox(height: 80, child: EpgPanel(channelName: iptv.current!.name)),
              Expanded(child: ChannelPanel()),
            ],
          );
        },
      ),
    );
  }
}