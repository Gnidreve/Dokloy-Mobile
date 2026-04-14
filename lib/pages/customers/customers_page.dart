import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../stores/customers_store.dart';

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
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
      listenable: CustomersStore.instance,
      builder: (context, _) {
        final store = CustomersStore.instance;
        final theme = ShadTheme.of(context);

        if (store.loading) return const Center(child: CircularProgressIndicator());

        if (store.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Fehler beim Laden', style: theme.textTheme.h4),
                  const SizedBox(height: 8),
                  Text(store.error!, style: theme.textTheme.muted, textAlign: TextAlign.center),
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
                placeholder: const Text('Kunden suchen …'),
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
                    ? CustomScrollView(slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.users, size: 48,
                                    color: theme.colorScheme.mutedForeground),
                                const SizedBox(height: 16),
                                Text('Keine Kunden gefunden',
                                    style: theme.textTheme.muted),
                              ],
                            ),
                          ),
                        ),
                      ])
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final c = items[i];
                          return ShadCard(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => context.go('/customers/${c.id}'),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.name,
                                          style: theme.textTheme.p.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${c.street}, ${c.zip} ${c.town}',
                                          style: theme.textTheme.muted,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(LucideIcons.chevronRight, size: 16,
                                      color: theme.colorScheme.mutedForeground),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
