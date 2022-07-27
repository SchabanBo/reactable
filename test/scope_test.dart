import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reactable/reactable.dart';
import 'package:reactable/src/context.dart';

void main() {
  testWidgets("scope update", (tester) async {
    final counter = 0.asReactable;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Scope(
                builder: (context) => Text('counter: $counter'),
              ),
              TextButton(
                child: const Text("+"),
                onPressed: () => counter.value++,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('counter: 0'), findsOneWidget);

    await tester.tap(find.text('+'));
    await tester.pump();
    expect(find.text('counter: 1'), findsOneWidget);

    counter.value = 2;
    await tester.pump();
    expect(find.text('counter: 2'), findsOneWidget);

    counter(3);
    await tester.pump();
    expect(find.text('counter: 3'), findsOneWidget);

    counter.update((val) => val! + 1);
    await tester.pump();
    expect(find.text('counter: 4'), findsOneWidget);

    expect(counter.value.hashCode, counter.hashCode);
    const value = 5;
    counter.value = value;
    // ignore: unrelated_type_equality_checks
    expect(counter == value, true);
    expect(counter == counter, true);
  });

  testWidgets('scope without reactable', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scope(
        builder: (_) => const Text('Hello'),
      ),
    ));

    expect(tester.takeException(), isA<ScopeError>());
  });

  testWidgets(
      'scope without reactable dose not throws error when throwError is false',
      (tester) async {
    reactableThrowOnError = false;
    await tester.pumpWidget(MaterialApp(
      home: Scope(
        builder: (_) => const Text('Hello'),
      ),
    ));

    expect(find.text('Hello'), findsOneWidget);
    reactableThrowOnError = true;
  });

  testWidgets("scope with read dose not update", (tester) async {
    final counter = 0.asReactable;
    final counter1 = 0.asReactable;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Scope(
            builder: (context) => Column(
              children: [
                Text('counter:${counter1.read}'),
                Text('counter:$counter'),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('counter:0'), findsNWidgets(2));

    counter1.value = 1;
    await tester.pump();
    expect(find.text('counter:0'), findsNWidgets(2)); // counter1 is not updated

    counter.value = 1;
    await tester.pump();
    expect(find.text('counter:1'), findsNWidgets(2)); // counter is updated
  });

  test('scope disposed throws error', () {
    expect(() {
      final counter = 0.asReactable;
      counter.dispose();
      counter.refresh();
    }, throwsA(isA<FlutterError>()));
  });

  testWidgets("scoped value", (tester) async {
    debugReactable = true;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScopedValue(
            initData: 0,
            builder: (_, Reactable<int> counter) => Column(
              children: [
                Text('counter: $counter'),
                TextButton(
                  child: const Text("+"),
                  onPressed: () => counter.value++,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('counter: 0'), findsOneWidget);

    await tester.tap(find.text('+'));
    await tester.pump();
    expect(find.text('counter: 1'), findsOneWidget);
  });

  test('scope name', () {
    expect(
      BaseScope.getScopeName(stackTrace: '''#0      Eval ()
#1      getScopeName (package:reactable/src/scope.dart:14:21)
#2      new _BaseScope (package:reactable/src/scope.dart:22:16)
#3      new Scope (package:reactable/src/scope.dart:124:8)
#4      AutoSaveSection.build (package:test/pages/settings/views/auto_save_section.dart:18:11)
#5      StatelessElement.build (package:flutter/src/widgets/framework.dart:4879:49)
#6      ComponentElement.performRebuild (package:flutter/src/widgets/framework.dart:4809:15)
#7      Element.rebuild (package:flutter/src/widgets/framework.dart:4536:5)
#8      ComponentElement._firstBuild (package:flutter/src/widgets/framework.dart:4790:5)
#9      ComponentElement.mount (package:flutter/src/widgets/framework.dart:4784:5)
#10     Element.inflateWidget (package:flutter/src/widgets/framework.dart:3819:16)
#11     MultiChildRenderObjectElement.inflateWidget (package:flutter/src/widgets/framework.dart:6352:36)
#12     MultiChildRenderObjectElement.mount (package:flutter/src/widgets/framework.dart:6364:32)
#13     Element.inflateWidget (package:flutter/src/widgets/framework.dart:3819:16)
#14     Element.updateChild (package:flutter/src/widgets/framework.dart:3553:18)
'''),
      'Scope in auto_save_section.dart:18',
    );

    expect(
      BaseScope.getScopeName(stackTrace: '''
C:/b/s/w/ir/cache/builder/src/out/host_debug/dart-sdk/lib/_internal/js_dev_runtime/patch/core_patch.dart 963:28   get current
packages/reactable/src/scope.dart 14:21                                                                   eval
packages/reactable/src/scope.dart 14:21                                                                   eval
packages/reactable/src/scope.dart 14:21                                                                   getScopeName
packages/reactable/src/scope.dart 22:16                                                                   new
packages/reactable/src/scope.dart 124:8                                                                   new
packages/test/pages/main/local_node/widget.dart 80:26                                             get header
packages/test/pages/main/local_node/widget.dart 55:59                                             <fn>
packages/reactable/src/scope.dart 129:48                                                                  build
packages/flutter/src/widgets/framework.dart 4879:22                                                               build
packages/reactable/src/context.dart 30:24                                                                    observe
'''),
      'Scope in widget.dart 80',
    );
  });
}
