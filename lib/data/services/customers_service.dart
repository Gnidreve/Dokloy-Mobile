import '../models/customer.dart';
import '../../services/auth_service.dart';

class CustomersService {
  CustomersService._();
  static final instance = CustomersService._();

  Future<List<Customer>> fetchAll() async {
    final records = await AuthService.instance.pb
        .collection('customers')
        .getFullList(sort: 'name');
    return records.map(Customer.fromRecord).toList();
  }

  Future<Customer> fetchOne(String id) async {
    final record = await AuthService.instance.pb
        .collection('customers')
        .getOne(id);
    return Customer.fromRecord(record);
  }

  Future<void> update(
    String id, {
    required String name,
    required String email,
    required String phone,
    required String street,
    required int zip,
    required String town,
  }) async {
    await AuthService.instance.pb
        .collection('customers')
        .update(
          id,
          body: {
            'name': name,
            'email': email,
            'phone': phone,
            'street': street,
            'zip': zip,
            'town': town,
          },
        );
  }
}
