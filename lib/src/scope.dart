import 'package:flutter/widgets.dart';

import '../reactable.dart';
import 'context.dart';

/// A condition that can be used to determine if a [Reactable] should be
/// updated.
typedef Where = bool Function();

/// Set this to true to enable debug logging for all scopes in the project.
/// Or set the [Scope.debug] property to true to enable debug logging for a
/// specific scope.
bool debugReactable = false;

/// Set this to true to throw an exception when a scope does not have a
/// [Reactable] associated with it.
bool reactableThrowOnError = true;

/// The base class for the scope that contains the main properties.
@visibleForTesting
abstract class BaseScope extends StatelessWidget {
  static final _locationRegex = RegExp(r'[a-zA-z]+.dart.{3}');

  final String name;
  final Where? where;
  final bool? debug;
  final bool? throwOnError;

  BaseScope({
    this.where,
    this.debug,
    this.throwOnError,
    Key? key,
  })  : name = getScopeName(),
        super(key: key);

  static String getScopeName({String? stackTrace}) {
    final lines = (stackTrace ?? StackTrace.current.toString()).split('\n');
    final parentLineNumber =
        lines.indexWhere((element) => element.contains('getScopeName')) + 3;
    final line = lines[parentLineNumber];
    final location = _locationRegex.firstMatch(line)?.group(0) ?? '--';
    return 'Scope in $location';
  }

  @override
  StatelessElement createElement() => _ScopeElement(this);
}

class _ScopeElement extends StatelessElement {
  _ScopeElement(BaseScope scope) : super(scope);

  BaseScope get scope => super.widget as BaseScope;

  final List<VoidCallback> disposers = <VoidCallback>[];
  bool _isDisposed = false;

  @override
  void unmount() {
    super.unmount();
    for (final disposer in disposers) {
      disposer();
    }

    disposers.clear();
    _isDisposed = true;

    try {
      (scope as ScopedValue).data.dispose();
    } catch (_) {
      // ignore
    }
  }

  void widgetUpdater() {
    final where = scope.where?.call() ?? true;
    final debug = scope.debug ?? debugReactable;
    if (_isDisposed || dirty || !where) {
      if (debug) {
        reactableContext.log(
          '${scope.name} will not be updated, condition is false',
        );
      }
      return;
    }
    if (debug) {
      reactableContext.log('${scope.name} is updating');
    }
    markNeedsBuild();
  }

  @override
  Widget build() {
    return reactableContext.watch(
      ScopeData(
        scope.name,
        widgetUpdater,
        super.build,
        disposers,
        scope.debug ?? debugReactable,
        scope.throwOnError ?? reactableThrowOnError,
      ),
    );
  }
}

/// This widget is useful when you need a temporary [Reactable] to be used
/// for updating something in the UI.
/// For example show/hide a widget.
/// ```
/// ScopedValue(
///    initData: false,
///    builder: (context, reactable<bool> reactable) => Column(
///      children: [
///        Checkbox(
///          value: reactable.value,
///          onChanged: (value) => reactable.value = value!,
///        ),
///        if (reactable.value) SomeWidget(),
///      ],
///    ),
///  )
/// ```
class ScopedValue<T> extends BaseScope {
  ScopedValue({
    required T initData,
    required this.builder,
    bool? debug,
    bool? throwOnError,
    Where? condition,
    Key? key,
  })  : data = Reactable(initData),
        super(
          where: condition,
          key: key,
          debug: debug,
          throwOnError: throwOnError,
        );

  final Widget Function(BuildContext context, Reactable<T> observable) builder;
  final Reactable<T> data;

  @override
  Widget build(BuildContext context) => builder(context, data);
}

/// A widget that watches the [Reactable] and rebuilds when the reactable
/// changes. This widget must contains at least one [Reactable] in the builder function.
/// ```
/// Scope(
///  builder: (context, Observable<int> counter) => Column(
///   children: [
///     Text('counter: $counter'),
///     TextButton(
///       child: const Text("+"),
///      onPressed: () => counter.value++,
///     ),
///   ],
/// ),
/// )
/// ```
/// You can also use [ScopedValue] to watch a temporary [Reactable]
///
/// You can also a condition to update the widget with [where] parameter.
/// That mean that the widget will only be updated when the [where] result is true.
/// if want to see more information of what is happening in the scope, you can use the [debug] parameter.
/// by default the scope will throw an error if no reactable is within it.
///  you can change this behavior with the [throwOnError] parameter.
class Scope extends BaseScope {
  Scope({
    required this.builder,
    Where? where,
    bool? debug,
    bool? throwOnError,
    Key? key,
  }) : super(
          key: key,
          where: where,
          debug: debug,
          throwOnError: throwOnError,
        );

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) => builder(context);
}
