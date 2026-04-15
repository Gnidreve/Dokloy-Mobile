import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../data/services/invoices_service.dart';
import '../../data/models/invoice.dart';

class InvoiceDetailPage extends StatefulWidget {
  const InvoiceDetailPage({super.key, required this.invoiceId});

  final String invoiceId;

  @override
  State<InvoiceDetailPage> createState() => _InvoiceDetailPageState();
}

class _InvoiceDetailPageState extends State<InvoiceDetailPage> {
  Invoice? _invoice;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await InvoicesService.instance.fetchOne(widget.invoiceId);
      if (mounted) setState(() => _invoice = data);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Fehler beim Laden', style: theme.textTheme.h4),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: theme.textTheme.muted,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ShadButton.outline(
                onPressed: _load,
                leading: const Icon(LucideIcons.refreshCw),
                child: const Text('Erneut versuchen'),
              ),
            ],
          ),
        ),
      );
    }

    final inv = _invoice!;
    final dateStr =
        '${inv.createdAt.day.toString().padLeft(2, '0')}.${inv.createdAt.month.toString().padLeft(2, '0')}.${inv.createdAt.year}';
    final amountStr = '${inv.amount.toStringAsFixed(2).replaceAll('.', ',')} €';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _KV(label: 'Titel', value: inv.title),
          const SizedBox(height: 16),
          _KV(label: 'Betrag', value: amountStr),
          const SizedBox(height: 16),
          _KV(label: 'Datum', value: dateStr),
        ],
      ),
    );
  }
}

class _KV extends StatelessWidget {
  const _KV({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.muted),
        const SizedBox(height: 2),
        Text(value, style: theme.textTheme.p),
      ],
    );
  }
}
