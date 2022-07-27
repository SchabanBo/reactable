import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactable/reactable.dart';

void main() {
  testWidgets(
      "ensure that the right scope will be update when scopes are nested",
      (tester) async {
    final counter0 = 0.asReactable;
    final counter1 = 0.asReactable;
    final counter2 = 0.asReactable;
    final counter3 = 0.asReactable;
    final counter4 = 0.asReactable;
    final list = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _NestedCounter(
            counter: counter0,
            onBuild: () => list.add(0),
            child: _NestedCounter(
              counter: counter1,
              onBuild: () => list.add(1),
              child: _NestedCounter(
                counter: counter2,
                onBuild: () => list.add(2),
                child: _NestedCounter(
                  counter: counter3,
                  onBuild: () => list.add(3),
                  child: _NestedCounter(
                    counter: counter4,
                    onBuild: () => list.add(4),
                    child: const Text('Hi'),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // all counters are built once.
    expect(true, list.contains(0));
    expect(true, list.contains(1));
    expect(true, list.contains(2));
    expect(true, list.contains(3));
    expect(true, list.contains(4));
    list.clear();

    Future ensureIndex(int index) async {
      await tester.pumpAndSettle();
      expect(1, list.length);
      expect(true, list.contains(index));
      list.clear();
    }

    // change counter0, ensure just counter0 is rebuilt.
    counter0(1);
    await ensureIndex(0);

    counter1(1);
    await ensureIndex(1);

    counter2(1);
    await ensureIndex(2);

    counter3(1);
    await ensureIndex(3);

    counter4(1);
    await ensureIndex(4);
  });

  testWidgets(
      "ensure that the right scope will be update when scopes are nested 1",
      (tester) async {
    final counters = List.generate(20, (index) => 0.asReactable);
    final reactions = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _NestedCounter1(
            counters: counters,
            reactions: reactions,
          ),
        ),
      ),
    );
    // first build all counters should be builded
    expect(reactions.length, 20);
    reactions.clear();

    // then update the counters one by one, and ensure the right counter is rebuilt.
    // as we go deeper in the list
    for (int i = 0; i < counters.length; i++) {
      counters[i].update((val) => val! + 1);
      await tester.pump();
      expect(counters.length - i, reactions.length);
      reactions.clear();
    }
  });
}

class _NestedCounter extends StatelessWidget {
  final VoidCallback onBuild;
  final Widget child;
  final Reactable<int> counter;
  const _NestedCounter({
    required this.child,
    required this.onBuild,
    required this.counter,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scope(
      builder: (_) {
        onBuild();
        return Column(
          children: [
            Text('counter:${counter.value}'),
            child,
          ],
        );
      },
    );
  }
}

class _NestedCounter1 extends StatelessWidget {
  final List<Reactable<int>> counters;
  final List<int> reactions;
  const _NestedCounter1({
    required this.counters,
    required this.reactions,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scope(
      builder: (_) {
        reactions.add(0);
        return Column(
          children: [
            Text('counter:${counters[0].value}'),
            if (counters.length > 1)
              _NestedCounter1(
                counters: counters.sublist(1),
                reactions: reactions,
              ),
          ],
        );
      },
    );
  }
}
