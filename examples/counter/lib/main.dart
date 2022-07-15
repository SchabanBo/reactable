import 'package:flutter/material.dart';
import 'package:reactable/reactable.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reactable',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key? key}) : super(key: key);

  final counter = 0.asReactable;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reactable'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Counter value is:',
            ),
            Scope(
              builder: (_) => Text(
                '$counter',
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
            const Text('Update counter only when the number is even'),
            Scope(
              where: () => counter.value % 2 == 0,
              debug: true,
              builder: (_) => Text(
                '$counter',
                style: Theme.of(context).textTheme.headline4,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => counter.value++,
                    child: const Text('Increment'),
                  ),
                  TextButton(
                    onPressed: () => counter.value--,
                    child: const Text('Decrement'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
