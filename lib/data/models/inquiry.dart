import 'package:pocketbase/pocketbase.dart';

class Inquiry {
  const Inquiry({
    required this.id,
    required this.name,
    required this.subject,
    required this.email,
    required this.message,
    required this.createdAt,
    this.customerId,
  });

  factory Inquiry.fromRecord(RecordModel r) => Inquiry(
    id:         r.id,
    name:       r.getStringValue('name'),
    subject:    r.getStringValue('subject'),
    email:      r.getStringValue('email'),
    message:    r.getStringValue('message'),
    createdAt:  DateTime.tryParse(r.getStringValue('created')) ?? DateTime.now(),
    customerId: r.getStringValue('customer').isEmpty ? null : r.getStringValue('customer'),
  );

  final String id;
  final String name;
  final String subject;
  final String email;
  final String message;
  final DateTime createdAt;
  final String? customerId;
}
