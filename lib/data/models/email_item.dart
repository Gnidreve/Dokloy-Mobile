import 'package:pocketbase/pocketbase.dart';

class EmailItem {
  const EmailItem({
    required this.id,
    required this.subject,
    required this.from,
    required this.to,
    required this.body,
    required this.createdAt,
    this.customerId,
  });

  factory EmailItem.fromRecord(RecordModel r) => EmailItem(
    id: r.id,
    subject: r.getStringValue('subject'),
    from: r.getStringValue('from'),
    to: r.getStringValue('to'),
    body: r.getStringValue('body'),
    createdAt: DateTime.tryParse(r.getStringValue('created')) ?? DateTime.now(),
    customerId: r.getStringValue('customer').isEmpty
        ? null
        : r.getStringValue('customer'),
  );

  final String id;
  final String subject;
  final String from;
  final String to;
  final String body;
  final DateTime createdAt;
  final String? customerId;
}
