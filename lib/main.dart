import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'router.dart';
import 'services/auth_service.dart';
import 'services/notifications_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  // Auth-Init und Firebase-Bootstrap parallel starten; SharedPreferences
  // gleichzeitig laden, damit kein Theme-Flash entsteht.
  final prefsFuture = SharedPreferences.getInstance();

  await Future.wait([
    AuthService.instance.init().catchError((_) async {
      await AuthService.instance.initFallback();
    }),
    NotificationsService.instance.bootstrap(),
    prefsFuture,
  ]);

  final prefs = await prefsFuture;
  runApp(MyCrmApp(initialThemePreference: prefs.getString('theme_mode')));
}

class MyCrmApp extends StatefulWidget {
  const MyCrmApp({super.key, this.initialThemePreference});

  final String? initialThemePreference;

  @override
  State<MyCrmApp> createState() => _MyCrmAppState();
}

class _MyCrmAppState extends State<MyCrmApp> {
  static const _themeModePreferenceKey = 'theme_mode';

  late ThemeMode _themeMode;
  late final _router = createRouter(onToggleTheme: _toggleTheme);

  @override
  void initState() {
    super.initState();
    // Präferenz wurde bereits in main() geladen — kein async-Flash mehr.
    _themeMode =
        _themeModeFromPreference(widget.initialThemePreference) ??
        _systemThemeMode();
  }

  void _toggleTheme() {
    final nextThemeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setState(() => _themeMode = nextThemeMode);
    _persistThemeMode(nextThemeMode);
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
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => null,
    };
  }

  String _themeModePreferenceValue(ThemeMode themeMode) {
    return switch (themeMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }

  @override
  Widget build(BuildContext context) {
    return ShadApp.router(
      title: 'MyCRM',
      themeMode: _themeMode,
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadNeutralColorScheme.light(),
        textTheme: ShadTextTheme(family: 'CSRegular'),
      ),
      darkTheme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadNeutralColorScheme.dark(),
        textTheme: ShadTextTheme(family: 'CSRegular'),
      ),
      routerConfig: _router,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bg = ShadTheme.of(context).colorScheme.background;
        return MediaQuery(
          // Temporary Changed: Schriftgröße auf 150% erhöht
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.11)),
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              systemNavigationBarColor: bg,
              systemNavigationBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
              systemNavigationBarContrastEnforced: false,
              systemNavigationBarDividerColor: Colors.transparent,
            ),
            child: child!,
          ),
        );
      },
    );
  }
}
