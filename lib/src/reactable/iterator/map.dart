import 'dart:collection';

import '../core.dart';

/// The main implementation of the reactable map.
class ReactableMap<K, V> extends ReactableValueNotifier<Map<K, V>>
    with MapMixin<K, V>, ReactableBase<Map<K, V>> {
  ReactableMap([Map<K, V> initial = const {}, bool canBeAutoDisposed = true])
      : super(initial, canBeAutoDisposed);

  @override
  V? operator [](Object? key) {
    return value[key as K];
  }

  @override
  void operator []=(K key, V value) {
    this.value[key] = value;
    notifyListeners();
  }

  @override
  void clear() {
    value.clear();
    notifyListeners();
  }

  @override
  int get length => value.length;

  @override
  Iterable<K> get keys => value.keys;

  @override
  V? remove(Object? key) {
    final val = value.remove(key);
    notifyListeners();
    return val;
  }
}

/// An extension to convert a map to a reactable map.
extension MapExtension<K, V> on Map<K, V> {
  /// Convert this map to reactable map.
  ReactableMap<K, V> get asReactable => ReactableMap<K, V>(this);
}
