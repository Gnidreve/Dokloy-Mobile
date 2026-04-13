import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class RegistryPage extends StatelessWidget {
  const RegistryPage({super.key});

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
                  const Icon(LucideIcons.box, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Docker Registry',
                    style: theme.textTheme.h4.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your Docker Registry configurations',
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
                    LucideIcons.box,
                    size: 36,
                    color: theme.colorScheme.mutedForeground,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "You don't have any registry configurations",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.large.copyWith(
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ShadButton(
                    onPressed: () {},
                    leading: const Icon(LucideIcons.plus, size: 16),
                    child: const Text('Add Registry'),
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
