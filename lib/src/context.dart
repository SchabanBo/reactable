import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'reactable/core.dart';

/// The context of the scopes.
final reactableContext = _ScopeContextImpl._();

class _ScopeContextImpl {
  /// Set this to true to enable debug logging for all scopes in the project.
  /// Or set the [Scope.debug] property to true to enable debug logging for a
  /// specific scope.
  bool debugReactable = false;

  /// Auto dispose reactable whenever there is no scope using it.
  bool autoDispose = false;

  /// Set this to true to throw an exception when a scope does not have a
  /// [Reactable] associated with it.
  bool reactableThrowOnError = true;

  final List<ScopeData> _dataList = [];

  _ScopeContextImpl._();

  void reading(ReactableNotifier reactable) {
    if (_dataList.isEmpty) return;

    final data = _dataList.last;
    if (!reactable.containsListener(data.updater)) {
      reactable.registerScope(data.updater);
      _dataList.last.disposers.add(() {
        reactable.detach(data);
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
  final bool autoDispose;

  const ScopeData(this.name, this.updater, this.builder, this.disposers,
      this.debug, this.throwOnError, this.autoDispose);
}

class ScopeError {
  const ScopeError(this.name);

  final String name;

  @override
  String toString() {
    var message = '''
      No Reactable was found in the builder method of a scope.
      Make sure you are using any reactable in the builder method.
      $name
      ''';

    return message;
  }
}
