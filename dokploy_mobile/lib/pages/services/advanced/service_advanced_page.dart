import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../api/project/models.dart';

class ServiceAdvancedPage extends StatelessWidget {
  const ServiceAdvancedPage({super.key, required this.service});

  final ProjectService service;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final config = _dangerZoneConfigFor(service);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ShadCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Advanced Settings', style: theme.textTheme.h3),
                const SizedBox(height: 24),
                _AdvancedField(
                  label: 'Docker Image',
                  value: _dockerImageFor(service),
                ),
                const SizedBox(height: 16),
                const _AdvancedField(label: 'Command', value: '/bin/sh'),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Arguments (Args)', style: theme.textTheme.p),
                          const SizedBox(height: 8),
                          Text(
                            'No arguments added yet. Click "Add Argument" to add one.',
                            style: theme.textTheme.muted,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ShadButton.outline(
                      onPressed: () {},
                      leading: const Icon(LucideIcons.plus, size: 16),
                      child: const Text('Add Argument'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: ShadButton(
                    onPressed: () {},
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.destructive),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      LucideIcons.triangleAlert,
                      size: 18,
                      color: theme.colorScheme.destructive,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Danger Zone',
                      style: theme.textTheme.h3.copyWith(
                        color: theme.colorScheme.destructive,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(config.title, style: theme.textTheme.large),
                const SizedBox(height: 8),
                Text(config.description, style: theme.textTheme.muted),
                const SizedBox(height: 24),
                ShadButton.destructive(
                  onPressed: () {},
                  leading: Icon(config.icon, size: 16),
                  child: Text(config.buttonLabel),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _dockerImageFor(ProjectService service) {
    switch (service.sourceKey) {
      case 'mariadb':
        return 'mariadb:latest';
      case 'mongo':
        return 'mongo:7';
      case 'mysql':
        return 'mysql:latest';
      case 'postgres':
        return 'postgres:latest';
      case 'redis':
        return 'redis:latest';
      case 'compose':
        return 'docker/compose:latest';
      case 'applications':
      default:
        return 'node:latest';
    }
  }

  _DangerZoneConfig _dangerZoneConfigFor(ProjectService service) {
    switch (service.sourceKey) {
      case 'mariadb':
      case 'mongo':
      case 'mysql':
      case 'postgres':
      case 'redis':
        return const _DangerZoneConfig(
          title: 'Rebuild Database',
          description:
              'This action will completely reset your database to its initial state. '
              'All data, tables, and configurations will be removed.',
          buttonLabel: 'Rebuild Database',
          icon: LucideIcons.database,
        );
      case 'compose':
        return const _DangerZoneConfig(
          title: 'Rebuild Compose',
          description:
              'This action will rebuild your compose service from scratch. '
              'Existing containers and generated runtime state may be replaced.',
          buttonLabel: 'Rebuild Compose',
          icon: LucideIcons.box,
        );
      case 'applications':
      default:
        return const _DangerZoneConfig(
          title: 'Rebuild Application',
          description:
              'This action will rebuild your application from scratch. '
              'Existing runtime state may be replaced during the process.',
          buttonLabel: 'Rebuild Application',
          icon: LucideIcons.rocket,
        );
    }
  }
}

class _AdvancedField extends StatelessWidget {
  const _AdvancedField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ShadTheme.of(context).textTheme.p),
        const SizedBox(height: 8),
        ShadInput(initialValue: value),
      ],
    );
  }
}

class _DangerZoneConfig {
  const _DangerZoneConfig({
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.icon,
  });

  final String title;
  final String description;
  final String buttonLabel;
  final IconData icon;
}
