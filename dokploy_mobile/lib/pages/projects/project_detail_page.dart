import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../api/index.dart';
import 'project_detail_page.config.dart';

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
                                        const ShadBadge(child: Text('Default')),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: ShadTheme.of(context).textTheme.h2,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          selectedEnvironment.isDefault
                              ? 'Default environment'
                              : 'Environment overview',
                          style: ShadTheme.of(context).textTheme.muted,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ShadButton.outline(
                    onPressed: () {},
                    child: const Text('Project Environment'),
                  ),
                  const SizedBox(width: 12),
                  const _CreateServiceMenuButton(),
                ],
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
                        child: _ServiceCardContent(service: service),
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

class _CreateServiceMenuButton extends StatefulWidget {
  const _CreateServiceMenuButton();

  @override
  State<_CreateServiceMenuButton> createState() =>
      _CreateServiceMenuButtonState();
}

class _CreateServiceMenuButtonState extends State<_CreateServiceMenuButton> {
  final _popoverController = ShadPopoverController();

  @override
  void dispose() {
    _popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShadPopover(
      controller: _popoverController,
      anchor: const ShadAnchorAuto(
        followerAnchor: Alignment.topRight,
        targetAnchor: Alignment.bottomRight,
        offset: Offset(0, 8),
      ),
      popover: (context) => const _CreateServiceMenu(),
      child: ShadButton(
        onPressed: _popoverController.toggle,
        leading: const Icon(LucideIcons.plus, size: 16),
        child: const Text('Create Service'),
      ),
    );
  }
}

class _CreateServiceMenu extends StatelessWidget {
  const _CreateServiceMenu();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Text(
              'Actions',
              style: ShadTheme.of(
                context,
              ).textTheme.p.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          const Divider(height: 1),
          const _CreateServiceMenuItem(
            icon: LucideIcons.folder,
            label: 'Application',
          ),
          const _CreateServiceMenuItem(
            icon: LucideIcons.database,
            label: 'Database',
          ),
          const _CreateServiceMenuItem(
            icon: LucideIcons.image,
            label: 'Compose',
          ),
          const _CreateServiceMenuItem(
            icon: LucideIcons.wandSparkles,
            label: 'Template',
          ),
          const _CreateServiceMenuItem(
            icon: LucideIcons.bot,
            label: 'AI Assistant',
          ),
        ],
      ),
    );
  }
}

class _CreateServiceMenuItem extends StatelessWidget {
  const _CreateServiceMenuItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ShadButton.ghost(
      onPressed: () {},
      width: double.infinity,
      mainAxisAlignment: MainAxisAlignment.start,
      leading: Icon(icon, size: 18),
      child: Text(label),
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

        final availableTabs = tabsForService(service);
        final activeTab = resolveActiveServiceTab(availableTabs, widget.tabKey);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _ServiceAssetIcon(service: service, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      service.name,
                      style: ShadTheme.of(context).textTheme.h2,
                    ),
                  ),
                  ShadButton.outline(
                    onPressed: () {},
                    size: ShadButtonSize.sm,
                    child: const Icon(LucideIcons.squarePen, size: 16),
                  ),
                  const SizedBox(width: 8),
                  ShadButton.destructive(
                    onPressed: () {},
                    size: ShadButtonSize.sm,
                    child: const Icon(LucideIcons.trash2, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${service.type} service in ${environment.name}',
                style: ShadTheme.of(context).textTheme.muted,
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _ServiceTabs(
                  projectId: project.id,
                  environmentId: environment.id,
                  serviceId: service.id,
                  tabs: availableTabs,
                  activeTabKey: activeTab.key,
                ),
              ),
              const SizedBox(height: 24),
              buildServiceTabContent(
                context,
                service: service,
                activeTab: activeTab,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ServiceCardContent extends StatelessWidget {
  const _ServiceCardContent({required this.service});

  final ProjectService service;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 56),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: ShadTheme.of(
                        context,
                      ).textTheme.p.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      service.type,
                      style: ShadTheme.of(context).textTheme.muted,
                    ),
                  ],
                ),
              ),
            ),
            const Icon(LucideIcons.chevronRight),
          ],
        ),
        Positioned(
          top: 0,
          right: 24,
          child: _ServiceStatusDot(status: service.status),
        ),
        Positioned(
          top: 12,
          right: 0,
          child: _ServiceAssetIcon(service: service),
        ),
      ],
    );
  }
}

