import 'package:flutter_test/flutter_test.dart';
import 'package:reactable/reactable.dart';

void main() {
  test('Observable map test', () {
    final map = <String, int>{}.asReactable;
    var actions = 0;
    map.addListener(() => actions++);

    map['a'] = 1;
    expect(actions, 1);
    expect(map.length, 1);

    map.update('a', (val) => val + 1);
    expect(actions, 2);
    expect(map['a'], 2);
    expect(map.keys.first, 'a');

    map.remove('a');
    expect(actions, 3);
    expect(map.length, 0);

    map['a'] = 8;
    expect(actions, 4);
    expect(map.length, 1);

    map.clear();
    expect(actions, 5);
    expect(map.length, 0);
  });
}
