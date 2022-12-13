import 'package:aoc/day13/part1/run.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

Future<void> main() async {
  test('parsePacket', () {
    var result = comparePackets('[1,1,3,1,1]', '[1,1,5,1,1]');
    expect(result, true);

    result = comparePackets('[[1],[2,3,4]]', '[[1],4]');
    expect(result, true);

    result = comparePackets('[9]', '[[8,7,6]]');
    expect(result, false);

    result = comparePackets('[[4,4],4,4]', '[[4,4],4,4,4]');
    expect(result, true);

    result = comparePackets('[7,7,7,7]', '[7,7,7]');
    expect(result, false);

    result = comparePackets('[]', '[3]');
    expect(result, true);

    result = comparePackets('[[[]]]', '[[]]');
    expect(result, false);

    result = comparePackets(
        '[1,[2,[3,[4,[5,6,7]]]],8,9]', '[1,[2,[3,[4,[5,6,0]]]],8,9]');
    expect(result, false);
  });

  test('parsePacket', () {
    var result = parsePacket('[1,1,3,1,1]');
    expect(result.length, 5);

    result = parsePacket('[[1],[2,3,4]]');
    expect(result.length, 2);

    result = parsePacket('[9]');
    expect(result.length, 1);

    result = parsePacket('[[4,4],4,4]');
    expect(result.length, 3);

    result = parsePacket('[7,7,7,7]');
    expect(result.length, 4);

    result = parsePacket('[]');
    expect(result.length, 0);

    result = parsePacket('[[[]]]');
    expect(result.length, 1);

    result = parsePacket('[1,[2,[3,[4,[5,6,7]]]],8,9]');
    expect(result.length, 4);
  });

  test('getNextElement', () {
    // [1,1,3,1,1] ==> returns 1
    var result = getNextElement('[1,1,3,1,1]', 0, {0: 10});
    expect(result!.packet, '1');

    // [[1],[2,3,4]] ==> returns [1]
    result = getNextElement('[[1],[2,3,4]]', 0, {0: 12, 1: 3, 5: 11});
    expect(result!.packet, '[1]');

    // [9] ==> returns 9
    result = getNextElement('[9]', 0, {0: 2});
    expect(result!.packet, '9');

    // 9 ==> returns 9
    result = getNextElement('9', 0, {});
    expect(result!.packet, '9');

    // [[4,4],4,4] ==> returns [4,4]
    result = getNextElement('[[4,4],4,4]', 0, {0: 10, 1: 5});
    expect(result!.packet, '[4,4]');

    // [7,7,7,7] ==> returns 7
    result = getNextElement('[7,7,7,7]', 0, {0: 8});
    expect(result!.packet, '7');

    // [] ==> returns null
    result = getNextElement('[]', 0, {0: 1});
    expect(result, isNull);

    // [[[]]] ==> returns [[]]
    result = getNextElement('[[[]]]', 0, {0: 5, 1: 4, 2: 3});
    expect(result!.packet, '[[]]');

    // [1,[2,[3,[4,[5,6,7]]]],8,9] ==> returns 1
    result = getNextElement('[1,[2,[3,[4,[5,6,7]]]],8,9]', 0, {0: 26, 3: 22});
    expect(result!.packet, '1');
  });
}
