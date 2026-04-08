import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../api/index.dart';
import '../../api/user_store.dart';
import '../../components/app_toast/app_toast.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadTabs<String>(
      value: 'account',
      tabs: [
        ShadTab(
          value: 'account',
          child: const Text('Account'),
          content: const _AccountTab(),
        ),
        ShadTab(
          value: 'api-keys',
          child: const Text('API/CLI Keys'),
          content: const _ApiKeysTab(),
        ),
      ],
    );
  }
}

class _AccountTab extends StatefulWidget {
  const _AccountTab();

  @override
  State<_AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<_AccountTab> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _email;
  final TextEditingController _currentPassword = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();

  late String _initialFirstName;
  late String _initialLastName;
  late String _initialEmail;

  bool _isSaving = false;

  bool get _isDirty {
    return _firstName.text != _initialFirstName ||
        _lastName.text != _initialLastName ||
        _email.text != _initialEmail ||
        _currentPassword.text.isNotEmpty ||
        _newPassword.text.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    final user = UserStore.current;
    _initialFirstName = user?.firstName ?? '';
    _initialLastName = user?.lastName ?? '';
    _initialEmail = user?.email ?? '';

    _firstName = TextEditingController(text: _initialFirstName);
    _lastName = TextEditingController(text: _initialLastName);
    _email = TextEditingController(text: _initialEmail);

    for (final c in [_firstName, _lastName, _email, _currentPassword, _newPassword]) {
      c.addListener(_onChanged);
    }
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    for (final c in [_firstName, _lastName, _email, _currentPassword, _newPassword]) {
      c.removeListener(_onChanged);
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await DokployApi().user.update(
            firstName: _firstName.text.trim(),
            lastName: _lastName.text.trim(),
            email: _email.text.trim(),
            password: _newPassword.text.isEmpty ? null : _newPassword.text,
            currentPassword:
                _currentPassword.text.isEmpty ? null : _currentPassword.text,
          );

      if (!mounted) return;

      // Update local store so drawer reflects new name immediately
      final current = UserStore.current;
      if (current != null) {
        UserStore.current = User(
          id: current.id,
          email: _email.text.trim(),
          firstName: _firstName.text.trim(),
          lastName: _lastName.text.trim(),
          image: current.image,
        );
      }

      _initialFirstName = _firstName.text.trim();
      _initialLastName = _lastName.text.trim();
      _initialEmail = _email.text.trim();
      _currentPassword.clear();
      _newPassword.clear();

      AppToast.showSuccess(
        context,
        title: 'Saved',
        subtitle: 'Your profile has been updated.',
      );
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(
        context,
        title: 'Could not save',
        subtitle: e.toString(),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSave = _isDirty && !_isSaving;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.userRound, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Account',
                          style: ShadTheme.of(context).textTheme.h3,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Change the details of your profile here.',
                      style: ShadTheme.of(context).textTheme.muted,
                    ),
                  ],
                ),
              ),
              ShadButton.outline(
                onPressed: null,
                leading: const Icon(LucideIcons.scanFace),
                child: const Text('Enable 2FA'),
              ),
            ],
          ),
          const ShadSeparator.horizontal(),
          const SizedBox(height: 16),
          ShadInputFormField(
            controller: _firstName,
            label: const Text('First Name'),
            placeholder: const Text('First Name'),
          ),
          const SizedBox(height: 12),
          ShadInputFormField(
            controller: _lastName,
            label: const Text('Last Name'),
            placeholder: const Text('Last Name'),
          ),
          const SizedBox(height: 12),
          ShadInputFormField(
            controller: _email,
            label: const Text('Email'),
            placeholder: const Text('Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          ShadInputFormField(
            controller: _currentPassword,
            label: const Text('Current Password'),
            placeholder: const Text('Current Password'),
            obscureText: true,
            trailing: const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(LucideIcons.eye),
            ),
          ),
          const SizedBox(height: 12),
          ShadInputFormField(
            controller: _newPassword,
            label: const Text('New Password'),
            placeholder: const Text('New Password'),
            obscureText: true,
            trailing: const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(LucideIcons.eye),
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: ShadButton(
              onPressed: canSave ? _save : null,
              leading: _isSaving
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApiKeysTab extends StatelessWidget {
  const _ApiKeysTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.keyRound, size: 24),
              const SizedBox(width: 10),
              Text(
                'API/CLI Keys',
                style: ShadTheme.of(context).textTheme.h3,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Generate and manage API keys to access the API/CLI',
            style: ShadTheme.of(context).textTheme.muted,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Swagger API: ',
                style: ShadTheme.of(context).textTheme.small,
              ),
              ShadButton.link(
                onPressed: () {},
                trailing: const Icon(LucideIcons.externalLink, size: 14),
                child: const Text('View'),
              ),
            ],
          ),
          const ShadSeparator.horizontal(),
          const SizedBox(height: 16),
          ShadCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TEST',
                        style: ShadTheme.of(context).textTheme.p.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(LucideIcons.clock, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Created about 1 hour ago',
                            style: ShadTheme.of(context).textTheme.muted,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ShadButton.ghost(
                  onPressed: () {},
                  child: const Icon(LucideIcons.trash),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: ShadButton(
              onPressed: () {},
              child: const Text('Generate New Key'),
            ),
          ),
        ],
      ),
    );
  }
}
