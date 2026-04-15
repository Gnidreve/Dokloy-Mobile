import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'components/app_drawer/app_drawer.dart';
import 'data/models/inquiry.dart';
import 'navigation/navigation_tree.dart';
import 'pages/connecting_page.dart';
import 'pages/contracts/contract_detail_page.dart';
import 'pages/contracts/contracts_page.dart';
import 'pages/customers/customer_detail_page.dart';
import 'pages/emails/email_detail_page.dart';
import 'pages/customers/customers_page.dart';
import 'pages/emails/emails_page.dart';
import 'pages/home/home_page.dart';
import 'pages/inquiries/inquiries_page.dart';
import 'pages/inquiries/inquiry_detail_page.dart';
import 'pages/invoices/invoice_detail_page.dart';
import 'pages/invoices/invoices_page.dart';
import 'pages/login/login_page.dart';
import 'pages/search/search_page.dart';
import 'pages/settings/settings_page.dart';
import 'stores/contracts_store.dart';
import 'stores/customers_store.dart';
import 'stores/emails_store.dart';
import 'stores/inquiries_store.dart';
import 'stores/invoices_store.dart';
import 'stores/todos_store.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter({required VoidCallback onToggleTheme}) => GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/connecting',
  routes: [
    GoRoute(path: '/connecting', builder: (_, _) => const ConnectingPage()),
    GoRoute(
      path: '/login',
      builder: (_, state) => LoginPage(initialError: state.extra as String?),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) =>
          _ShellWrapper(onToggleTheme: onToggleTheme, child: child),
      routes: [
        GoRoute(path: '/search', builder: (_, _) => const SearchPage()),
        GoRoute(path: '/home', builder: (_, _) => const HomePage()),
        GoRoute(path: '/settings', builder: (_, _) => const SettingsPage()),
        GoRoute(
          path: '/customers',
          builder: (_, _) => const CustomersPage(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, state) =>
                  CustomerDetailPage(customerId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: '/inquiries',
          builder: (_, _) => const InquiriesPage(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, state) =>
                  InquiryDetailPage(inquiryId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: '/invoices',
          builder: (_, _) => const InvoicesPage(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, state) =>
                  InvoiceDetailPage(invoiceId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: '/emails',
          builder: (_, _) => const EmailsPage(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, state) =>
                  EmailDetailPage(emailId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: '/contracts',
          builder: (_, _) => const ContractsPage(),
          routes: [
            GoRoute(
              path: ':id',
              builder: (_, state) =>
                  ContractDetailPage(contractId: state.pathParameters['id']!),
            ),
          ],
        ),
      ],
    ),
  ],
);

// ── Shell ─────────────────────────────────────────────────────────────────────

class _ShellWrapper extends StatefulWidget {
  const _ShellWrapper({required this.onToggleTheme, required this.child});

  final VoidCallback onToggleTheme;
  final Widget child;

  @override
  State<_ShellWrapper> createState() => _ShellWrapperState();
}

class _ShellWrapperState extends State<_ShellWrapper> {
  @override
  void initState() {
    super.initState();
    // Stores eager initialisieren — Daten laden & Realtime abonnieren.
    // Jeder Store ist sein eigener Single Source of Truth; kein SyncService mehr.
    CustomersStore.instance;
    InquiriesStore.instance;
    InvoicesStore.instance;
    EmailsStore.instance;
    ContractsStore.instance;
    TodosStore.instance;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final segments = breadcrumbsForRoute(location);

    return Scaffold(
      drawer: AppDrawer(onToggleTheme: widget.onToggleTheme),
      appBar: AppBar(
        titleSpacing: 0,
        leadingWidth: 52,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: ShadSeparator.horizontal(margin: EdgeInsets.zero),
        ),
        leading: context.canPop()
            ? IconButton(
                icon: const Icon(LucideIcons.arrowLeft),
                onPressed: () => context.pop(),
              )
            : Builder(
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
            ShadBreadcrumb(
              spacing: 6,
              separator: ShadBreadcrumbSeparator(
                color: ShadTheme.of(context).colorScheme.mutedForeground,
                size: 12,
              ),
              children: [
                for (final seg in segments)
                  if (seg.parentRoute != null)
                    ShadBreadcrumbLink(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(seg.parentRoute!);
                        }
                      },
                      child: Text(
                        seg.label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    )
                  else
                    Text(
                      seg.label,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
              ],
            ),
          ],
        ),
      ),
      body: _NotificationLayer(child: widget.child),
    );
  }
}

// ── Notification Layer ────────────────────────────────────────────────────────

class _NotificationLayer extends StatefulWidget {
  const _NotificationLayer({required this.child});

  final Widget child;

  @override
  State<_NotificationLayer> createState() => _NotificationLayerState();
}

class _NotificationLayerState extends State<_NotificationLayer> {
  StreamSubscription<Inquiry>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = InquiriesStore.instance.newInquiries.listen(_onNewInquiry);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _onNewInquiry(Inquiry inq) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Neue Anfrage von ${inq.name}'),
        action: SnackBarAction(
          label: 'Öffnen',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            context.go('/inquiries/${inq.id}');
          },
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
