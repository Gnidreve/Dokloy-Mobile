import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../api/models.dart';

class RemoteServersPage extends StatelessWidget {
  const RemoteServersPage({super.key});

  @override
  Widget build(BuildContext context) {
    const servers = <RemoteServer>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ShadCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.server, size: 28),
                const SizedBox(width: 12),
                Text('Servers', style: ShadTheme.of(context).textTheme.h3),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Add servers to deploy your applications remotely.',
              style: ShadTheme.of(context).textTheme.muted,
            ),
            const Divider(height: 32),
            if (servers.isEmpty)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 32),
                    const Icon(LucideIcons.key, size: 48),
                    const SizedBox(height: 16),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: ShadTheme.of(context).textTheme.p,
                        children: [
                          const TextSpan(
                            text: 'No SSH Keys found. Add a SSH Key to start adding servers. ',
                          ),
                          TextSpan(
                            text: 'Add SSH Key',
                            style: ShadTheme.of(context).textTheme.p.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              )
            else
              ...servers.map(
                (s) => ListTile(
                  leading: const Icon(LucideIcons.server),
                  title: Text(s.name),
                  subtitle: Text(s.ip),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
