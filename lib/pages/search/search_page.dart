import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../data/models/search_result.dart';
import '../../data/services/search_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<SearchResult> _results = const [];
  String _query = '';
  String? _error;
  bool _loading = false;
  int _searchRequestId = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _controller.text;
    _debounce?.cancel();
    setState(() {
      _query = query;
      _error = null;
    });

    if (query.trim().isEmpty) {
      setState(() {
        _results = const [];
        _loading = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    final requestId = ++_searchRequestId;
    setState(() => _loading = true);
    try {
      final results = await SearchService.instance.search(query);
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _error = e.toString();
        _results = const [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final hasQuery = _query.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: ShadInput(
            controller: _controller,
            placeholder: const Text('Alle Daten durchsuchen…'),
            leading: const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(LucideIcons.search, size: 16),
            ),
          ),
        ),
        Expanded(
          child: !hasQuery
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.search, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Gib einen Suchbegriff ein',
                        style: theme.textTheme.muted,
                      ),
                    ],
                  ),
                )
              : _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Fehler beim Laden', style: theme.textTheme.h4),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: theme.textTheme.muted,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : _results.isEmpty
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
                  itemCount: _results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final item = _results[i];
                    return ShadCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Material(
                        type: MaterialType.transparency,
                        clipBehavior: Clip.antiAlias,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => context.go(item.route),
                          child: Row(
                            children: [
                              Icon(
                                _iconForType(item.type),
                                size: 20,
                                color: theme.colorScheme.mutedForeground,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: theme.textTheme.p.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (item.subtitle.trim().isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        item.subtitle,
                                        style: theme.textTheme.muted,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    item.type,
                                    style: theme.textTheme.muted.copyWith(
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Icon(
                                    LucideIcons.chevronRight,
                                    size: 16,
                                    color: theme.colorScheme.mutedForeground,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  IconData _iconForType(String type) => switch (type) {
    'Kontakt' => LucideIcons.users,
    'Anfrage' => LucideIcons.mail,
    'Vertrag' => LucideIcons.fileText,
    'E-Mail' => LucideIcons.mail,
    _ => LucideIcons.fileText,
  };
}
