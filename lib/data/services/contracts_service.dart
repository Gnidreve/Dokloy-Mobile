import '../models/contract.dart';
import '../../services/auth_service.dart';

class ContractsService {
  ContractsService._();
  static final instance = ContractsService._();

  Future<List<Contract>> fetchAll() async {
    final records = await AuthService.instance.pb
        .collection('contracts')
        .getFullList(sort: '-created');
    return records.map(Contract.fromRecord).toList();
  }

  Future<Contract> fetchOne(String id) async {
    final record = await AuthService.instance.pb
        .collection('contracts')
        .getOne(id);
    return Contract.fromRecord(record);
  }

  Future<List<Contract>> fetchByCustomer(String customerId) async {
    final records = await AuthService.instance.pb
        .collection('contracts')
        .getFullList(
          sort: '-created',
          filter: 'customer = "$customerId"',
        );
    return records.map(Contract.fromRecord).toList();
  }
}
