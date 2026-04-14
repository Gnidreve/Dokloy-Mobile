import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final today = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: ShadSelect<String>(
            placeholder: const Text('Alle Termine'),
            selectedOptionBuilder: (_, v) => Text(v),
            onChanged: (_) {},
            options: const [
              ShadOption(value: 'alle', child: Text('Alle Termine')),
              ShadOption(value: 'meine', child: Text('Meine Termine')),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ShadCalendar(
              selected: today,
              fromMonth: DateTime(today.year - 1),
              toMonth: DateTime(today.year, 12),
            ),
          ),
        ),
      ],
    );
  }
}
