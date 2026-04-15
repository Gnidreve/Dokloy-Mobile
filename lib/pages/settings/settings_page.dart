import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../components/app_toast/app_toast.dart';
import '../../services/notifications_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    NotificationsService.instance.refreshStatus();
  }

  Future<void> _onNotificationsChanged(bool value) async {
    final service = NotificationsService.instance;
    await service.setEnabled(value);
    if (!mounted || service.lastError == null) return;

    AppToast.showError(
      context,
      title: 'Benachrichtigungen konnten nicht aktualisiert werden',
      subtitle: service.lastError,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: NotificationsService.instance,
      builder: (context, _) {
        final theme = ShadTheme.of(context);
        final notifications = NotificationsService.instance;

        return RefreshIndicator(
          onRefresh: notifications.refreshStatus,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ShadCard(
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
                              Text(
                                'Notification Enabled',
                                style: theme.textTheme.p.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Fordert die Android-Berechtigung an und speichert den aktuellen Device-Token beim eingeloggten Superuser.',
                                style: theme.textTheme.muted,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (notifications.loading)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          ShadSwitch(
                            value: notifications.enabled,
                            enabled: notifications.isSupported,
                            onChanged: _onNotificationsChanged,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      notifications.statusText,
                      style: theme.textTheme.muted,
                    ),
                    if ((notifications.serverToken ?? '').isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Server-Token: ${notifications.serverToken}',
                        style: theme.textTheme.small.copyWith(
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ),
                    ],
                    if ((notifications.deviceToken ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Geräte-Token: ${notifications.deviceToken}',
                        style: theme.textTheme.small.copyWith(
                          color: theme.colorScheme.mutedForeground,
                        ),
                      ),
                    ],
                    if (notifications.lastError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        notifications.lastError!,
                        style: theme.textTheme.small.copyWith(
                          color: theme.colorScheme.destructive,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
