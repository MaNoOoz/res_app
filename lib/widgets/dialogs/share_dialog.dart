import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareDialog extends StatelessWidget {
  final String content;

  const ShareDialog({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("l10n.shareTitle"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.share, size: 48),
          const SizedBox(height: 16),
          Text(content),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("l10n.cancel"),
        ),
        TextButton(
          onPressed: () {
            Share.share(content);
            Navigator.pop(context);
          },
          child: Text("l10n.shareTitle"),
        ),
      ],
    );
  }
}
