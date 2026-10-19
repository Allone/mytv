import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/iptv_provider.dart';
import '../providers/epg_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/player_provider.dart';

class ImportDialog extends StatefulWidget {
  const ImportDialog({super.key});

  @override
  State<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<ImportDialog> {
  final _urlCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('导入直播源'),
      content: TextField(
        controller: _urlCtrl,
        decoration: const InputDecoration(labelText: 'M3U/Tvbox 链接', border: OutlineInputBorder()),
      ),
      actions: [
        if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
        FilledButton(
          onPressed: _loading
              ? null
              : () async {
                  final url = _urlCtrl.text.trim();
                  if (url.isEmpty) {
                    setState(() => _error = '请输入直播源链接');
                    return;
                  }
                  setState(() { _loading = true; _error = null; });
                  // override source url
                  context.read<SettingsProvider>().iptvSourceUrl = url;
                  final iptv = context.read<IptvProvider>();
                  await iptv.load(forceRefresh: true);
                  if (!mounted) return;
                  if (iptv.error != null) {
                    setState(() { _error = iptv.error; _loading = false; });
                    return;
                  }
                  if (!context.mounted) return;
                  await context.read<EpgProvider>().load(iptv.groupList);
                  if (!mounted) return;
                  setState(() => _loading = false);
                  final c = iptv.current;
                  if (c != null && context.mounted) {
                    context.read<PlayerProvider>().play(c);
                    Navigator.pop(context);
                  } else {
                    setState(() => _error = '导入成功，但列表中没有可用频道');
                  }
                },
          child: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('导入'),
        ),
      ],
    );
  }
}