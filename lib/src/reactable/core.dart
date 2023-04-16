import 'package:flutter/foundation.dart';

import '../context.dart';

class ReactableNotifier extends Listenable {
  ReactableNotifier(this.canBeAutoDisposed);

  final bool canBeAutoDisposed;

  final _disposers = <VoidCallback>[];
  final _listeners = <_Listeners>[];

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(_Listeners(action: listener));
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.removeWhere((l) => l.action == listener);
  }

  void registerScope(VoidCallback listener) {
    _listeners.add(_Listeners(action: listener, isFromScope: true));
  }

  void addDisposer(VoidCallback listener) {
    _disposers.add(listener);
  }

  void removeDisposer(VoidCallback listener) {
    _disposers.remove(listener);
  }

  bool containsListener(VoidCallback listener) =>
      _listeners.any((l) => l.action == listener);

  void refresh() {
    notifyListeners();
  }

  @protected
  void notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  @mustCallSuper
  void dispose() {
    _listeners.clear();
    for (var disposer in _disposers) {
      disposer();
    }
    _disposers.clear();
  }

  void detach(ScopeData data) {
    removeListener(data.updater);
    if (_listeners.any((e) => e.isFromScope)) return;
    if (data.autoDispose && canBeAutoDisposed) dispose();
  }
}

class ReactableValueNotifier<T> extends ReactableNotifier
    implements ValueListenable<T> {
  ReactableValueNotifier(T val, bool canBeAutoDisposed)
      : _value = val,
        super(canBeAutoDisposed);

  T _value;

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

  /// Silently read the value of this reactable
  /// without registering a listener.
  T get read => _value;

  /// Silently write the value of this reactable
  /// without triggering any listener.
  T write(T val) {
    _value = val;
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
  Reactable(T initial, {bool canBeAutoDisposed = true})
      : super(initial, canBeAutoDisposed);

  void update(T Function(T? val) fn) {
    value = fn(value);
  }

  /// Register this VoidCallBack for all the given reactable. and register
  /// the VoidCallBack to be removed when the reactable is no longer is used.
  static void listenTo(List<Reactable> reactables, VoidCallback callback) {
    for (var reactable in reactables) {
      reactable.addListener(callback);
      reactable.addDisposer(() {
        reactable.removeListener(callback);
      });
    }
  }
}

/// An extension to convert an object to a reactable.
extension ObjectExtension<T> on T {
  /// Convert this object to an reactable.
  Reactable<T> get asReactable => Reactable<T>(this);
}

class _Listeners {
  _Listeners({
    required this.action,
    this.isFromScope = false,
  });

  final VoidCallback action;
  final bool isFromScope;

  void call() => action();
}
