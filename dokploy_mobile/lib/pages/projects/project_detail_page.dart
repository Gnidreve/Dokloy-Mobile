import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../api/index.dart';

const serviceTabs = <ServiceTabDefinition>[
  ServiceTabDefinition(key: 'general', label: 'General'),
  ServiceTabDefinition(key: 'environment', label: 'Environment'),
  ServiceTabDefinition(key: 'domains', label: 'Domains'),
  ServiceTabDefinition(key: 'deployments', label: 'Deployments'),
  ServiceTabDefinition(key: 'backups', label: 'Backups'),
  ServiceTabDefinition(key: 'schedules', label: 'Schedules'),
  ServiceTabDefinition(key: 'volume-backups', label: 'Volume Backups'),
  ServiceTabDefinition(key: 'logs', label: 'Logs'),
  ServiceTabDefinition(key: 'patches', label: 'Patches'),
  ServiceTabDefinition(key: 'monitoring', label: 'Monitoring'),
  ServiceTabDefinition(key: 'advanced', label: 'Advanced'),
];

class ServiceTabDefinition {
  const ServiceTabDefinition({required this.key, required this.label});

  final String key;
  final String label;
}

class ProjectDetailPage extends StatefulWidget {
  const ProjectDetailPage({super.key, required this.projectId});

  final String projectId;

  @override
  State<ProjectDetailPage> createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  final DokployApi _api = DokployApi();
  late Future<Project> _projectFuture;
  bool _hasRedirected = false;

  @override
  void initState() {
    super.initState();
    _projectFuture = _api.project.find(widget.projectId);
  }

