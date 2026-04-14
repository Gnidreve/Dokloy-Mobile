import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  String _query = '';

  static const _placeholderItems = <_SearchItem>[
    _SearchItem(type: 'Kontakt',  title: 'Max Mustermann',     subtitle: 'Musterstraße 1, 12345 Berlin'),
    _SearchItem(type: 'Kontakt',  title: 'Erika Musterfrau',   subtitle: 'Hauptstraße 5, 80331 München'),
    _SearchItem(type: 'Kontakt',  title: 'Hans Beispiel GmbH', subtitle: 'Industrieweg 12, 20095 Hamburg'),
    _SearchItem(type: 'Anfrage',  title: 'Website-Redesign',   subtitle: 'Max Mustermann · 10.03.2026'),
    _SearchItem(type: 'Anfrage',  title: 'Support-Anfrage',    subtitle: 'Erika Musterfrau · 22.03.2026'),
    _SearchItem(type: 'Rechnung', title: 'Jahresabschluss 2025', subtitle: 'Ausgang · 4.800,00 €'),
    _SearchItem(type: 'Rechnung', title: 'Beratungshonorar Q1',  subtitle: 'Ausgang · 1.200,00 €'),
    _SearchItem(type: 'Rechnung', title: 'Büromaterial',          subtitle: 'Eingang · 349,90 €'),
    _SearchItem(type: 'Vertrag',  title: 'Wartungsvertrag 2026', subtitle: 'Aktiv · 2.400,00 €'),
    _SearchItem(type: 'Vertrag',  title: 'Lizenzvertrag Software', subtitle: 'Aktiv · 960,00 €'),
    _SearchItem(type: 'Vertrag',  title: 'Mietvertrag Lager',    subtitle: 'Inaktiv · 600,00 €'),
  ];

  List<_SearchItem> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _placeholderItems;
    return _placeholderItems
        .where((i) =>
            i.title.toLowerCase().contains(q) ||
            i.subtitle.toLowerCase().contains(q) ||
            i.type.toLowerCase().contains(q))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() => _query = _controller.text));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final items = _filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: ShadInput(
            controller: _controller,
            placeholder: const Text('Suchen …'),
            leading: const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(LucideIcons.search, size: 16),
            ),
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.search, size: 48),
                      const SizedBox(height: 16),
                      Text('Keine Ergebnisse', style: theme.textTheme.muted),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return ShadCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.muted,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              _iconForType(item.type),
                              size: 16,
                              color: theme.colorScheme.mutedForeground,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: theme.textTheme.p.copyWith(
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(item.subtitle,
                                    style: theme.textTheme.muted),
                              ],
                            ),
                          ),
                          Text(
                            item.type,
                            style: theme.textTheme.muted
                                .copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  IconData _iconForType(String type) => switch (type) {
    'Kontakt'  => LucideIcons.users,
    'Anfrage'  => LucideIcons.mail,
    'Rechnung' => LucideIcons.fileText,
    _          => LucideIcons.fileText,
  };
}

class _SearchItem {
  const _SearchItem({
    required this.type,
    required this.title,
    required this.subtitle,
  });

  final String type;
  final String title;
  final String subtitle;
}
