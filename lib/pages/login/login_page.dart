import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../components/app_toast/app_toast.dart';
import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.initialError});

  final String? initialError;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialError != null) {
      // Nach dem ersten Frame anzeigen, damit der Overlay-Context bereit ist
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          AppToast.showError(
            context,
            title: 'Automatischer Login fehlgeschlagen',
            subtitle: widget.initialError,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _extractError(Object e) {
    if (e is ClientException) {
      final msg = e.response['message'];
      if (msg is String && msg.isNotEmpty) return msg;
      if (e.statusCode == 400) return 'Falsche E-Mail oder falsches Passwort.';
      if (e.statusCode == 0)
        return 'Server nicht erreichbar. Bitte Verbindung prüfen.';
      return 'Fehler ${e.statusCode}: ${e.response}';
    }
    return e.toString();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      AppToast.showError(
        context,
        title: 'Fehlende Eingabe',
        subtitle: 'Bitte E-Mail und Passwort eingeben.',
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await AuthService.instance.login(email, password);
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        AppToast.showError(
          context,
          title: 'Login fehlgeschlagen',
          subtitle: _extractError(e),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: SizedBox(width: 56, height: 56)),
                  const SizedBox(height: 24),
                  Text(
                    'Customer  Relationsships',
                    style: theme.textTheme.h2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Melde dich mit deinem Account an.',
                    style: theme.textTheme.muted,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ShadInputFormField(
                    controller: _emailController,
                    label: const Text('E-Mail'),
                    placeholder: const Text('deine@email.de'),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    enabled: !_loading,
                  ),
                  const SizedBox(height: 16),
                  ShadInputFormField(
                    controller: _passwordController,
                    label: const Text('Passwort'),
                    placeholder: const Text('••••••••'),
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _login(),
                    enabled: !_loading,
                  ),
                  const SizedBox(height: 24),
                  ShadButton(
                    onPressed: _loading ? null : _login,
                    width: double.infinity,
                    child: _loading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Anmelden'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
