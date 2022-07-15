import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'reactable/core.dart';

/// The context of the scopes.
final reactableContext = _ScopeContextImpl._();

class _ScopeContextImpl {
  final List<ScopeData> _dataList = [];

  _ScopeContextImpl._();

  void reading(ReactableNotifier reactable) {
    if (_dataList.isEmpty) return;

    final updater = _dataList.last.updater;
    if (!reactable.containsListener(updater)) {
      reactable.addListener(updater);
      _dataList.last.disposers.add(() {
        reactable.removeListener(updater);
      });
      if (_dataList.last.debug) {
        reactableContext.log(
            '${_dataList.last.name} is listening to ${reactable.runtimeType}');
      }
    }
  }

  Widget watch(ScopeData data) {
    _dataList.add(data);
    final result = data.builder();
    _dataList.removeLast();

    if (data.disposers.isEmpty && data.throwOnError) {
      throw ScopeError(data.name);
    }
    return result;
  }

  void log(String message) {
    if (kDebugMode) {
      print('[Reactable] $message');
    }
  }
}

class ScopeData {
  final Widget Function() builder;
  final String name;
  final VoidCallback updater;
  final List<VoidCallback> disposers;
  final bool debug;
  final bool throwOnError;

  const ScopeData(
    this.name,
    this.updater,
    this.builder,
    this.disposers,
    this.debug,
    this.throwOnError,
  );
}

class ScopeError {
  const ScopeError(this.name);

  final String name;

  @override
  String toString() {
    var message = '''
      No Reactable was found in the builder method of a scope.
      Make sure you are using any reactables in the builder method.
      $name
      ''';

    return message;
  }
}
