import '../models/invoice.dart';
import '../../services/auth_service.dart';

class InvoicesService {
  InvoicesService._();
  static final instance = InvoicesService._();

  Future<List<Invoice>> fetchAll() async {
    final records = await AuthService.instance.pb
        .collection('invoices')
        .getFullList(sort: '-created');
    return records.map(Invoice.fromRecord).toList();
  }

  Future<Invoice> fetchOne(String id) async {
    final record = await AuthService.instance.pb
        .collection('invoices')
        .getOne(id);
    return Invoice.fromRecord(record);
  }

  Future<List<Invoice>> fetchByCustomer(String customerId) async {
    final records = await AuthService.instance.pb
        .collection('invoices')
        .getFullList(
          sort: '-created',
          filter: 'customer = "$customerId"',
        );
    return records.map(Invoice.fromRecord).toList();
  }

  Future<List<Invoice>> fetchByDirection(InvoiceDirection direction) async {
    final filter = direction == InvoiceDirection.incoming
        ? 'direction = "incoming"'
        : 'direction = "outbounding"';
    final records = await AuthService.instance.pb
        .collection('invoices')
        .getFullList(sort: '-created', filter: filter);
    return records.map(Invoice.fromRecord).toList();
  }
}
