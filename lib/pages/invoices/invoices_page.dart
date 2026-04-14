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
  String _tab = 'outbounding';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: InvoicesStore.instance,
      builder: (context, _) {
        final store = InvoicesStore.instance;
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

        final direction = _tab == 'outbounding'
            ? InvoiceDirection.outbounding
            : InvoiceDirection.incoming;
        final shown = store.byDirection(direction);
        final emptyLabel = _tab == 'outbounding'
            ? 'Keine Ausgangsrechnungen'
            : 'Keine Eingangsrechnungen';

        return RefreshIndicator(
          onRefresh: store.reload,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: ShadTabs<String>(
                  value: _tab,
                  onChanged: (t) => setState(() => _tab = t),
                  tabs: const [
                    ShadTab(value: 'outbounding', content: SizedBox.shrink(), child: Text('Ausgang')),
                    ShadTab(value: 'incoming',    content: SizedBox.shrink(), child: Text('Eingang')),
                  ],
                ),
              ),
              Expanded(
                child: shown.isEmpty
                    ? CustomScrollView(slivers: [
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.fileText, size: 48,
                                    color: theme.colorScheme.mutedForeground),
                                const SizedBox(height: 16),
                                Text(emptyLabel,
                                    style: theme.textTheme.muted),
                              ],
                            ),
                          ),
                        ),
                      ])
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: shown.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) => _InvoiceCard(invoice: shown[i]),
                      ),
              ),
            ],
          ),
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
                  style: theme.textTheme.p.copyWith(fontWeight: FontWeight.w600),
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
