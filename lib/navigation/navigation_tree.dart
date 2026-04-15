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
    label: '', // Group-Label bewusst leer — kein Abschnittstitel gewünscht
    sections: [
      NavigationSection(
        label: '',
        items: [
          NavigationItem(
            label: 'Suche',
            route: '/search',
            icon: LucideIcons.search,
          ),
          NavigationItem(
            label: 'Dashboard',
            route: '/home',
            icon: LucideIcons.layoutDashboard,
          ),
          NavigationItem(
            label: 'Settings',
            route: '/settings',
            icon: LucideIcons.settings,
          ),
          NavigationItem(
            label: 'Kontakte',
            route: '/customers',
            icon: LucideIcons.users,
          ),
          NavigationItem(
            label: 'Anfragen',
            route: '/inquiries',
            icon: LucideIcons.mail,
          ),
          NavigationItem(
            label: 'Verträge',
            route: '/contracts',
            icon: LucideIcons.fileText,
          ),
          NavigationItem(
            label: 'Rechnungen',
            route: '/invoices',
            icon: LucideIcons.fileText,
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

class BreadcrumbSegment {
  const BreadcrumbSegment(this.label, {this.parentRoute});

  final String label;

  /// Wenn gesetzt, wird dieses Segment als anklickbarer Link gerendert,
  /// der per pop() zurücknavigiert — oder bei fehlendem Stack per go(parentRoute).
  final String? parentRoute;
}

List<BreadcrumbSegment> breadcrumbsForRoute(String route) {
  if (route.startsWith('/customers/')) {
    return const [
      BreadcrumbSegment('Kontakte', parentRoute: '/customers'),
      BreadcrumbSegment('Details'),
    ];
  }
  if (route.startsWith('/inquiries/')) {
    return const [
      BreadcrumbSegment('Anfragen', parentRoute: '/inquiries'),
      BreadcrumbSegment('Details'),
    ];
  }
  if (route.startsWith('/invoices/')) {
    return const [
      BreadcrumbSegment('Rechnungen', parentRoute: '/invoices'),
      BreadcrumbSegment('Details'),
    ];
  }
  if (route.startsWith('/contracts/')) {
    return const [
      BreadcrumbSegment('Verträge', parentRoute: '/contracts'),
      BreadcrumbSegment('Details'),
    ];
  }
  for (final group in navigationTree) {
    for (final section in group.sections) {
      for (final item in section.items) {
        if (item.route == route) return [BreadcrumbSegment(item.label)];
      }
    }
  }
  return const [BreadcrumbSegment('MyCRM')];
}
