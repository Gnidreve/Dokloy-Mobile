import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  static const _themeModePreferenceKey = 'theme_mode';

  late ThemeMode _themeMode;
  late final _router = createRouter(onToggleTheme: _toggleTheme);

  @override
  void initState() {
    super.initState();
    _themeMode = _systemThemeMode();
    _loadThemeModePreference();
  }

  void _toggleTheme() {
    final nextThemeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;

    setState(() {
      _themeMode = nextThemeMode;
    });
    _persistThemeMode(nextThemeMode);
  }

  Future<void> _loadThemeModePreference() async {
    final preferences = await SharedPreferences.getInstance();
    final storedThemeMode = preferences.getString(_themeModePreferenceKey);
    final themeMode = _themeModeFromPreference(storedThemeMode);
    if (themeMode == null || !mounted) {
      return;
    }

    setState(() {
      _themeMode = themeMode;
    });
  }

  Future<void> _persistThemeMode(ThemeMode themeMode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _themeModePreferenceKey,
      _themeModePreferenceValue(themeMode),
    );
  }

  ThemeMode _systemThemeMode() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
  }

  ThemeMode? _themeModeFromPreference(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return null;
    }
  }

  String _themeModePreferenceValue(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
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
