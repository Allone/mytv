import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/iptv_provider.dart';
import '../providers/epg_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/channel_panel.dart';
import '../widgets/player_area.dart';
import '../widgets/epg_panel.dart';
import '../widgets/classic_panel.dart';
import 'import_dialog.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _classicOpen = false;

  void _setClassicOpen(bool open) {
    setState(() => _classicOpen = open);
    context.read<PlayerProvider>().setWebVideoVisible(!open);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final iptv = context.read<IptvProvider>();
      final epg = context.read<EpgProvider>();
      iptv.load().then((_) {
        epg.load(iptv.groupList);
        if (!mounted) return;
        final c = iptv.current;
        if (iptv.error == null && c != null) {
          context.read<PlayerProvider>().play(c);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final classic = settings.uiUseClassicPanel;
    if (!classic && !_classicOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<PlayerProvider>().setWebVideoVisible(true);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('MyTV'),
        actions: [
          if (classic)
            IconButton(
              icon: const Icon(Icons.grid_view),
              tooltip: '经典选台',
              onPressed: () => _setClassicOpen(!_classicOpen),
            ),
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
          final iptv = context.watch<IptvProvider>();
          if (iptv.loading) return const Center(child: CircularProgressIndicator());
          if (iptv.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.signal_wifi_off, size: 48, color: Colors.white38),
                    const SizedBox(height: 12),
                    Text(
                      iptv.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      icon: const Icon(Icons.playlist_add),
                      label: const Text('导入直播源'),
                      onPressed: () => showDialog(context: context, builder: (_) => const ImportDialog()),
                    ),
                  ],
                ),
              ),
            );
          }

          if (classic) {
            return Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => _setClassicOpen(true),
                    child: PlayerArea(),
                  ),
                ),
                if (_classicOpen)
                  Positioned.fill(
                    child: ClassicPanel(onClose: () => _setClassicOpen(false)),
                  ),
              ],
            );
          }

          final wide = constraints.maxWidth >= 900;
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
                      if (iptv.current != null)
                        SizedBox(height: 110, child: EpgPanel(channel: iptv.current!)),
                    ],
                  ),
                ),
              ],
            );
          }
          return Column(
            children: [
              SizedBox(height: 240, child: PlayerArea()),
              if (iptv.current != null) SizedBox(height: 80, child: EpgPanel(channel: iptv.current!)),
              Expanded(child: ChannelPanel()),
            ],
          );
        },
      ),
    );
  }
}