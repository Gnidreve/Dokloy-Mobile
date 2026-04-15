import 'package:pocketbase/pocketbase.dart';

class Invoice {
  const Invoice({
    required this.id,
    required this.title,
    required this.amount,
    required this.createdAt,
    this.customerId,
  });

  factory Invoice.fromRecord(RecordModel r) => Invoice(
    id: r.id,
    title: r.getStringValue('title'),
    amount: (r.data['total'] as num?)?.toDouble() ?? 0.0,
    createdAt: DateTime.tryParse(r.getStringValue('created')) ?? DateTime.now(),
    customerId: r.getStringValue('customer').isEmpty
        ? null
        : r.getStringValue('customer'),
  );

  final String id;
  final String title;
  final double amount;
  final DateTime createdAt;
  final String? customerId;
}
