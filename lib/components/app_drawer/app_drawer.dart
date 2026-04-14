import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../navigation/navigation_tree.dart';
import '../../services/auth_service.dart';
import '../../services/sync_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            _DrawerHeader(),
            const Divider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                children: [
                  for (final group in navigationTree) ...[
                    if (group.label.isNotEmpty) _SectionLabel(label: group.label),
                    for (final section in group.sections) ...[
                      if (section.label.isNotEmpty)
                        _SubsectionLabel(label: section.label),
                      for (final item in section.items)
                        _NavItem(
                          icon: item.icon,
                          label: item.label,
                          route: item.route,
                          current: location,
                        ),
                    ],
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
            const Divider(),
            _DrawerFooter(onToggleTheme: onToggleTheme),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Temporary Disabled: App-Logo
          // const Icon(LucideIcons.layoutDashboard, size: 22),
          // const SizedBox(width: 12),
          Text(
            'Customer Relationship Management',
            style: ShadTheme.of(
              context,
            ).textTheme.p.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.current,
  });

  final IconData icon;
  final String label;
  final String route;
  final String current;

  @override
  Widget build(BuildContext context) {
    final isActive = current == route;
    return ShadButton.ghost(
      width: double.infinity,
      mainAxisAlignment: MainAxisAlignment.start,
      onPressed: () {
        Scaffold.of(context).closeDrawer();
        context.go(route);
      },
      leading: Icon(icon),
      backgroundColor: isActive
          ? ShadTheme.of(context).colorScheme.accent
          : null,
      child: Text(label),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(label, style: ShadTheme.of(context).textTheme.muted),
    );
  }
}

class _SubsectionLabel extends StatelessWidget {
  const _SubsectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Text(
        label,
        style: ShadTheme.of(context).textTheme.small.copyWith(
          color: ShadTheme.of(context).colorScheme.mutedForeground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DrawerFooter extends StatefulWidget {
  const _DrawerFooter({required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  State<_DrawerFooter> createState() => _DrawerFooterState();
}

class _DrawerFooterState extends State<_DrawerFooter> {
  final _popoverController = ShadPopoverController();

  @override
  void dispose() {
    _popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: ShadPopover(
        controller: _popoverController,
        anchor: const ShadAnchorAuto(
          followerAnchor: Alignment.bottomCenter,
          targetAnchor: Alignment.topCenter,
          offset: Offset(0, -8),
        ),
        popover: (context) => _AccountPopoverContent(
          onToggleTheme: widget.onToggleTheme,
          onClose: _popoverController.hide,
        ),
        child: InkWell(
          onTap: _popoverController.toggle,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                ShadAvatar(
                  null,
                  placeholder: Text(auth.currentUserInitials),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        auth.currentUserName.isNotEmpty
                            ? auth.currentUserName
                            : 'Account',
                        style: ShadTheme.of(context).textTheme.p.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        auth.currentUserEmail,
                        style: ShadTheme.of(context).textTheme.muted,
                      ),
                    ],
                  ),
                ),
                const Icon(LucideIcons.chevronsUpDown, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AccountPopoverContent extends StatelessWidget {
  const _AccountPopoverContent({
    required this.onToggleTheme,
    required this.onClose,
  });

  final VoidCallback onToggleTheme;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final auth = AuthService.instance;

    return SizedBox(
      width: 260,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                ShadAvatar(null, placeholder: Text(auth.currentUserInitials)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.currentUserName.isNotEmpty
                            ? auth.currentUserName
                            : 'Account',
                        style: ShadTheme.of(context).textTheme.p.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        auth.currentUserEmail,
                        style: ShadTheme.of(context).textTheme.muted,
                      ),
                    ],
                  ),
                ),
                ShadButton(
                  onPressed: onToggleTheme,
                  size: ShadButtonSize.sm,
                  child: Icon(
                    Theme.of(context).brightness == Brightness.dark
                        ? LucideIcons.moon
                        : LucideIcons.sun,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _PopoverItem(
            label: 'Settings',
            onTap: () {
              onClose();
              Scaffold.of(context).closeDrawer();
              context.go('/settings');
            },
          ),
          _PopoverItem(
            label: 'Abmelden',
            onTap: () async {
              onClose();
              await auth.logout();
              if (context.mounted) {
                Scaffold.of(context).closeDrawer();
                context.go('/connecting');
              }
            },
          ),
        ],
      ),
    );
  }
}

class _PopoverItem extends StatelessWidget {
  const _PopoverItem({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ShadButton.ghost(
      width: double.infinity,
      mainAxisAlignment: MainAxisAlignment.start,
      onPressed: onTap,
      child: Text(label),
    );
  }
}