  void _reloadProject() {
    setState(() {
      _projectFuture = _api.project.find(widget.projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Project>(
      future: _projectFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _LoadErrorCard(
            message: '${snapshot.error}',
            onRetry: _reloadProject,
          );
        }

        final project = snapshot.data!;

        final defaultEnvironment =
            project.environments
                .where((environment) => environment.isDefault)
                .firstOrNull ??
            project.environments.firstOrNull;

        if (!_hasRedirected && defaultEnvironment != null) {
          _hasRedirected = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            context.go(
              '/projects/${project.id}/environments/${defaultEnvironment.id}',
            );
          });
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.folderOpen, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      project.name,
                      style: ShadTheme.of(context).textTheme.h2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                project.description.isEmpty
                    ? 'No description for this project.'
                    : project.description,
                style: ShadTheme.of(context).textTheme.muted,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _InfoChip(
                    icon: LucideIcons.layers,
                    label:
                        '${project.environments.length} environment${project.environments.length == 1 ? '' : 's'}',
                  ),
                  _InfoChip(
                    icon: LucideIcons.box,
                    label:
                        '${project.serviceCount} service${project.serviceCount == 1 ? '' : 's'}',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Environments',
                style: ShadTheme.of(context).textTheme.large,
              ),
              const SizedBox(height: 12),
              if (project.environments.isEmpty)
                ShadCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No environments found for this project.',
                      style: ShadTheme.of(context).textTheme.muted,
                    ),
                  ),
                )
              else
                ...project.environments.map(
                  (environment) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => context.go(
                        '/projects/${project.id}/environments/${environment.id}',
                      ),
                      child: ShadCard(
                        child: Row(
                          children: [
                            const Icon(LucideIcons.layers),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          environment.name,
                                          style: ShadTheme.of(context)
                                              .textTheme
                                              .p
                                              .copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                      if (environment.isDefault) ...[
                                        const SizedBox(width: 8),
                                        ShadBadge(child: const Text('Default')),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${environment.serviceCount} service${environment.serviceCount == 1 ? '' : 's'}',
                                    style: ShadTheme.of(
                                      context,
                                    ).textTheme.muted,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(LucideIcons.chevronRight),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class EnvironmentDetailPage extends StatefulWidget {
  const EnvironmentDetailPage({
    super.key,
    required this.projectId,
    required this.environmentId,
  });

  final String projectId;
  final String environmentId;

  @override
  State<EnvironmentDetailPage> createState() => _EnvironmentDetailPageState();
}

class _EnvironmentDetailPageState extends State<EnvironmentDetailPage> {
  final DokployApi _api = DokployApi();
  late Future<Project> _projectFuture;

  @override
  void initState() {
    super.initState();
    _projectFuture = _api.project.find(widget.projectId);
  }

  void _reloadProject() {
    setState(() {
      _projectFuture = _api.project.find(widget.projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Project>(
      future: _projectFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _LoadErrorCard(
            message: '${snapshot.error}',
            onRetry: _reloadProject,
          );
        }

        final project = snapshot.data!;
        final environment = project.environments.where(
          (item) => item.id == widget.environmentId,
        );

        if (environment.isEmpty) {
          return _LoadErrorCard(
            message: 'Environment wurde nicht gefunden.',
            onRetry: _reloadProject,
          );
        }

        final selectedEnvironment = environment.first;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(project.name, style: ShadTheme.of(context).textTheme.h2),
              const SizedBox(height: 8),
              Text(
                selectedEnvironment.isDefault
                    ? 'Default environment'
                    : 'Environment overview',
                style: ShadTheme.of(context).textTheme.muted,
              ),
              const SizedBox(height: 24),
              Text('Services', style: ShadTheme.of(context).textTheme.large),
              const SizedBox(height: 12),
              if (selectedEnvironment.services.isEmpty)
                ShadCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No services found in this environment.',
                      style: ShadTheme.of(context).textTheme.muted,
                    ),
                  ),
                )
              else
                ...selectedEnvironment.services.map(
                  (service) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => context.go(
                        '/projects/${project.id}/environments/${selectedEnvironment.id}/services/${service.id}',
                      ),
                      child: ShadCard(
                        child: Row(
                          children: [
                            const Icon(LucideIcons.box),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.name,
                                    style: ShadTheme.of(context).textTheme.p
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    service.type,
                                    style: ShadTheme.of(
                                      context,
                                    ).textTheme.muted,
                                  ),
                                ],
                              ),
                            ),
                            if (service.status != null &&
                                service.status!.isNotEmpty) ...[
                              _StatusBadge(status: service.status!),
                              const SizedBox(width: 12),
                            ],
                            const Icon(LucideIcons.chevronRight),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class ServiceDetailPage extends StatefulWidget {
  const ServiceDetailPage({
    super.key,
    required this.projectId,
    required this.environmentId,
    required this.serviceId,
    required this.tabKey,
  });

  final String projectId;
  final String environmentId;
  final String serviceId;
  final String tabKey;

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  final DokployApi _api = DokployApi();
  late Future<Project> _projectFuture;

  @override
  void initState() {
    super.initState();
    _projectFuture = _api.project.find(widget.projectId);
  }

  void _reloadProject() {
    setState(() {
      _projectFuture = _api.project.find(widget.projectId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Project>(
      future: _projectFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _LoadErrorCard(
            message: '${snapshot.error}',
            onRetry: _reloadProject,
          );
        }

        final project = snapshot.data!;
        final environment = project.environments
            .where((item) => item.id == widget.environmentId)
            .firstOrNull;

        if (environment == null) {
          return _LoadErrorCard(
            message: 'Environment wurde nicht gefunden.',
            onRetry: _reloadProject,
          );
        }

        final service = environment.services
            .where((item) => item.id == widget.serviceId)
            .firstOrNull;

        if (service == null) {
          return _LoadErrorCard(
            message: 'Service wurde nicht gefunden.',
            onRetry: _reloadProject,
          );
        }

        final activeTab =
            serviceTabs.where((tab) => tab.key == widget.tabKey).firstOrNull ??
            serviceTabs.first;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.box, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      service.name,
                      style: ShadTheme.of(context).textTheme.h2,
                    ),
                  ),
                  if (service.status != null && service.status!.isNotEmpty)
                    _StatusBadge(status: service.status!),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${service.type} service in ${environment.name}',
                style: ShadTheme.of(context).textTheme.muted,
              ),
              const SizedBox(height: 24),
              _ServiceTabs(
                projectId: project.id,
                environmentId: environment.id,
                serviceId: service.id,
                activeTabKey: activeTab.key,
              ),
              const SizedBox(height: 24),
              ShadCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    activeTab.label,
                    style: ShadTheme.of(context).textTheme.large,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = status.trim().toLowerCase();

    return switch (normalizedStatus) {
      'error' || 'failed' => ShadBadge.destructive(child: Text(status)),
      'running' || 'success' || 'done' => ShadBadge(child: Text(status)),
      _ => ShadBadge.secondary(child: Text(status)),
    };
  }
}

class _ServiceTabs extends StatelessWidget {
  const _ServiceTabs({
    required this.projectId,
    required this.environmentId,
    required this.serviceId,
    required this.activeTabKey,
  });

  final String projectId;
  final String environmentId;
  final String serviceId;
  final String activeTabKey;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: ShadTheme.of(context).colorScheme.muted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(6),
        child: Row(
          children: serviceTabs
              .map(
                (tab) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ShadButton.ghost(
                    backgroundColor: tab.key == activeTabKey
                        ? ShadTheme.of(context).colorScheme.background
                        : Colors.transparent,
                    onPressed: () => context.go(
                      '/projects/$projectId/environments/$environmentId/services/$serviceId/${tab.key}',
                    ),
                    child: Text(
                      tab.label,
                      style: ShadTheme.of(context).textTheme.p.copyWith(
                        fontWeight: tab.key == activeTabKey
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

String normalizeServiceTabKey(String? tabKey) {
  if (tabKey == null || tabKey.isEmpty) {
    return serviceTabs.first.key;
  }

  final matchingTab = serviceTabs.where((tab) => tab.key == tabKey).firstOrNull;
  return matchingTab?.key ?? serviceTabs.first.key;
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: ShadTheme.of(context).colorScheme.accent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 8), Text(label)],
      ),
    );
  }
}

class _LoadErrorCard extends StatelessWidget {
  const _LoadErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ShadCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daten konnten nicht geladen werden.',
                style: ShadTheme.of(context).textTheme.large,
              ),
              const SizedBox(height: 8),
              Text(message, style: ShadTheme.of(context).textTheme.muted),
              const SizedBox(height: 12),
              ShadButton(
                onPressed: onRetry,
                child: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
