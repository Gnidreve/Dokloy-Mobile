import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const DokployApp());
}

class DokployApp extends StatefulWidget {
  const DokployApp({super.key});

  @override
  State<DokployApp> createState() => _DokployAppState();
}

class _DokployAppState extends State<DokployApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  late final _router = createRouter(onToggleTheme: _toggleTheme);

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ShadApp.router(
      title: 'Dokploy',
      themeMode: _themeMode,
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadSlateColorScheme.light(),
      ),
      darkTheme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadSlateColorScheme.dark(),
      ),
      routerConfig: _router,
    );
  }
}
