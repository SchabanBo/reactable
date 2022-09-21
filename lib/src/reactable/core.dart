import 'package:flutter/foundation.dart';

import '../context.dart';

class ReactableNotifier extends Listenable {
  bool _isDisposed = false;
  final _listeners = <VoidCallback>[];
  final _disposers = <VoidCallback>[];

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

  void addDisposer(VoidCallback listener) {
    assert(_debugAssertNotDisposed());
    _disposers.add(listener);
  }

  void removeDisposer(VoidCallback listener) {
    assert(_debugAssertNotDisposed());
    _disposers.remove(listener);
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
    for (var disposer in _disposers) {
      disposer();
    }
    _disposers.clear();
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

  void detach(ScopeData data) {
    assert(_debugAssertNotDisposed());
    removeListener(data.updater);
    if (_listeners.isNotEmpty) return;
    if (data.autoDispose) dispose();
  }
}

class ReactableValueNotifier<T> extends ReactableNotifier
    implements ValueListenable<T> {
  ReactableValueNotifier(T val) : _value = val;

  T _value;

  /// Silently read the value of this reactable
  /// without registering a listener.
  T get read => _value;

  /// Silently write the value of this reactable
  /// without triggering any listener.
  T write(T val) {
    _value = val;
    return _value;
  }

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

/// The main implementation of the reactable object.
class Reactable<T> extends ReactableValueNotifier<T> with ReactableBase<T> {
  Reactable(T initial) : super(initial);

  void update(T Function(T? val) fn) {
    value = fn(value);
  }
}

/// An extension to convert an object to a reactable.
extension ObjectExtension<T> on T {
  /// Convert this object to an reactable.
  Reactable<T> get asReactable => Reactable<T>(this);
}
