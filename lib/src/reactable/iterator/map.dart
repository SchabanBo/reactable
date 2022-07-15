import 'dart:collection';

import '../core.dart';

class ReactableMap<K, V> extends ReactableValueNotifier<Map<K, V>>
    with MapMixin<K, V>, ReactableBase<Map<K, V>> {
  ReactableMap([Map<K, V> initial = const {}]) : super(initial);

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

extension MapExtension<K, V> on Map<K, V> {
  ReactableMap<K, V> get asReactable => ReactableMap<K, V>(this);
}
