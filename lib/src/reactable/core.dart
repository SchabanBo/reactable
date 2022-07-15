import 'package:flutter/foundation.dart';

import '../context.dart';

class ReactableNotifier extends Listenable {
  bool _isDisposed = false;
  final _listeners = <VoidCallback>[];

  @override
  void addListener(VoidCallback listener) {
    assert(_debugAssertNotDisposed());
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    assert(_debugAssertNotDisposed());
    _listeners.remove(listener);
  }

  bool containsListener(VoidCallback listener) => _listeners.contains(listener);

  void refresh() {
    notifyListeners();
  }

  @protected
  void notifyListeners() {
    assert(_debugAssertNotDisposed());
    for (var listener in _listeners) {
      listener();
    }
  }

  @mustCallSuper
  void dispose() {
    assert(_debugAssertNotDisposed());
    _listeners.clear();
    _isDisposed = true;
  }

  bool _debugAssertNotDisposed() {
    assert(() {
      if (_isDisposed) {
        throw FlutterError('''A $runtimeType was used after being disposed.\n
        'Once you have called dispose() on a $runtimeType, it can no longer be used.''');
      }
      return true;
    }());
    return true;
  }
}

class ReactableValueNotifier<T> extends ReactableNotifier
    implements ValueListenable<T> {
  ReactableValueNotifier(T val) : _value = val;

  T _value;

  /// Silently read the value of this reactable
  /// without registering a listener.
  T get read => _value;

  @override
  String toString() {
    reactableContext.reading(this);
    return value.toString();
  }

  @override
  T get value {
    reactableContext.reading(this);
    return _value;
  }

  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    refresh();
  }

  T? call([T? v]) {
    if (v != null) {
      value = v;
    }
    return value;
  }
}

mixin ReactableBase<T> on ReactableValueNotifier<T> {
  @override
  bool operator ==(Object o) {
    if (o is T) return value == o;
    if (o is ReactableBase<T>) return value == o.value;
    return false;
  }

  @override
  int get hashCode => value.hashCode;
}

class Reactable<T> extends ReactableValueNotifier<T> with ReactableBase<T> {
  Reactable(T initial) : super(initial);

  void update(T Function(T? val) fn) {
    value = fn(value);
  }
}

extension ObjectExtension<T> on T {
  /// Convert this object to an observable.
  Reactable<T> get asReactable => Reactable<T>(this);
}
