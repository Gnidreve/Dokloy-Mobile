import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../data/models/todo_item.dart';
import '../../stores/todos_store.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: TodosStore.instance,
      builder: (context, _) {
        final store = TodosStore.instance;
        final theme = ShadTheme.of(context);

        if (store.loading) return const Center(child: CircularProgressIndicator());

        if (store.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Fehler beim Laden', style: theme.textTheme.h4),
                  const SizedBox(height: 8),
                  Text(store.error!, style: theme.textTheme.muted, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ShadButton.outline(
                    onPressed: store.reload,
                    leading: const Icon(LucideIcons.refreshCw),
                    child: const Text('Erneut versuchen'),
                  ),
                ],
              ),
            ),
          );
        }

        final items = store.items;

        return RefreshIndicator(
          onRefresh: store.reload,
          child: items.isEmpty
              ? CustomScrollView(slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.circleCheck, size: 48,
                              color: ShadTheme.of(context).colorScheme.mutedForeground),
                          const SizedBox(height: 16),
                          Text('Keine Aufgaben vorhanden',
                              style: ShadTheme.of(context).textTheme.muted),
                        ],
                      ),
                    ),
                  ),
                ])
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _TodoCard(item: items[i]),
                ),
        );
      },
    );
  }
}

class _TodoCard extends StatelessWidget {
  const _TodoCard({required this.item});

  final TodoItem item;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return ShadCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => TodosStore.instance
                .setFinished(item.id, finished: !item.isFinished),
            child: Icon(
              item.isFinished ? LucideIcons.circleCheck : LucideIcons.circle,
              size: 20,
              color: item.isFinished
                  ? const Color(0xFF16a34a)
                  : theme.colorScheme.mutedForeground,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              item.keyword,
              style: theme.textTheme.p.copyWith(
                fontWeight: FontWeight.w500,
                decoration: item.isFinished
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: item.isFinished
                    ? theme.colorScheme.mutedForeground
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
