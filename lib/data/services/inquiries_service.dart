import '../models/inquiry.dart';
import '../../services/auth_service.dart';

class InquiriesService {
  InquiriesService._();
  static final instance = InquiriesService._();

  Future<List<Inquiry>> fetchAll() async {
    final records = await AuthService.instance.pb
        .collection('inquiries')
        .getFullList(sort: '-created');
    return records.map(Inquiry.fromRecord).toList();
  }

  Future<List<Inquiry>> fetchByCustomer(String customerId) async {
    final records = await AuthService.instance.pb
        .collection('inquiries')
        .getFullList(
          sort: '-created',
          filter: 'customer = "$customerId"',
        );
    return records.map(Inquiry.fromRecord).toList();
  }

  Future<Inquiry> fetchOne(String id) async {
    final record = await AuthService.instance.pb
        .collection('inquiries')
        .getOne(id);
    return Inquiry.fromRecord(record);
  }
}
