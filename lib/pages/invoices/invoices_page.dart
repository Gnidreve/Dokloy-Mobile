import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../data/models/invoice.dart';
import '../../stores/invoices_store.dart';

class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key});

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
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
      listenable: InvoicesStore.instance,
      builder: (context, _) {
        final store = InvoicesStore.instance;
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
                placeholder: const Text('Rechnungen suchen …'),
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
                                    LucideIcons.fileText,
                                    size: 48,
                                    color: theme.colorScheme.mutedForeground,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Keine Rechnungen gefunden',
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
                        itemBuilder: (context, i) =>
                            _InvoiceCard(invoice: items[i]),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final dateStr =
        '${invoice.createdAt.day.toString().padLeft(2, '0')}.${invoice.createdAt.month.toString().padLeft(2, '0')}.${invoice.createdAt.year}';
    final amountStr =
        '${invoice.amount.toStringAsFixed(2).replaceAll('.', ',')} €';

    return ShadCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.title,
                  style: theme.textTheme.p.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(dateStr, style: theme.textTheme.muted),
              ],
            ),
          ),
          Text(amountStr, style: theme.textTheme.p),
        ],
      ),
    );
  }
}
