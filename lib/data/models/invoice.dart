import 'package:pocketbase/pocketbase.dart';

enum InvoiceDirection { incoming, outbounding }

class Invoice {
  const Invoice({
    required this.id,
    required this.title,
    required this.amount,
    required this.direction,
    required this.createdAt,
    this.customerId,
  });

  factory Invoice.fromRecord(RecordModel r) {
    final dir = r.getStringValue('direction');
    return Invoice(
      id:         r.id,
      title:      r.getStringValue('title'),
      amount:     (r.data['total'] as num?)?.toDouble() ?? 0.0,
      direction:  dir == 'incoming'
                    ? InvoiceDirection.incoming
                    : InvoiceDirection.outbounding,
      createdAt:  DateTime.tryParse(r.getStringValue('created')) ?? DateTime.now(),
      customerId: r.getStringValue('customer').isEmpty
                    ? null
                    : r.getStringValue('customer'),
    );
  }

  final String id;
  final String title;
  final double amount;
  final InvoiceDirection direction;
  final DateTime createdAt;
  final String? customerId;
}
