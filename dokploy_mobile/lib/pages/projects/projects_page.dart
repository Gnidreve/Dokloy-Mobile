import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../api/index.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final DokployApi _api = DokployApi();

  String _filter = '';
  String _sort = 'newest';
  late Future<List<Project>> _projectsFuture;

  @override
  void initState() {
    super.initState();
    _projectsFuture = _api.project.all();
  }

  void _reloadProjects() {
    setState(() {
      _projectsFuture = _api.project.all();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.folder, size: 28),
              const SizedBox(width: 12),
              Text('Projects', style: ShadTheme.of(context).textTheme.h2),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Create and manage your projects',
            style: ShadTheme.of(context).textTheme.muted,
          ),
          const SizedBox(height: 16),
          ShadButton(
            onPressed: () {},
            leading: const Icon(LucideIcons.plus),
            child: const Text('Create Project'),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ShadInput(
                  placeholder: const Text('Filter projects...'),
                  trailing: const Icon(LucideIcons.search),
                  onChanged: (v) => setState(() => _filter = v),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 160,
                child: ShadSelect<String>(
                  initialValue: _sort,
                  placeholder: const Text('Newest first'),
                  onChanged: (v) => setState(() => _sort = v ?? 'newest'),
                  selectedOptionBuilder: (context, value) =>
                      Text(switch (value) {
                        'newest' => 'Newest first',
                        'oldest' => 'Oldest first',
                        'az' => 'A → Z',
                        _ => value,
                      }),
                  options: const [
                    ShadOption(value: 'newest', child: Text('Newest first')),
                    ShadOption(value: 'oldest', child: Text('Oldest first')),
                    ShadOption(value: 'az', child: Text('A → Z')),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<Project>>(
            future: _projectsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return ShadCard(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Projects konnten nicht geladen werden.',
                          style: ShadTheme.of(context).textTheme.large,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          style: ShadTheme.of(context).textTheme.muted,
                        ),
                        const SizedBox(height: 12),
                        ShadButton(
                          onPressed: _reloadProjects,
                          leading: const Icon(LucideIcons.refreshCw),
                          child: const Text('Erneut versuchen'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final projects = _applyFilters(snapshot.data ?? const []);

              if (projects.isEmpty) {
                return ShadCard(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      'Keine Projekte gefunden.',
                      style: ShadTheme.of(context).textTheme.muted,
                    ),
                  ),
                );
              }

              return Column(
                children: projects
                    .map(
                      (p) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            final defaultEnvironment =
                                p.environments
                                    .where((env) => env.isDefault)
                                    .firstOrNull ??
                                p.environments.firstOrNull;

                            if (defaultEnvironment != null) {
                              context.go(
                                '/projects/${p.id}/environments/${defaultEnvironment.id}',
                              );
                              return;
                            }

                            context.go('/projects/${p.id}');
                          },
                          child: ShadCard(
                            child: Row(
                              children: [
                                const Icon(LucideIcons.folder),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.name,
                                        style: ShadTheme.of(context).textTheme.p
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      if (p.description.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          p.description,
                                          style: ShadTheme.of(
                                            context,
                                          ).textTheme.muted,
                                        ),
                                      ],
                                      const SizedBox(height: 4),
                                      Text(
                                        'Created ${_formatRelativeDate(p.createdAt)}  ·  ${p.serviceCount} service${p.serviceCount == 1 ? '' : 's'}',
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
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Project> _applyFilters(List<Project> projects) {
    final filtered = projects
        .where((p) => p.name.toLowerCase().contains(_filter.toLowerCase()))
        .toList();

    filtered.sort((a, b) {
      return switch (_sort) {
        'oldest' => a.createdAt.compareTo(b.createdAt),
        'az' => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        _ => b.createdAt.compareTo(a.createdAt),
      };
    });

    return filtered;
  }

  String _formatRelativeDate(DateTime createdAt) {
    final now = DateTime.now().toUtc();
    final difference = now.difference(createdAt.toUtc());

    if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months == 1 ? '' : 's'} ago';
    }

    if (difference.inDays >= 1) {
      final days = difference.inDays;
      return '$days day${days == 1 ? '' : 's'} ago';
    }

    if (difference.inHours >= 1) {
      final hours = difference.inHours;
      return '$hours hour${hours == 1 ? '' : 's'} ago';
    }

    final minutes = difference.inMinutes.clamp(0, 59);
    return '$minutes minute${minutes == 1 ? '' : 's'} ago';
  }
}
