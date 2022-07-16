import 'package:reactable/reactable.dart';

class TodoController {
  final todoList = <Todo>[].asReactable;
  final filter = TodoFilter.all.asReactable;

  List<bool> get selected =>
      TodoFilter.values.map((e) => e == filter.value).toList();

  void addTodo(String name) {
    if (name.isEmpty) {
      return;
    }
    todoList.add(Todo(title: name, completed: false));
  }

  void toggleTodo(Todo todo) {
    todo.completed = !todo.completed;

    // Here we should call update because we are update an item
    // in the list we are not updating the list itself
    todoList.refresh();
  }

  void removeTodo(Todo todo) {
    todoList.remove(todo);
  }

  void updateFilter(int index) {
    filter.value = TodoFilter.values[index];
  }

  bool listFilter(Todo todo) {
    switch (filter.value) {
      case TodoFilter.all:
        return true;
      case TodoFilter.active:
        return !todo.completed;
      case TodoFilter.completed:
        return todo.completed;
    }
  }
}

class Todo {
  final String title;
  bool completed;

  Todo({
    required this.title,
    required this.completed,
  });
}

enum TodoFilter { all, active, completed }
