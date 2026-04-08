import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../api/models.dart';

class DeploymentsPage extends StatefulWidget {
  const DeploymentsPage({super.key});

  @override
  State<DeploymentsPage> createState() => _DeploymentsPageState();
}

class _DeploymentsPageState extends State<DeploymentsPage> {
  DeploymentStatus? _statusFilter;
  String? _typeFilter;

  @override
  Widget build(BuildContext context) {
    const allDeployments = <Deployment>[];
    final deployments = allDeployments.where((d) {
      if (_statusFilter != null && d.status != _statusFilter) return false;
      if (_typeFilter != null && d.type != _typeFilter) return false;
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.rocket, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Deployments',
                    style: ShadTheme.of(context).textTheme.h2,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'All application and compose deployments in one place.',
                style: ShadTheme.of(context).textTheme.muted,
              ),
            ],
          ),
        ),
        ShadTabs<String>(
          value: 'deployments',
          tabs: [
            ShadTab(
              value: 'deployments',
              child: const Text('Deployments'),
              content: _DeploymentsTab(
                deployments: deployments,
                statusFilter: _statusFilter,
                typeFilter: _typeFilter,
                onStatusChanged: (v) => setState(() => _statusFilter = v),
                onTypeChanged: (v) => setState(() => _typeFilter = v),
              ),
            ),
            ShadTab(
              value: 'queue',
              child: const Text('Queue'),
              content: const _QueueTab(),
            ),
          ],
        ),
      ],
    );
  }
}

class _DeploymentsTab extends StatelessWidget {
  const _DeploymentsTab({
    required this.deployments,
    required this.statusFilter,
    required this.typeFilter,
    required this.onStatusChanged,
    required this.onTypeChanged,
  });

  final List<Deployment> deployments;
  final DeploymentStatus? statusFilter;
  final String? typeFilter;
  final ValueChanged<DeploymentStatus?> onStatusChanged;
  final ValueChanged<String?> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              ShadInput(
                placeholder: const Text('Search by name, project, environment...'),
                trailing: const Icon(LucideIcons.search),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ShadSelect<DeploymentStatus?>(
                      initialValue: null,
                      placeholder: const Text('All statuses'),
                      onChanged: onStatusChanged,
                      selectedOptionBuilder: (context, value) => Text(
                        switch (value) {
                          DeploymentStatus.running => 'Running',
                          DeploymentStatus.done => 'Done',
                          DeploymentStatus.error => 'Error',
                          DeploymentStatus.cancelled => 'Cancelled',
                          _ => 'All statuses',
                        },
                      ),
                      options: const [
                        ShadOption(value: null, child: Text('All statuses')),
                        ShadOption(value: DeploymentStatus.running, child: Text('Running')),
                        ShadOption(value: DeploymentStatus.done, child: Text('Done')),
                        ShadOption(value: DeploymentStatus.error, child: Text('Error')),
                        ShadOption(value: DeploymentStatus.cancelled, child: Text('Cancelled')),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ShadSelect<String?>(
                      initialValue: null,
                      placeholder: const Text('All types'),
                      onChanged: onTypeChanged,
                      selectedOptionBuilder: (context, value) =>
                          Text(value ?? 'All types'),
                      options: const [
                        ShadOption(value: null, child: Text('All types')),
                        ShadOption(value: 'Application', child: Text('Application')),
                        ShadOption(value: 'Compose', child: Text('Compose')),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Service',
                  style: ShadTheme.of(context).textTheme.small.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                'Project',
                style: ShadTheme.of(context).textTheme.small.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const Divider(),
        ...deployments.map(
          (d) => ListTile(
            leading: const Icon(LucideIcons.rocket),
            title: Text(d.serviceName),
            subtitle: ShadBadge.secondary(child: Text(d.type)),
            trailing: Text(d.projectName),
          ),
        ),
      ],
    );
  }
}

class _QueueTab extends StatelessWidget {
  const _QueueTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text('Job ID', style: ShadTheme.of(context).textTheme.small.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              Text('Label', style: ShadTheme.of(context).textTheme.small.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              Text('Type', style: ShadTheme.of(context).textTheme.small.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(width: 16),
              Text('State', style: ShadTheme.of(context).textTheme.small.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const Divider(),
        const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('Deployment jobs')),
        ),
      ],
    );
  }
}
