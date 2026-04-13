import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../api/project/models.dart';

class DatabaseGeneralPage extends StatelessWidget {
  const DatabaseGeneralPage({
    super.key,
    required this.service,
    required this.databaseKind,
    required this.defaultUser,
    required this.defaultPort,
    this.defaultDatabaseName,
    this.showDatabaseName = true,
    this.secondarySecretLabel,
  });

  final ProjectService service;
  final String databaseKind;
  final String defaultUser;
  final String defaultPort;
  final String? defaultDatabaseName;
  final bool showDatabaseName;
  final String? secondarySecretLabel;

  @override
  Widget build(BuildContext context) {
    final host = '${service.name.toLowerCase()}-${databaseKind.toLowerCase()}';
    final connectionUrl = showDatabaseName
        ? '${databaseKind.toLowerCase()}://$defaultUser:password@$host:$defaultPort/${defaultDatabaseName ?? ''}'
        : '${databaseKind.toLowerCase()}://$defaultUser:password@$host:$defaultPort';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ShadCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Internal Credentials',
                  style: ShadTheme.of(context).textTheme.large,
                ),
                const SizedBox(height: 16),
                _FieldColumn(label: 'User', value: defaultUser),
                if (showDatabaseName) ...[
                  const SizedBox(height: 16),
                  _FieldColumn(
                    label: 'Database Name',
                    value: defaultDatabaseName ?? '',
                  ),
                ],
                const SizedBox(height: 16),
                const _FieldColumn(
                  label: 'Password',
                  value: '••••••••••••••••',
                ),
                if (secondarySecretLabel != null) ...[
                  const SizedBox(height: 16),
                  _FieldColumn(
                    label: secondarySecretLabel!,
                    value: '••••••••••••••••',
                  ),
                ],
                const SizedBox(height: 16),
                _FieldColumn(
                  label: 'Internal Port (Container)',
                  value: defaultPort,
                ),
                const SizedBox(height: 16),
                _FieldColumn(label: 'Internal Host', value: host),
                const SizedBox(height: 16),
                _FieldColumn(
                  label: 'Internal Connection URL',
                  value: connectionUrl,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ShadCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'External Credentials',
                  style: ShadTheme.of(context).textTheme.large,
                ),
                const SizedBox(height: 8),
                Text(
                  'In order to make the database reachable through the internet, you must set a port and ensure that the port is not being used by another application or database',
                  style: ShadTheme.of(context).textTheme.muted,
                ),
                const SizedBox(height: 16),
                _FieldColumn(
                  label: 'External Port (Internet)',
                  value: defaultPort,
                ),
                const SizedBox(height: 16),
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
      ],
    );
  }
}

class _FieldColumn extends StatelessWidget {
  const _FieldColumn({required this.label, required this.value});

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
