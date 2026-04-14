import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:pocketbase/pocketbase.dart';

import '../services/auth_service.dart';

class ConnectingPage extends StatefulWidget {
  const ConnectingPage({super.key});

  @override
  State<ConnectingPage> createState() => _ConnectingPageState();
}

class _ConnectingPageState extends State<ConnectingPage> {
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final auth = AuthService.instance;

    // Bereits eingeloggt (Token aus SecureStorage noch gültig)
    if (auth.isLoggedIn) {
      if (mounted) context.go('/home');
      return;
    }

    // Dev: automatischer Login über .env
    try {
      final didLogin = await auth.tryEnvLogin();
      if (!mounted) return;
      if (didLogin) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    } catch (e) {
      if (!mounted) return;
      final msg = _extractError(e);
      context.go('/login', extra: msg);
    }
  }

  String _extractError(Object e) {
    if (e is ClientException) {
      final msg = e.response['message'];
      if (msg is String && msg.isNotEmpty) return msg;
      if (e.statusCode == 0) return 'Server nicht erreichbar (${AuthService.instance.pb.baseURL}).';
      return 'Fehler ${e.statusCode}';
    }
    return e.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.6,
          ),
          child: const ShadProgress(),
        ),
      ),
    );
  }
}
