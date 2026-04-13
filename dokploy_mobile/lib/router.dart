import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'api/index.dart';
import 'components/app_drawer/app_drawer.dart';
import 'navigation/navigation_tree.dart';
import 'pages/connecting_page.dart';
import 'pages/connection_error_page.dart';
import 'pages/projects/projects_page.dart';
import 'pages/projects/project_detail_page.dart';
import 'pages/deployments/deployments_page.dart';
import 'pages/monitoring/monitoring_page.dart';
import 'pages/schedules/schedules_page.dart';
import 'pages/docker/docker_page.dart';
import 'pages/swarm/swarm_page.dart';
import 'pages/requests/requests_page.dart';
import 'pages/web_server/web_server_page.dart';
import 'pages/ssh_keys/ssh_keys_page.dart';
import 'pages/ai/ai_page.dart';
import 'pages/git/git_page.dart';
import 'pages/registry/registry_page.dart';
import 'pages/s3_destinations/s3_destinations_page.dart';
import 'pages/certificates/certificates_page.dart';
import 'pages/cluster/cluster_page.dart';
import 'pages/notifications/notifications_page.dart';
import 'pages/profile/profile_page.dart';
import 'pages/remote_servers/remote_servers_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter({required VoidCallback onToggleTheme}) => GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/connecting',
  routes: [
    GoRoute(path: '/connecting', builder: (_, _) => const ConnectingPage()),
    GoRoute(
      path: '/connection-error',
      builder: (_, _) => const ConnectionErrorPage(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) =>
          _ShellWrapper(onToggleTheme: onToggleTheme, child: child),
      routes: [
        GoRoute(
          path: '/projects',
          builder: (_, _) => const ProjectsPage(),
          routes: [
            GoRoute(
              path: ':projectId',
              builder: (_, state) => ProjectDetailPage(
                projectId: state.pathParameters['projectId']!,
              ),
              routes: [
                GoRoute(
                  path: 'environments/:environmentId',
                  builder: (_, state) => EnvironmentDetailPage(
                    projectId: state.pathParameters['projectId']!,
                    environmentId: state.pathParameters['environmentId']!,
                  ),
                  routes: [
                    GoRoute(
                      path: 'services/:serviceId',
                      builder: (_, state) => ServiceDetailPage(
                        projectId: state.pathParameters['projectId']!,
                        environmentId: state.pathParameters['environmentId']!,
                        serviceId: state.pathParameters['serviceId']!,
                        tabKey: normalizeServiceTabKey(null),
                      ),
                      routes: [
                        GoRoute(
                          path: ':tab',
                          builder: (_, state) => ServiceDetailPage(
                            projectId: state.pathParameters['projectId']!,
                            environmentId:
                                state.pathParameters['environmentId']!,
                            serviceId: state.pathParameters['serviceId']!,
                            tabKey: normalizeServiceTabKey(
                              state.pathParameters['tab'],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/deployments',
          builder: (_, _) => const DeploymentsPage(),
        ),
        GoRoute(path: '/monitoring', builder: (_, _) => const MonitoringPage()),
        GoRoute(path: '/schedules', builder: (_, _) => const SchedulesPage()),
        GoRoute(
          path: '/traefik',
          builder: (_, _) =>
              const _PlaceholderPage(title: 'Traefik File System'),
        ),
        GoRoute(path: '/docker', builder: (_, _) => const DockerPage()),
        GoRoute(path: '/swarm', builder: (_, _) => const SwarmPage()),
        GoRoute(path: '/requests', builder: (_, _) => const RequestsPage()),
        GoRoute(path: '/web-server', builder: (_, _) => const WebServerPage()),
        GoRoute(path: '/ssh-keys', builder: (_, _) => const SshKeysPage()),
        GoRoute(path: '/ai', builder: (_, _) => const AiPage()),
        GoRoute(path: '/git', builder: (_, _) => const GitPage()),
        GoRoute(path: '/registry', builder: (_, _) => const RegistryPage()),
        GoRoute(
          path: '/s3-destinations',
          builder: (_, _) => const S3DestinationsPage(),
        ),
        GoRoute(
          path: '/certificates',
          builder: (_, _) => const CertificatesPage(),
        ),
        GoRoute(path: '/cluster', builder: (_, _) => const ClusterPage()),
        GoRoute(
          path: '/notifications',
          builder: (_, _) => const NotificationsPage(),
        ),
        GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),
        GoRoute(
          path: '/remote-servers',
          builder: (_, _) => const RemoteServersPage(),
        ),
      ],
    ),
  ],
);

class _ShellWrapper extends StatelessWidget {
  const _ShellWrapper({required this.onToggleTheme, required this.child});

  final VoidCallback onToggleTheme;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    return Scaffold(
      drawer: AppDrawer(onToggleTheme: onToggleTheme),
      appBar: AppBar(
        titleSpacing: 0,
        leadingWidth: 52,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: ShadSeparator.horizontal(margin: EdgeInsets.zero),
        ),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(LucideIcons.panelLeft),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            const SizedBox(width: 2),
            Container(
              width: 1,
              height: 18,
              color: ShadTheme.of(
                context,
              ).colorScheme.mutedForeground.withValues(alpha: 0.35),
            ),
            const SizedBox(width: 14),
            Expanded(child: _Breadcrumbs(location: location)),
          ],
        ),
      ),
      body: child,
    );
  }
}

class _Breadcrumbs extends StatelessWidget {
  const _Breadcrumbs({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    final segments = Uri.parse(location).pathSegments;
    if (segments.isNotEmpty &&
        segments.first == 'projects' &&
        segments.length >= 2) {
      return _ProjectBreadcrumbs(
        projectId: segments[1],
        environmentId: segments.length >= 4 && segments[2] == 'environments'
            ? segments[3]
            : null,
        serviceId: segments.length >= 6 && segments[4] == 'services'
            ? segments[5]
            : null,
        serviceTabKey: segments.length >= 7 ? segments[6] : null,
      );
    }

    final crumbs = breadcrumbsForRoute(location);
    return ShadBreadcrumb(
      spacing: 6,
      separator: _MutedBreadcrumbSeparator(),
      children: [for (final crumb in crumbs) Text(crumb)],
    );
  }
}

class _ProjectBreadcrumbs extends StatefulWidget {
  const _ProjectBreadcrumbs({
    required this.projectId,
    required this.environmentId,
    required this.serviceId,
    required this.serviceTabKey,
  });

  final String projectId;
  final String? environmentId;
  final String? serviceId;
  final String? serviceTabKey;

  @override
  State<_ProjectBreadcrumbs> createState() => _ProjectBreadcrumbsState();
}

class _ProjectBreadcrumbsState extends State<_ProjectBreadcrumbs> {
  final DokployApi _api = DokployApi();
  late Future<Project> _projectFuture;

  @override
  void initState() {
    super.initState();
    _projectFuture = _api.project.find(widget.projectId);
  }

  @override
  void didUpdateWidget(covariant _ProjectBreadcrumbs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.projectId != widget.projectId) {
      _projectFuture = _api.project.find(widget.projectId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Project>(
      future: _projectFuture,
      builder: (context, snapshot) {
        final project = snapshot.data;
        final selectedEnvironment = project?.environments
            .where((environment) => environment.id == widget.environmentId)
            .firstOrNull;
        final selectedService = selectedEnvironment?.services
            .where((service) => service.id == widget.serviceId)
            .firstOrNull;

        return ShadBreadcrumb(
          spacing: 6,
          separator: _MutedBreadcrumbSeparator(),
          children: [
            ShadBreadcrumbLink(
              onPressed: () => context.go('/projects'),
              child: const Text('Projects'),
            ),
            if (widget.environmentId == null)
              Text(project?.name ?? widget.projectId)
            else
              ShadBreadcrumbLink(
                onPressed: () => context.go(
                  '/projects/${widget.projectId}/environments/${widget.environmentId}',
                ),
                child: Text(project?.name ?? widget.projectId),
              ),
            if (widget.environmentId != null)
              _EnvironmentDropdown(
                project: project,
                selectedEnvironmentId: widget.environmentId!,
                fallbackLabel:
                    selectedEnvironment?.name ?? widget.environmentId!,
              ),
            if (widget.serviceId != null)
              Text(selectedService?.name ?? widget.serviceId!),
          ],
        );
      },
    );
  }
}

class _EnvironmentDropdown extends StatelessWidget {
  const _EnvironmentDropdown({
    required this.project,
    required this.selectedEnvironmentId,
    required this.fallbackLabel,
  });

  final Project? project;
  final String selectedEnvironmentId;
  final String fallbackLabel;

  @override
  Widget build(BuildContext context) {
    if (project == null) {
      return Text(fallbackLabel);
    }

    final selectedEnvironment = project!.environments
        .where((environment) => environment.id == selectedEnvironmentId)
        .firstOrNull;

    final label = selectedEnvironment?.name ?? fallbackLabel;

    return ShadBreadcrumbDropdown(
      items: project!.environments
          .map(
            (environment) => ShadBreadcrumbDropMenuItem(
              onPressed: () => context.go(
                '/projects/${project!.id}/environments/${environment.id}',
              ),
              child: Text(environment.name),
            ),
          )
          .toList(),
      child: Text(label),
    );
  }
}

class _MutedBreadcrumbSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShadBreadcrumbSeparator(
      color: ShadTheme.of(context).colorScheme.mutedForeground,
      size: 12,
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('$title — coming soon'));
  }
}
