import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:go_router/go_router.dart';

import '../../components/app_toast/app_toast.dart';
import '../../data/models/contract.dart';
import '../../data/models/email_item.dart';
import '../../data/models/inquiry.dart';
import '../../data/models/invoice.dart';
import '../../data/services/customers_service.dart';
import '../../stores/contracts_store.dart';
import '../../stores/emails_store.dart';
import '../../stores/inquiries_store.dart';
import '../../stores/invoices_store.dart';

class CustomerDetailPage extends StatefulWidget {
  const CustomerDetailPage({super.key, required this.customerId});

  final String customerId;

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _zipController = TextEditingController();
  final _townController = TextEditingController();

  String _tab = 'allgemein';
  String? _error;
  bool _loading = true;
  bool _saving = false;
  bool _isDirty = false;

  // Ursprungswerte für isDirty-Vergleich
  String _origName = '';
  String _origEmail = '';
  String _origPhone = '';
  String _origStreet = '';
  String _origZip = '';
  String _origTown = '';

  @override
  void initState() {
    super.initState();
    _load();
    for (final c in [
      _nameController,
      _emailController,
      _phoneController,
      _streetController,
      _zipController,
      _townController,
    ]) {
      c.addListener(_checkDirty);
    }
  }

  @override
  void dispose() {
    for (final c in [
      _nameController,
      _emailController,
      _phoneController,
      _streetController,
      _zipController,
      _townController,
    ]) {
      c.removeListener(_checkDirty);
      c.dispose();
    }
    super.dispose();
  }

  void _checkDirty() {
    final dirty =
        _nameController.text != _origName ||
        _emailController.text != _origEmail ||
        _phoneController.text != _origPhone ||
        _streetController.text != _origStreet ||
        _zipController.text != _origZip ||
        _townController.text != _origTown;
    if (dirty != _isDirty) setState(() => _isDirty = dirty);
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await CustomersService.instance.fetchOne(widget.customerId);
      if (!mounted) return;
      _origName = data.name;
      _origEmail = data.email;
      _origPhone = data.phone;
      _origStreet = data.street;
      _origZip = data.zip == 0 ? '' : data.zip.toString();
      _origTown = data.town;
      _nameController.text = _origName;
      _emailController.text = _origEmail;
      _phoneController.text = _origPhone;
      _streetController.text = _origStreet;
      _zipController.text = _origZip;
      _townController.text = _origTown;
      setState(() => _isDirty = false);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final zip = int.tryParse(_zipController.text.trim()) ?? 0;
    setState(() => _saving = true);
    try {
      await CustomersService.instance.update(
        widget.customerId,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        street: _streetController.text.trim(),
        zip: zip,
        town: _townController.text.trim(),
      );
      if (!mounted) return;
      _origName = _nameController.text;
      _origEmail = _emailController.text;
      _origPhone = _phoneController.text;
      _origStreet = _streetController.text;
      _origZip = _zipController.text;
      _origTown = _townController.text;
      setState(() => _isDirty = false);
      AppToast.showSuccess(context, title: 'Gespeichert');
    } catch (e) {
      if (mounted) {
        AppToast.showError(
          context,
          title: 'Fehler beim Speichern',
          subtitle: e.toString(),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
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

    const h = EdgeInsets.symmetric(horizontal: 16);
    final onAkte = _tab == 'akte';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Tab-Leiste
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: ShadTabs<String>(
            value: _tab,
            onChanged: (t) => setState(() => _tab = t),
            tabs: const [
              ShadTab(
                value: 'allgemein',
                content: SizedBox.shrink(),
                child: Text('Allgemein'),
              ),
              ShadTab(
                value: 'akte',
                content: SizedBox.shrink(),
                child: Text('Akte'),
              ),
            ],
          ),
        ),
        // Inhalt je Tab
        Expanded(
          child: onAkte
              ? _AkteTab(customerId: widget.customerId)
              : _AllgemeinTab(
                  nameController: _nameController,
                  emailController: _emailController,
                  phoneController: _phoneController,
                  streetController: _streetController,
                  zipController: _zipController,
                  townController: _townController,
                  saving: _saving,
                  h: h,
                  onSubmit: _save,
                ),
        ),
        if (!onAkte)
          _SaveBar(saving: _saving, isDirty: _isDirty, onSave: _save),
      ],
    );
  }
}

// ─── Allgemein ───────────────────────────────────────────────────────────────

