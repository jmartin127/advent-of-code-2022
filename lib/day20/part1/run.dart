import 'dart:collection';

import '../../src/util.dart';
import 'package:quiver/core.dart';

class Element extends LinkedListEntry<Element> {
  int value;
  int originalIndex;

  Element(this.value, this.originalIndex);

  @override
  String toString() {
    return '$value';
  }

  @override
  bool operator ==(Object other) =>
      other is Element &&
      other.value == value &&
      other.originalIndex == originalIndex;

  @override
  int get hashCode => hash2(value.hashCode, originalIndex.hashCode);
}

Future<void> main() async {
  final lines = await Util.readFileAsStrings('input.txt');

  // Note: the input does have duplicates unfortunately
  // From 5000 lines --> 3615 lines when applying: cat input.txt | sort | uniq  | wc -l
  // It isn't real clear from the wording of the problem if these should be
  // treated independently or not.
  final numbers = LinkedList<Element>();
  final numbersOriginal = LinkedList<Element>();
  Element? zeroElement;
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    final val = int.parse(line);
    numbers.add(Element(val, i));
    numbersOriginal.add(Element(val, i));
    if (val == 0) {
      zeroElement = numbers.last;
    }
  }
  // print('Length: ${numbers.length}');
  print('Zero was found $zeroElement at ${zeroElement!.originalIndex}');

  // The numbers should be moved in the order they originally appear in the
  // encrypted file. Numbers moving around during the mixing process do not
  // change the order in which the numbers are moved.
  for (final currentNum in numbersOriginal) {
    final index = findIndexOfElement(numbers, currentNum)!;
    final foundNum = numbers.elementAt(index);

    final adjustedIndex = findNewIndex(index, numbers.length, foundNum.value);

    if (adjustedIndex == index) {
      // nothing to do, same spot
      continue;
    }

    numbers.remove(foundNum);
    numbers.elementAt(adjustedIndex).insertBefore(foundNum);
  }

  // Then, the grove coordinates can be found by looking at the 1000th,
  // 2000th, and 3000th numbers after the value 0, wrapping around the list as
  // necessary.
  print('Final length: ${numbers.length}');
  final zeroIndex = findIndexOfElement(numbers, zeroElement)!;
  print('Zero index: $zeroIndex');
  final oneThousandth = numbers.elementAt((zeroIndex + 1000) % numbers.length);
  final twoThousandth = numbers.elementAt((zeroIndex + 2000) % numbers.length);
  final threeThousandth =
      numbers.elementAt((zeroIndex + 3000) % numbers.length);
  final sum = oneThousandth.value + twoThousandth.value + threeThousandth.value;
  print('oneThousandth: $oneThousandth');
  print('twoThousandth: $twoThousandth');
  print('threeThousandth: $threeThousandth');
  print('Sum: $sum');

  // too high: 13343
  // incorrect: -11909, -9415, -10493, 11539
  // must be: 1591
}

int? findIndexOfElement(LinkedList<Element> numbers, Element element) {
  int index = 0;
  for (final otherNum in numbers) {
    if (element == otherNum) {
      return index;
    }
    index++;
  }
  return null;
}

int findNewIndex(int currentIndex, int listLength, int numToMove) {
  int newIndex = myModFunction((currentIndex + numToMove), listLength - 1);
  if (newIndex < 0) {
    newIndex = listLength + newIndex - 1;
  }
  return newIndex;
}

int myModFunction(int a, int b) {
  if (a > 0) {
    return a % b;
  }

  return ((a * -1) % b) * -1;
}
