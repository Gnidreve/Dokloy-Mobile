import 'package:pocketbase/pocketbase.dart';

class Contract {
  const Contract({
    required this.id,
    required this.keyword,
    required this.isActive,
    required this.amount,
    this.customerId,
  });

  factory Contract.fromRecord(RecordModel r) => Contract(
    id:         r.id,
    keyword:    r.getStringValue('keyword'),
    isActive:   r.data['is_active'] == true,
    amount:     (r.data['amount'] as num?)?.toDouble() ?? 0.0,
    customerId: r.getStringValue('customer').isEmpty
                  ? null
                  : r.getStringValue('customer'),
  );

  final String id;
  final String keyword;
  final bool isActive;
  final double amount;
  final String? customerId;
}
