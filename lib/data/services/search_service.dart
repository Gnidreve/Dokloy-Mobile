import '../../services/auth_service.dart';
import '../models/search_result.dart';

class SearchService {
  SearchService._();
  static final instance = SearchService._();

  Future<List<SearchResult>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    final escaped = _escapeFilterValue(trimmed);

    final results = await Future.wait([
      AuthService.instance.pb
          .collection('customers')
          .getList(
            page: 1,
            perPage: 10,
            filter:
                'name ~ "$escaped" || email ~ "$escaped" || '
                'telefon ~ "$escaped" || street ~ "$escaped" || '
                'town ~ "$escaped"',
            sort: 'name',
          ),
      AuthService.instance.pb
          .collection('inquiries')
          .getList(
            page: 1,
            perPage: 10,
            filter: 'name ~ "$escaped" || email ~ "$escaped"',
            sort: '-created',
          ),
      AuthService.instance.pb
          .collection('contracts')
          .getList(
            page: 1,
            perPage: 10,
            filter: 'keyword ~ "$escaped"',
            sort: '-created',
          ),
      AuthService.instance.pb
          .collection('emails')
          .getList(
            page: 1,
            perPage: 10,
            filter: 'subject ~ "$escaped" || to ~ "$escaped"',
            sort: '-created',
          ),
    ]);

    final items = <SearchResult>[
      ...results[0].items.map(
        (r) => SearchResult(
          type: 'Kontakt',
          title: r.getStringValue('name'),
          subtitle: _customerSubtitle(
            email: r.getStringValue('email'),
            town: r.getStringValue('town'),
          ),
          route: '/customers/${r.id}',
          sortDate: _readDate(r.getStringValue('updated')),
        ),
      ),
      ...results[1].items.map(
        (r) => SearchResult(
          type: 'Anfrage',
          title: r.getStringValue('name').trim().isEmpty
              ? r.getStringValue('email')
              : r.getStringValue('name'),
          subtitle: r.getStringValue('email'),
          route: '/inquiries/${r.id}',
          sortDate: _readDate(r.getStringValue('created')),
        ),
      ),
      ...results[2].items.map(
        (r) => SearchResult(
          type: 'Vertrag',
          title: r.getStringValue('keyword'),
          subtitle: r.data['is_active'] == true ? 'Aktiv' : 'Inaktiv',
          route: '/contracts/${r.id}',
          sortDate: _readDate(r.getStringValue('created')),
        ),
      ),
      ...results[3].items.map(
        (r) => SearchResult(
          type: 'E-Mail',
          title: r.getStringValue('subject').trim().isEmpty
              ? '(Ohne Betreff)'
              : r.getStringValue('subject'),
          subtitle: r.getStringValue('to'),
          route: '/emails/${r.id}',
          sortDate: _readDate(r.getStringValue('created')),
        ),
      ),
    ];

    items.sort((a, b) => b.sortDate.compareTo(a.sortDate));
    return items;
  }

  static String _escapeFilterValue(String value) {
    return value.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
  }

  static DateTime _readDate(String raw) =>
      DateTime.tryParse(raw) ?? DateTime(0);

  static String _customerSubtitle({
    required String email,
    required String town,
  }) {
    final joined = _joinParts([email, town]);
    return joined.isEmpty ? 'Kontakt' : joined;
  }

  static String _joinParts(List<String> values, {String separator = ' · '}) {
    final parts = values.where((value) => value.trim().isNotEmpty).toList();
    return parts.join(separator);
  }
}
