import 'package:aoc/day20/part1/run.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  test('negative mod', () {
    expect(myModFunction(-10, 9), -1);
    expect(myModFunction(-6, 9), -6);
    expect(myModFunction(-11, 9), -2);
    expect(myModFunction(-7, 9), -7);
    expect(myModFunction(-20, 9), -2);
  });

  test('Test basic forward movement', () {
    ///   currentIndex: 5
    ///   listLength: 10
    ///   numToMove: 2
    ///   answer: 7
    expect(findNewIndex(5, 10, 2), 7);
  });

  test('Test move forward, not full wrap', () {
    ///   currentIndex: 5
    ///   listLength: 10
    ///   numToMove: 7
    ///   answer: 2
    expect(findNewIndex(5, 10, 7), 2);
  });

  test('Test move forward, 1 full wrap past', () {
    ///   currentIndex: 5
    ///   listLength: 10
    ///   numToMove: 10
    ///   answer: 7
    expect(findNewIndex(5, 10, 10), 6);
  });

  test('Test move forward, 2 full wrap past', () {
    ///   currentIndex: 5
    ///   listLength: 10
    ///   numToMove: 20
    ///   answer: 7
    expect(findNewIndex(5, 10, 20), 7);
  });

  test('Test move forward, 3 full wrap past', () {
    ///   currentIndex: 5
    ///   listLength: 10
    ///   numToMove: 30
    ///   answer: 8
    expect(findNewIndex(5, 10, 30), 8);
  });

  test('Test basic backward movement', () {
    ///   currentIndex: 5
    ///   listLength: 10
    ///   numToMove: -2
    ///   answer: 3
    expect(findNewIndex(5, 10, -2), 3);
  });

  test('Test move backward, not full wrap', () {
    ///   currentIndex: 5
    ///   listLength: 10
    ///   numToMove: -7
    ///   answer: 8
    expect(findNewIndex(5, 10, -7), 8);
  });

  test('Test move backward, 1 full wrap past', () {
    ///   currentIndex: 5
    ///   listLength: 10
    ///   numToMove: -10
    ///   answer: 4
    expect(findNewIndex(5, 10, -10), 4);
  });

  test('Test move backward, 2 full wrap past', () {
    ///   currentIndex: 5
    ///   listLength: 10
    ///   numToMove: -20
    ///   answer: 3
    expect(findNewIndex(5, 10, -20), 3);
  });

  test('Test move backward, 4 full wrap past', () {
    ///   currentIndex: 5
    ///   listLength: 10
    ///   numToMove: -30
    ///   answer: 2
    expect(findNewIndex(5, 10, -30), 2);
  });

  test('Test move backward, 6 full wrap past', () {
    ///   currentIndex: 5
    ///   listLength: 10
    ///   numToMove: -50
    ///   answer: 0
    expect(findNewIndex(5, 10, -50), 0);
  });

  test('Test move backward, 7 full wrap past', () {
    ///   currentIndex: 5
    ///   listLength: 10
    ///   numToMove: -60
    ///   answer: 0
    expect(findNewIndex(5, 10, -60), 9);
  });

  test('Test move backward, test #1', () {
    ///   currentIndex: 2
    ///   listLength: 5
    ///   numToMove: -9
    ///   answer: 1
    expect(findNewIndex(2, 5, -9), 1);
  });

  test('Test real #1', () {
    ///   currentIndex: 4982
    ///   listLength: 5000
    ///   numToMove: -2494
    ///   answer: 2488
    expect(findNewIndex(4982, 5000, -2494), 2488);
  });

  test('Test real #2', () {
    ///   currentIndex: 4979
    ///   listLength: 5000
    ///   numToMove: -8457
    ///   answer: 1521
    expect(findNewIndex(4979, 5000, -8457), 1521);
  });

  test('Test real #3', () {
    ///   currentIndex: 4990
    ///   listLength: 5000
    ///   numToMove: 934
    ///   answer: 924
    expect(findNewIndex(4990, 5000, 934), 924);
  });

  test('Test real #4', () {
    ///   currentIndex: 2282
    ///   listLength: 5000
    ///   numToMove: -1010
    ///   answer: 1272
    expect(findNewIndex(2282, 5000, -1010), 1272);
  });

  test('Test real #5', () {
    ///   currentIndex: 11
    ///   listLength: 5000
    ///   numToMove: -9904
    ///   answer: 106 (same as below)
    expect(findNewIndex(11, 5000, -9904), 106);
  });

  test('Test real #5', () {
    ///   currentIndex: 11
    ///   listLength: 5000
    ///   numToMove: -4905 (not full wrap)
    ///   answer: 106 (95 + 11)
    expect(findNewIndex(11, 5000, -4905), 106);
  });

  test('Test real #6', () {
    ///   currentIndex: 11
    ///   listLength: 5000
    ///   numToMove: -4999
    ///   answer: 12
    expect(findNewIndex(11, 5000, -4999), 12);
  });

  test('Test real #7', () {
    ///   currentIndex: 11
    ///   listLength: 5000
    ///   numToMove: -4999
    ///   answer: 12
    expect(findNewIndex(11, 5000, -4999), 12);
  });

  test('Test real #8', () {
    ///   currentIndex: 49
    ///   listLength: 5000
    ///   numToMove: 5000
    ///   answer: 50
    expect(findNewIndex(49, 5000, 5000), 50);
  });

  test('Test additional #1', () {
    ///   currentIndex: 5
    ///   listLength: 10
    ///   numToMove: -10
    ///   answer: 4
    expect(findNewIndex(4, 10, -10), 3);
  });
}
