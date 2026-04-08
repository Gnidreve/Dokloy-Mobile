import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../api/models.dart';

class SchedulesPage extends StatelessWidget {
  const SchedulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    const schedules = <Schedule>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: schedules.isEmpty
          ? Center(
              child: ShadCard(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Scheduled Tasks', style: ShadTheme.of(context).textTheme.h3),
                    const SizedBox(height: 8),
                    Text(
                      'Schedule tasks to run automatically at specified intervals.',
                      style: ShadTheme.of(context).textTheme.muted,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    const Icon(LucideIcons.clock, size: 48),
                    const SizedBox(height: 24),
                    Text('No scheduled tasks', style: ShadTheme.of(context).textTheme.h4),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first scheduled task to automate your workflows',
                      style: ShadTheme.of(context).textTheme.muted,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ShadButton(
                      onPressed: () {},
                      leading: const Icon(LucideIcons.plus),
                      child: const Text('Add Schedule'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: schedules
                  .map((s) => ShadCard(
                        child: Row(
                          children: [
                            Expanded(child: Text(s.name)),
                            Text(s.cron, style: ShadTheme.of(context).textTheme.muted),
                          ],
                        ),
                      ))
                  .toList(),
            ),
    );
  }
}
