import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/inquiry.dart';
import '../../data/services/inquiries_service.dart';

class InquiryDetailPage extends StatefulWidget {
  const InquiryDetailPage({super.key, required this.inquiryId});

  final String inquiryId;

  @override
  State<InquiryDetailPage> createState() => _InquiryDetailPageState();
}

class _InquiryDetailPageState extends State<InquiryDetailPage> {
  Inquiry? _inquiry;
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
      final data = await InquiriesService.instance.fetchOne(widget.inquiryId);
      if (mounted) setState(() => _inquiry = data);
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

    final q = _inquiry!;
    final dateStr =
        '${q.createdAt.day.toString().padLeft(2, '0')}.${q.createdAt.month.toString().padLeft(2, '0')}.${q.createdAt.year}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _KV(label: 'Betreff', value: q.subject),
          const SizedBox(height: 16),
          _KV(label: 'Name', value: q.name),
          const SizedBox(height: 16),
          _EmailKV(email: q.email),
          const SizedBox(height: 16),
          _KV(label: 'Datum', value: dateStr),
          const SizedBox(height: 24),
          Text('Nachricht', style: theme.textTheme.muted),
          const SizedBox(height: 6),
          Text(q.message, style: theme.textTheme.p),
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

class _EmailKV extends StatelessWidget {
  const _EmailKV({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('E-Mail', style: theme.textTheme.muted),
        const SizedBox(height: 2),
        GestureDetector(
          onTap: () => launchUrl(Uri.parse('mailto:$email')),
          child: Text(
            email,
            style: theme.textTheme.p.copyWith(
              color: theme.colorScheme.primary,
              decoration: TextDecoration.underline,
              decorationColor: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
