import '../models/email_item.dart';
import '../../services/auth_service.dart';

class EmailsService {
  EmailsService._();
  static final instance = EmailsService._();

  Future<List<EmailItem>> fetchAll() async {
    final records = await AuthService.instance.pb
        .collection('emails')
        .getFullList(sort: '-created');
    return records.map(EmailItem.fromRecord).toList();
  }

  Future<EmailItem> fetchOne(String id) async {
    final record = await AuthService.instance.pb
        .collection('emails')
        .getOne(id);
    return EmailItem.fromRecord(record);
  }
}
