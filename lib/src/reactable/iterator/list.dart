import 'dart:collection';

import '../core.dart';

class ReactableList<E> extends ReactableValueNotifier<List<E>>
    with ListMixin<E>, ReactableBase<List<E>> {
  ReactableList([List<E> initial = const []]) : super(initial);

  @override
  ReactableList<E> operator +(Iterable<E> other) {
    addAll(other);
    return this;
  }

  @override
  E operator [](int index) => value[index];

  @override
  void operator []=(int index, E val) {
    value[index] = val;
    notifyListeners();
  }

  @override
  void add(E element) {
    value.add(element);
    notifyListeners();
  }

  @override
  void insert(int index, E element) {
    value.insert(index, element);
    notifyListeners();
  }

  @override
  E removeAt(int index) {
    final removed = value.removeAt(index);
    notifyListeners();
    return removed;
  }

  @override
  bool remove(Object? element) {
    final bool result = value.remove(element);
    notifyListeners();
    return result;
  }

  @override
  void addAll(Iterable<E> iterable) {
    value.addAll(iterable);
    notifyListeners();
  }

  @override
  void insertAll(int index, Iterable<E> iterable) {
    value.insertAll(index, iterable);
    notifyListeners();
  }

  @override
  Iterator<E> get iterator => value.iterator;

  @override
  int get length => value.length;

  @override
  set length(int newLength) {
    value.length = newLength;
    notifyListeners();
  }

  @override
  void removeWhere(bool Function(E element) test) {
    value.removeWhere(test);
    notifyListeners();
  }

  @override
  void retainWhere(bool Function(E element) test) {
    value.retainWhere(test);
    notifyListeners();
  }

  @override
  E removeLast() {
    final result = value.removeLast();
    notifyListeners();
    return result;
  }

  @override
  Iterable<E> get reversed => value.reversed;

  @override
  void sort([int Function(E a, E b)? compare]) {
    value.sort(compare);
    notifyListeners();
  }

  @override
  void clear() {
    length = 0;
  }

  @override
  Iterable<E> where(bool Function(E) test) => value.where(test);

  @override
  Iterable<T> whereType<T>() => value.whereType<T>();
}

extension ListExtension<E> on List<E> {
  ReactableList<E> get asReactable => ReactableList<E>(this);
}
