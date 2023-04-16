import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactable/reactable.dart';

void main() {
  testWidgets("scope auto dispose", (tester) async {
    final counter = 0.asReactable;
    var isDisposed = false;
    counter.addDisposer(() {
      isDisposed = true;
    });
    counter.removeDisposer(() {});
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        home: Scaffold(
          body: Column(
            children: [
              TextButton(
                child: const Text("+"),
                onPressed: () => counter.value++,
              ),
            ],
          ),
        ),
      ),
    );

    Navigator.push(
      navigatorKey.currentContext!,
      MaterialPageRoute(
        builder: (c) => Material(
          child: Scope(
            autoDispose: true,
            builder: (_) => Text('counter: $counter'),
          ),
        ),
      ),
    );

    counter.value = 2;
    await tester.pumpAndSettle();
    expect(find.text('counter: 2'), findsOneWidget);

    Navigator.pop(navigatorKey.currentContext!);
    await tester.pumpAndSettle();
    expect(isDisposed, true);
  });

  test('Reactable.listenTo', () {
    final counter1 = Reactable(0);
    final counter2 = Reactable(0);
    final counter3 = Reactable(0);
    var indexer = 0;
    void update() {
      indexer++;
    }

    Reactable.listenTo([counter1, counter2, counter3], update);

    counter1(1);
    expect(indexer, 1);

    counter2(1);
    expect(indexer, 2);

    counter3(1);
    expect(indexer, 3);

    counter1.dispose();
    counter2.dispose();
    counter3.dispose();

    expect(counter1.containsListener(update), false);
    expect(counter2.containsListener(update), false);
    expect(counter3.containsListener(update), false);
  });
}
