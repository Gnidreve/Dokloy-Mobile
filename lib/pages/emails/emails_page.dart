import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../data/models/email_item.dart';
import '../../stores/emails_store.dart';

class EmailsPage extends StatefulWidget {
  const EmailsPage({super.key});

  @override
  State<EmailsPage> createState() => _EmailsPageState();
}

class _EmailsPageState extends State<EmailsPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: EmailsStore.instance,
      builder: (context, _) {
        final store = EmailsStore.instance;
        final theme = ShadTheme.of(context);

        if (store.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (store.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Fehler beim Laden', style: theme.textTheme.h4),
                  const SizedBox(height: 8),
                  Text(
                    store.error!,
                    style: theme.textTheme.muted,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ShadButton.outline(
                    onPressed: store.reload,
                    leading: const Icon(LucideIcons.refreshCw),
                    child: const Text('Erneut versuchen'),
                  ),
                ],
              ),
            ),
          );
        }

        final items = store.forQuery(_query);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: ShadInput(
                controller: _searchController,
                placeholder: const Text('E-Mails suchen …'),
                leading: const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(LucideIcons.search, size: 16),
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: store.reload,
                child: items.isEmpty
                    ? CustomScrollView(
                        slivers: [
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.mail,
                                    size: 48,
                                    color: theme.colorScheme.mutedForeground,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Keine E-Mails gefunden',
                                    style: theme.textTheme.muted,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) => _EmailCard(
                          email: items[i],
                          onTap: () => context.go('/emails/${items[i].id}'),
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EmailCard extends StatelessWidget {
  const _EmailCard({required this.email, required this.onTap});

  final EmailItem email;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final title = email.subject.trim().isEmpty
        ? '(Ohne Betreff)'
        : email.subject.trim();
    final from = email.from.trim().isEmpty ? 'Unbekannt' : email.from.trim();
    final to = email.to.trim().isEmpty ? 'Unbekannt' : email.to.trim();

    return ShadCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Material(
        type: MaterialType.transparency,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.p.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text('Von: $from', style: theme.textTheme.muted),
                    const SizedBox(height: 2),
                    Text('An: $to', style: theme.textTheme.muted),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: 16,
                color: theme.colorScheme.mutedForeground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
