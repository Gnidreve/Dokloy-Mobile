import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../api/index.dart';

class DeploymentsPage extends StatefulWidget {
  const DeploymentsPage({super.key});

  @override
  State<DeploymentsPage> createState() => _DeploymentsPageState();
}

class _DeploymentsPageState extends State<DeploymentsPage> {
  final _api = DokployApi();
  late Future<List<Deployment>> _deploymentsFuture;
  late Future<List<DeploymentQueueItem>> _queueFuture;

  @override
  void initState() {
    super.initState();
    _deploymentsFuture = _api.deployment.all();
    _queueFuture = _api.deployment.queueList();
  }

  void _retryDeployments() {
    setState(() {
      _deploymentsFuture = _api.deployment.all();
    });
  }

  void _retryQueue() {
    setState(() {
      _queueFuture = _api.deployment.queueList();
    });
  }

  @override
  Widget build(BuildContext context) {
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
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ShadTabs<String>(
              value: 'deployments',
              tabs: [
                ShadTab(
                  value: 'deployments',
                  content: _DeploymentsTab(
                    future: _deploymentsFuture,
                    onRetry: _retryDeployments,
                  ),
                  child: const Text('Deployments'),
                ),
                ShadTab(
                  value: 'queue',
                  content: _QueueTab(
                    future: _queueFuture,
                    onRetry: _retryQueue,
                  ),
                  child: const Text('Queue'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DeploymentsTab extends StatelessWidget {
  const _DeploymentsTab({required this.future, required this.onRetry});

  final Future<List<Deployment>> future;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Deployment>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _LoadError(
            title: 'Deployments konnten nicht geladen werden.',
            error: snapshot.error,
            onRetry: onRetry,
          );
        }

        final deployments = snapshot.data ?? const <Deployment>[];
        if (deployments.isEmpty) {
          return const _EmptyState(label: 'No deployments found.');
        }

        return _DeploymentsTable(deployments: deployments);
      },
    );
  }
}

class _QueueTab extends StatelessWidget {
  const _QueueTab({required this.future, required this.onRetry});

  final Future<List<DeploymentQueueItem>> future;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DeploymentQueueItem>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _LoadError(
            title: 'Queue konnte nicht geladen werden.',
            error: snapshot.error,
            onRetry: onRetry,
          );
        }

        final items = snapshot.data ?? const <DeploymentQueueItem>[];
        if (items.isEmpty) {
          return const _EmptyState(label: 'No queue items found.');
        }

        return _QueueTable(items: items);
      },
    );
  }
}

class _DeploymentsTable extends StatelessWidget {
  const _DeploymentsTable({required this.deployments});

  final List<Deployment> deployments;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 860),
        child: ShadTable.list(
          header: [
            _HeaderCell(label: 'Service'),
            _HeaderCell(label: 'Project'),
            _HeaderCell(label: 'Environment'),
            _HeaderCell(label: 'Server'),
            _HeaderCell(label: 'Title'),
          ],
          columnSpanExtent: _columnSpanExtent,
          children: deployments
              .map(
                (deployment) => [
                  ShadTableCell(child: _ServiceCell(deployment: deployment)),
                  ShadTableCell(child: Text(deployment.projectName)),
                  ShadTableCell(child: Text(deployment.environmentName)),
                  ShadTableCell(child: Text(deployment.serverName)),
                  ShadTableCell(child: Text(deployment.title)),
                ],
              )
              .toList(),
        ),
      ),
    );
  }
}

class _QueueTable extends StatelessWidget {
  const _QueueTable({required this.items});

  final List<DeploymentQueueItem> items;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 860),
        child: ShadTable.list(
          header: [
            _HeaderCell(label: 'Service'),
            _HeaderCell(label: 'Project'),
            _HeaderCell(label: 'Environment'),
            _HeaderCell(label: 'Server'),
            _HeaderCell(label: 'Title'),
          ],
          columnSpanExtent: _columnSpanExtent,
          children: items
              .map(
                (item) => [
                  ShadTableCell(child: _QueueServiceCell(item: item)),
                  ShadTableCell(child: Text(item.projectName)),
                  ShadTableCell(child: Text(item.environmentName)),
                  ShadTableCell(child: Text(item.serverName)),
                  ShadTableCell(child: Text(item.title)),
                ],
              )
              .toList(),
        ),
      ),
    );
  }
}

TableSpanExtent? _columnSpanExtent(int index) {
  if (index == 0) return const FixedTableSpanExtent(260);
  if (index == 1) return const FixedTableSpanExtent(130);
  if (index == 2) return const FixedTableSpanExtent(170);
  if (index == 3) return const FixedTableSpanExtent(120);
  if (index == 4) {
    return const MaxTableSpanExtent(
      FixedTableSpanExtent(220),
      RemainingTableSpanExtent(),
    );
  }
  return null;
}

class _HeaderCell extends ShadTableCell {
  _HeaderCell({required String label})
    : super.header(
        child: Row(
          children: [
            Text(label),
            const SizedBox(width: 8),
            const Icon(LucideIcons.arrowUpDown, size: 14),
          ],
        ),
      );
}

class _ServiceCell extends StatelessWidget {
  const _ServiceCell({required this.deployment});

  final Deployment deployment;

  @override
  Widget build(BuildContext context) {
    return _BaseServiceCell(
      name: deployment.serviceName,
      type: deployment.type,
    );
  }
}

class _QueueServiceCell extends StatelessWidget {
  const _QueueServiceCell({required this.item});

  final DeploymentQueueItem item;

  @override
  Widget build(BuildContext context) {
    return _BaseServiceCell(name: item.serviceName, type: item.type);
  }
}

class _BaseServiceCell extends StatelessWidget {
  const _BaseServiceCell({required this.name, required this.type});

  final String name;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(LucideIcons.workflow, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: ShadTheme.of(
                  context,
                ).textTheme.p.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ShadBadge.outline(child: Text(type)),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({
    required this.title,
    required this.error,
    required this.onRetry,
  });

  final String title;
  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: ShadTheme.of(context).textTheme.h4,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              style: ShadTheme.of(context).textTheme.muted,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ShadButton(
              onPressed: onRetry,
              child: const Text('Erneut versuchen'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(label, style: ShadTheme.of(context).textTheme.muted),
    );
  }
}