class _AllgemeinTab extends StatelessWidget {
  const _AllgemeinTab({
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.streetController,
    required this.zipController,
    required this.townController,
    required this.saving,
    required this.h,
    required this.onSubmit,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController streetController;
  final TextEditingController zipController;
  final TextEditingController townController;
  final bool saving;
  final EdgeInsets h;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: h,
            child: ShadInputFormField(
              controller: nameController,
              label: const Text('Name'),
              placeholder: const Text('Kundenname'),
              textInputAction: TextInputAction.next,
              enabled: !saving,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: h,
            child: ShadInputFormField(
              controller: emailController,
              label: const Text('E-Mail'),
              placeholder: const Text('name@beispiel.de'),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              enabled: !saving,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: h,
            child: ShadInputFormField(
              controller: phoneController,
              label: const Text('Telefon'),
              placeholder: const Text('+49 123 456789'),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              enabled: !saving,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: h,
            child: ShadInputFormField(
              controller: streetController,
              label: const Text('Straße'),
              placeholder: const Text('Musterstraße 1'),
              textInputAction: TextInputAction.next,
              enabled: !saving,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 160,
                  child: ShadInputFormField(
                    controller: zipController,
                    label: const Text('PLZ'),
                    placeholder: const Text('12345'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(5),
                    ],
                    textInputAction: TextInputAction.next,
                    enabled: !saving,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ShadInputFormField(
                    controller: townController,
                    label: const Text('Ort'),
                    placeholder: const Text('Musterstadt'),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => onSubmit(),
                    enabled: !saving,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Akte ─────────────────────────────────────────────────────────────────────

class _AkteTab extends StatefulWidget {
  const _AkteTab({required this.customerId});
  final String customerId;

  @override
  State<_AkteTab> createState() => _AkteTabState();
}

class _AkteTabState extends State<_AkteTab> {
  String _filter = 'alle';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        InquiriesStore.instance,
        InvoicesStore.instance,
        ContractsStore.instance,
        EmailsStore.instance,
      ]),
      builder: (context, _) => _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = ShadTheme.of(context);

    final loading =
        InquiriesStore.instance.loading ||
        InvoicesStore.instance.loading ||
        ContractsStore.instance.loading ||
        EmailsStore.instance.loading;

    final showInquiries = _filter == 'alle' || _filter == 'anfragen';
    final showInvoices = _filter == 'alle' || _filter == 'rechnungen';
    final showContracts = _filter == 'alle' || _filter == 'vertraege';
    final showEmails = _filter == 'alle' || _filter == 'emails';

    final visibleInquiries = showInquiries
        ? InquiriesStore.instance.byCustomer(widget.customerId)
        : const <Inquiry>[];
    final visibleInvoices = showInvoices
        ? InvoicesStore.instance.byCustomer(widget.customerId)
        : const <Invoice>[];
    final visibleContracts = showContracts
        ? ContractsStore.instance.byCustomer(widget.customerId)
        : const <Contract>[];
    final visibleEmails = showEmails
        ? EmailsStore.instance.byCustomer(widget.customerId)
        : const <EmailItem>[];
    final isEmpty =
        visibleInquiries.isEmpty &&
        visibleInvoices.isEmpty &&
        visibleContracts.isEmpty &&
        visibleEmails.isEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ShadSelect<String>(
            initialValue: 'alle',
            options: const [
              ShadOption(value: 'alle', child: Text('Alles')),
              ShadOption(value: 'anfragen', child: Text('Anfragen')),
              ShadOption(value: 'rechnungen', child: Text('Rechnungen')),
              ShadOption(value: 'vertraege', child: Text('Verträge')),
              ShadOption(value: 'emails', child: Text('E-Mails')),
            ],
            selectedOptionBuilder: (_, v) => Text(switch (v) {
              'anfragen' => 'Anfragen',
              'rechnungen' => 'Rechnungen',
              'vertraege' => 'Verträge',
              'emails' => 'E-Mails',
              _ => 'Alles',
            }),
            onChanged: (v) => setState(() => _filter = v ?? 'alle'),
          ),
          const SizedBox(height: 24),
          if (loading)
            const Center(child: CircularProgressIndicator())
          else if (isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Text('Nichts vorhanden'),
              ),
            )
          else ...[
            if (showInquiries && visibleInquiries.isNotEmpty) ...[
              Text('Anfragen', style: theme.textTheme.muted),
              const SizedBox(height: 8),
              for (final inq in visibleInquiries)
                _AkteCard(
                  title: inq.name,
                  subtitle: inq.subject,
                  onTap: () => context.push('/inquiries/${inq.id}'),
                ),
            ],
            if (showInvoices && visibleInvoices.isNotEmpty) ...[
              if (showInquiries && visibleInquiries.isNotEmpty)
                const SizedBox(height: 16),
              Text('Rechnungen', style: theme.textTheme.muted),
              const SizedBox(height: 8),
              for (final inv in visibleInvoices)
                _AkteCard(
                  title: inv.title,
                  subtitle:
                      '${inv.amount.toStringAsFixed(2).replaceAll('.', ',')} €',
                  onTap: () => context.push('/invoices/${inv.id}'),
                ),
            ],
            if (showContracts && visibleContracts.isNotEmpty) ...[
              if ((showInquiries && visibleInquiries.isNotEmpty) ||
                  (showInvoices && visibleInvoices.isNotEmpty))
                const SizedBox(height: 16),
              Text('Verträge', style: theme.textTheme.muted),
              const SizedBox(height: 8),
              for (final con in visibleContracts)
                _AkteCard(
                  title: con.keyword,
                  subtitle:
                      '${con.amount.toStringAsFixed(2).replaceAll('.', ',')} € · ${con.isActive ? 'Aktiv' : 'Inaktiv'}',
                  onTap: () => context.push('/contracts/${con.id}'),
                ),
            ],
            if (showEmails && visibleEmails.isNotEmpty) ...[
              if ((showInquiries && visibleInquiries.isNotEmpty) ||
                  (showInvoices && visibleInvoices.isNotEmpty) ||
                  (showContracts && visibleContracts.isNotEmpty))
                const SizedBox(height: 16),
              Text('E-Mails', style: theme.textTheme.muted),
              const SizedBox(height: 8),
              for (final email in visibleEmails)
                _AkteCard(
                  title: email.subject.trim().isEmpty
                      ? '(Ohne Betreff)'
                      : email.subject,
                  subtitle: '${email.from} -> ${email.to}',
                  onTap: () => context.push('/emails/${email.id}'),
                ),
            ],
          ],
        ],
      ),
    );
  }
}

class _AkteCard extends StatelessWidget {
  const _AkteCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ShadCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    Text(subtitle, style: theme.textTheme.muted),
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

// ─── Save Bar ─────────────────────────────────────────────────────────────────

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.saving,
    required this.isDirty,
    required this.onSave,
  });

  final bool saving;
  final bool isDirty;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: ShadButton(
          width: double.infinity,
          onPressed: (saving || !isDirty) ? null : onSave,
          child: saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Speichern'),
        ),
      ),
    );
  }
}
