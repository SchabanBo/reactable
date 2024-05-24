import 'package:flutter/material.dart';
import 'package:reactable/reactable.dart';

import 'controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      title: 'Reactable',
      home: const MyHomePage(),
    );
  }
}

/// save the instance of the controller anywhere in the app
/// or user a DI container to get it. Like: [GetIt] package
final controller = TodoController();

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 50, bottom: 20),
              child: Text(
                'Reactable Todo',
                style: Theme.of(context)
                    .textTheme
                    .displaySmall!
                    .copyWith(fontFamily: 'consolas'),
              ),
            ),
            const AddTodo(),
            const SizedBox(height: 20),
            Scope(
              builder: (_) => Text(
                '${controller.todoList.where((p0) => !p0.completed).length} items to do',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 20),
            Scope(
              builder: (_) => ToggleButtons(
                isSelected: controller.selected,
                onPressed: controller.updateFilter,
                children: TodoFilter.values.map(filterButton).toList(),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color.fromARGB(255, 32, 32, 34),
              ),
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 250),
                // put the list in an scope to update the widget when the list changes
                child: Scope(
                  builder: (_) => ListView(
                    shrinkWrap: true,
                    children: controller.todoList
                        .where(controller.listFilter)
                        .map((t) => TodoWidget(todo: t))
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget filterButton(TodoFilter filter) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(filter.name.toUpperCase()),
    );
  }
}

class AddTodo extends StatefulWidget {
  const AddTodo({Key? key}) : super(key: key);

  @override
  State<AddTodo> createState() => _AddTodoState();
}

class _AddTodoState extends State<AddTodo> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color.fromARGB(255, 32, 32, 34),
      ),
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: const InputDecoration(
          labelText: 'Add a new todo',
        ),
        onSubmitted: (String value) {
          // return value to parent
          controller.addTodo(value);

          // clear the text field
          _controller.clear();
          setState(() {});
          _focusNode.requestFocus();
        },
      ),
    );
  }
}

class TodoWidget extends StatelessWidget {
  final Todo todo;
  const TodoWidget({required this.todo, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Row(
        children: [
          IconButton(
            onPressed: () => controller.removeTodo(todo),
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
          Text(todo.title),
        ],
      ),
      value: todo.completed,
      onChanged: (value) {
        controller.toggleTodo(todo);
      },
    );
  }
}
