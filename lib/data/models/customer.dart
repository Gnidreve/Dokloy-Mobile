import 'package:pocketbase/pocketbase.dart';

class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.street,
    required this.zip,
    required this.town,
  });

  factory Customer.fromRecord(RecordModel r) => Customer(
    id: r.id,
    name: r.getStringValue('name'),
    email: r.getStringValue('email'),
    phone: r.getStringValue('telefon'),
    street: r.getStringValue('street'),
    zip: (r.data['zip'] as num?)?.toInt() ?? 0,
    town: r.getStringValue('town'),
  );

  final String id;
  final String name;
  final String email;
  final String phone;
  final String street;
  final int zip;
  final String town;
}
