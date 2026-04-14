import 'package:pocketbase/pocketbase.dart';

class TodoItem {
  const TodoItem({
    required this.id,
    required this.keyword,
    required this.isFinished,
  });

  factory TodoItem.fromRecord(RecordModel r) => TodoItem(
    id:         r.id,
    keyword:    r.getStringValue('keyword'),
    isFinished: r.data['is_finished'] == true,
  );

  final String id;
  final String keyword;
  final bool isFinished;
}
