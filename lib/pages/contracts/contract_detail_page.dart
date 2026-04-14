import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../data/models/contract.dart';
import '../../data/services/contracts_service.dart';

class ContractDetailPage extends StatefulWidget {
  const ContractDetailPage({super.key, required this.contractId});

  final String contractId;

  @override
  State<ContractDetailPage> createState() => _ContractDetailPageState();
}

class _ContractDetailPageState extends State<ContractDetailPage> {
  Contract? _contract;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ContractsService.instance.fetchOne(widget.contractId);
      if (mounted) setState(() => _contract = data);
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
              Text(_error!, style: theme.textTheme.muted, textAlign: TextAlign.center),
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

    final c = _contract!;
    final amountStr = '${c.amount.toStringAsFixed(2).replaceAll('.', ',')} €';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _KV(label: 'Bezeichnung', value: c.keyword),
          const SizedBox(height: 16),
          _KV(label: 'Betrag', value: amountStr),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status', style: theme.textTheme.muted),
              const SizedBox(height: 6),
              ShadBadge(
                backgroundColor: c.isActive
                    ? const Color(0xFF16a34a)
                    : theme.colorScheme.muted,
                child: Text(
                  c.isActive ? 'Aktiv' : 'Inaktiv',
                  style: TextStyle(
                    color: c.isActive
                        ? Colors.white
                        : theme.colorScheme.mutedForeground,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
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
