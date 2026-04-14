import '../models/todo_item.dart';
import '../../services/auth_service.dart';

class TodosService {
  TodosService._();
  static final instance = TodosService._();

  Future<List<TodoItem>> fetchAll() async {
    final records = await AuthService.instance.pb
        .collection('todo')
        .getFullList(sort: 'is_finished,created');
    return records.map(TodoItem.fromRecord).toList();
  }

  Future<void> setFinished(String id, {required bool finished}) async {
    await AuthService.instance.pb
        .collection('todo')
        .update(id, body: {'is_finished': finished});
  }
}