class _ServiceStatusDot extends StatelessWidget {
  const _ServiceStatusDot({required this.status});

  final String? status;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context, status);
    if (color == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Color? _statusColor(BuildContext context, String? rawStatus) {
    final status = rawStatus?.trim().toLowerCase();
    if (status == null || status.isEmpty) return null;

    switch (status) {
      case 'running':
      case 'success':
      case 'done':
        return Colors.green;
      case 'pending':
      case 'starting':
      case 'queued':
      case 'restarting':
        return Colors.amber;
      case 'error':
      case 'failed':
      case 'stopped':
        return ShadTheme.of(context).colorScheme.destructive;
      default:
        return ShadTheme.of(context).colorScheme.mutedForeground;
    }
  }
}

class _ServiceAssetIcon extends StatefulWidget {
  const _ServiceAssetIcon({required this.service, this.size = 32});

  final ProjectService service;
  final double size;

  @override
  State<_ServiceAssetIcon> createState() => _ServiceAssetIconState();
}

class _ServiceAssetIconState extends State<_ServiceAssetIcon> {
  static Future<_EnvironmentAssetLookup>? _assetLookupFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_EnvironmentAssetLookup>(
      future: _assetLookupFuture ??= _loadAssetLookup(),
      builder: (context, snapshot) {
        final assetPath = snapshot.data?.findAssetFor(widget.service);

        if (assetPath == null) {
          return Icon(LucideIcons.box, size: widget.size);
        }

        if (assetPath.toLowerCase().endsWith('.svg')) {
          return SvgPicture.asset(
            assetPath,
            width: widget.size,
            height: widget.size,
          );
        }

        return Image.asset(
          assetPath,
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain,
        );
      },
    );
  }

  Future<_EnvironmentAssetLookup> _loadAssetLookup() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final manifest = jsonDecode(manifestContent) as Map<String, dynamic>;
    final paths = manifest.keys
        .where((path) => path.startsWith('lib/assets/enviroments/'))
        .toList();

    return _EnvironmentAssetLookup(
      entries: [
        for (final path in paths)
          _EnvironmentAssetEntry(
            normalizedName: _normalizedAssetFileName(path),
            assetPath: path,
          ),
      ],
    );
  }

  String _normalizedAssetFileName(String path) {
    final fileName = path.split('/').last;
    final baseName = fileName.contains('.')
        ? fileName.substring(0, fileName.lastIndexOf('.'))
        : fileName;
    return _normalizeToken(baseName);
  }

  String _normalizeToken(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}

class _EnvironmentAssetLookup {
  const _EnvironmentAssetLookup({required this.entries});

  final List<_EnvironmentAssetEntry> entries;

  String? findAssetFor(ProjectService service) {
    final candidates = [
      _normalizeToken(service.sourceKey),
      _normalizeToken(service.endpointSlug),
      _normalizeToken(service.type),
    ].where((candidate) => candidate.isNotEmpty).toList();

    for (final candidate in candidates) {
      final exact = entries
          .where((entry) => entry.normalizedName == candidate)
          .firstOrNull;
      if (exact != null) return exact.assetPath;
    }

    for (final candidate in candidates) {
      final fuzzy = entries
          .where(
            (entry) =>
                entry.normalizedName.contains(candidate) ||
                candidate.contains(entry.normalizedName),
          )
          .firstOrNull;
      if (fuzzy != null) return fuzzy.assetPath;
    }

    return null;
  }

  String _normalizeToken(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}

class _EnvironmentAssetEntry {
  const _EnvironmentAssetEntry({
    required this.normalizedName,
    required this.assetPath,
  });

  final String normalizedName;
  final String assetPath;
}

class _ServiceTabs extends StatelessWidget {
  const _ServiceTabs({
    required this.projectId,
    required this.environmentId,
    required this.serviceId,
    required this.tabs,
    required this.activeTabKey,
  });

  final String projectId;
  final String environmentId;
  final String serviceId;
  final List<ServiceTabDefinition> tabs;
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
          children: tabs
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
  return tabKey?.isNotEmpty == true ? tabKey! : 'general';
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
