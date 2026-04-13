import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SshKeysPage extends StatelessWidget {
  const SshKeysPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.keyRound, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'SSH Keys',
                    style: theme.textTheme.h4.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Create and manage SSH Keys, you can use them to access your servers, git private repositories, and more.',
                style: theme.textTheme.muted,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    LucideIcons.keyRound,
                    size: 36,
                    color: theme.colorScheme.mutedForeground,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "You don't have any SSH keys",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.large.copyWith(
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ShadButton(
                    onPressed: () => showShadDialog(
                      context: context,
                      builder: (context) => ShadDialog.alert(
                        title: const Text('Add SSH Key'),
                        description: const Text(
                          'This modal is wired up, but the form is still intentionally empty.',
                        ),
                        actions: [
                          ShadButton.outline(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ),
                    leading: const Icon(LucideIcons.plus, size: 16),
                    child: const Text('Add SSH Key'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
