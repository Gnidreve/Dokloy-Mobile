import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class NavigationGroup {
  const NavigationGroup({required this.label, required this.sections});

  final String label;
  final List<NavigationSection> sections;
}

class NavigationSection {
  const NavigationSection({required this.label, required this.items});

  final String label;
  final List<NavigationItem> items;
}

class NavigationItem {
  const NavigationItem({
    required this.label,
    required this.route,
    required this.icon,
  });

  final String label;
  final String route;
  final IconData icon;
}

const navigationTree = <NavigationGroup>[
  NavigationGroup(
    label: 'Home',
    sections: [
      NavigationSection(
        label: '',
        items: [
          NavigationItem(
            label: 'Projects',
            route: '/projects',
            icon: LucideIcons.folder,
          ),
          NavigationItem(
            label: 'Deployments',
            route: '/deployments',
            icon: LucideIcons.rocket,
          ),
          NavigationItem(
            label: 'Monitoring',
            route: '/monitoring',
            icon: LucideIcons.chartBar,
          ),
          NavigationItem(
            label: 'Schedules',
            route: '/schedules',
            icon: LucideIcons.clock,
          ),
          NavigationItem(
            label: 'Traefik File System',
            route: '/traefik',
            icon: LucideIcons.hardDrive,
          ),
          NavigationItem(
            label: 'Docker',
            route: '/docker',
            icon: LucideIcons.layoutGrid,
          ),
          NavigationItem(
            label: 'Swarm',
            route: '/swarm',
            icon: LucideIcons.network,
          ),
          NavigationItem(
            label: 'Requests',
            route: '/requests',
            icon: LucideIcons.arrowRightLeft,
          ),
        ],
      ),
    ],
  ),
  NavigationGroup(
    label: 'Settings',
    sections: [
      NavigationSection(
        label: '',
        items: [
          NavigationItem(
            label: 'Web Server',
            route: '/web-server',
            icon: LucideIcons.activity,
          ),
          NavigationItem(
            label: 'SSH Keys',
            route: '/ssh-keys',
            icon: LucideIcons.key,
          ),
          NavigationItem(label: 'AI', route: '/ai', icon: LucideIcons.activity),
          NavigationItem(
            label: 'Git',
            route: '/git',
            icon: LucideIcons.arrowRightLeft,
          ),
          NavigationItem(
            label: 'Registry',
            route: '/registry',
            icon: LucideIcons.layoutGrid,
          ),
          NavigationItem(
            label: 'S3 Destinations',
            route: '/s3-destinations',
            icon: LucideIcons.hardDrive,
          ),
          NavigationItem(
            label: 'Certificates',
            route: '/certificates',
            icon: LucideIcons.server,
          ),
          NavigationItem(
            label: 'Cluster',
            route: '/cluster',
            icon: LucideIcons.network,
          ),
          NavigationItem(
            label: 'Notifications',
            route: '/notifications',
            icon: LucideIcons.bell,
          ),
          NavigationItem(
            label: 'Remote Servers',
            route: '/remote-servers',
            icon: LucideIcons.server,
          ),
        ],
      ),
    ],
  ),
];

NavigationItem? findNavigationItem(String route) {
  for (final group in navigationTree) {
    for (final section in group.sections) {
      for (final item in section.items) {
        if (item.route == route) return item;
      }
    }
  }
  return null;
}

List<String> breadcrumbsForRoute(String route) {
  if (route.startsWith('/projects/')) {
    final segments = Uri.parse(route).pathSegments;
    if (segments.length >= 4 && segments[2] == 'environments') {
      return ['Projects', segments[1], segments[3]];
    }
    if (segments.length >= 2) return ['Projects', segments[1]];
  }

  for (final group in navigationTree) {
    for (final section in group.sections) {
      for (final item in section.items) {
        if (item.route == route) return [item.label];
      }
    }
  }
  return const ['Dokploy'];
}
