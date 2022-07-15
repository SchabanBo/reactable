import 'package:flutter_test/flutter_test.dart';
import 'package:reactable/reactable.dart';

void main() {
  test('Observable list Test', () {
    var list = [1, 2, 3].asReactable;
    var actions = 0;
    list.addListener(() => actions++);
    expect(list.length, 3);
    expect(list[0], 1);

    list.add(4);
    expect(list.length, 4);
    expect(actions, 1);

    list.remove(2);
    expect(list.length, 3);
    expect(actions, 2);

    list.removeWhere((e) => e == 1);
    expect(list.length, 2);
    expect(actions, 3);

    list.insert(0, 0);
    expect(list.length, 3);
    expect(actions, 4);

    list.insertAll(0, [5, 6]);
    expect(list.length, 5);
    expect(actions, 5);

    list.removeAt(0);
    expect(list.length, 4);
    expect(actions, 6);

    list.removeLast();
    expect(list.length, 3);
    expect(actions, 7);

    list.clear();
    expect(list.length, 0);
    expect(actions, 8);

    list.addAll([1, 2, 3]);
    expect(list.length, 3);
    expect(actions, 9);

    list[0] = 5;
    expect(list.length, 3);
    expect(list[0], 5);
    expect(actions, 10);

    final newList = list + [4, 4, 4];
    expect(newList.length, 6);
    expect(actions, 11);

    expect(list.where((p0) => p0 == 4).length, 3);
    expect(list.whereType<int>().length, 6);

    list.sort();
    expect(list.length, 6);
    expect(actions, 12);

    expect(list.first, 2);
    expect(list.reversed.first, 5);
    expect(actions, 12);

    list.retainWhere((element) => element == 5);
    expect(list.length, 1);
    expect(actions, 13);

    expect(list.iterator, isA<Iterator>());

    list.refresh();
    expect(actions, 14);
  });
}
