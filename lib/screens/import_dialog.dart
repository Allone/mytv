import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/iptv_provider.dart';
import '../providers/epg_provider.dart';
import '../providers/settings_provider.dart';

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
                  setState(() { _loading = true; _error = null; });
                  try {
                    final iptv = context.read<IptvProvider>();
                    await iptv.load(forceRefresh: true);
                    if (!context.mounted) return;
                    // override source url
                    context.read<SettingsProvider>().iptvSourceUrl = _urlCtrl.text.trim();
                    await iptv.load(forceRefresh: true);
                    if (!context.mounted) return;
                    await context.read<EpgProvider>().load(iptv.groupList);
                    if (context.mounted) Navigator.pop(context);
                  } catch (e) {
                    setState(() => _error = e.toString());
                  } finally {
                    if (mounted) setState(() => _loading = false);
                  }
                },
          child: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('导入'),
        ),
      ],
    );
  }
}