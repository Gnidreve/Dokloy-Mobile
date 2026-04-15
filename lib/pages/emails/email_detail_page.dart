import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/email_item.dart';
import '../../data/services/emails_service.dart';

class EmailDetailPage extends StatefulWidget {
  const EmailDetailPage({super.key, required this.emailId});

  final String emailId;

  @override
  State<EmailDetailPage> createState() => _EmailDetailPageState();
}

class _EmailDetailPageState extends State<EmailDetailPage> {
  EmailItem? _email;
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
      final data = await EmailsService.instance.fetchOne(widget.emailId);
      if (mounted) setState(() => _email = data);
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

    final email = _email!;
    final subject = email.subject.trim().isEmpty
        ? '(Ohne Betreff)'
        : email.subject.trim();
    final from = email.from.trim().isEmpty ? 'Unbekannt' : email.from.trim();
    final to = email.to.trim().isEmpty ? 'Unbekannt' : email.to.trim();
    final body = email.body.trim().isEmpty ? 'Kein Inhalt' : email.body.trim();
    final dateStr =
        '${email.createdAt.day.toString().padLeft(2, '0')}.${email.createdAt.month.toString().padLeft(2, '0')}.${email.createdAt.year}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _KV(label: 'Betreff', value: subject),
          const SizedBox(height: 16),
          _EmailKV(label: 'Von', email: from),
          const SizedBox(height: 16),
          _EmailKV(label: 'An', email: to),
          const SizedBox(height: 16),
          _KV(label: 'Datum', value: dateStr),
          const SizedBox(height: 24),
          Text('Body', style: theme.textTheme.muted),
          const SizedBox(height: 6),
          SelectableText(body, style: theme.textTheme.p),
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
  const _EmailKV({required this.label, required this.email});

  final String label;
  final String email;

  Future<void> _openMail() async {
    await launchUrl(Uri.parse('mailto:$email'));
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.muted),
        const SizedBox(height: 2),
        GestureDetector(
          onTap: _openMail,
          child: Text(
            email,
            style: theme.textTheme.p.copyWith(
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
