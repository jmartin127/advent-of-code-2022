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

  // The numbers should be moved in the order they originally appear in the
  // encrypted file. Numbers moving around during the mixing process do not
  // change the order in which the numbers are moved.
  int count = 0;
  for (final currentNum in numbersOriginal) {
    count++;
    if (count % 100 == 0) {
      print('Count: $count');
    }
    // print('Moving $currentNum');

    final index = findIndexOfElement(numbers, currentNum)!;
    final foundNum = numbers.elementAt(index);
    // print('\tFound at index: $index');

    if (foundNum.value > 0) {
      // determine where the inseration is going to happen
      final insertAfterIndex = index + foundNum.value;
      final adjustedIndex = insertAfterIndex % numbersOriginal.length;
      if (adjustedIndex == index) {
        // nothing to do, same spot
        continue;
      }

      // if it is wanting to move to length-1, then move it to the beginning
      if (adjustedIndex == numbers.length - 1) {
        numbers.remove(foundNum);
        numbers.addFirst(foundNum);
      } else {
        // remove and add in new location
        final priorElement = numbers.elementAt(adjustedIndex);
        numbers.remove(foundNum);
        priorElement.insertAfter(foundNum);
      }
    } else if (foundNum.value < 0) {
      // determine where the inseration is going to happen
      final insertBeforeIndex = index + foundNum.value;
      var adjustedIndex = insertBeforeIndex % numbersOriginal.length;
      if (adjustedIndex < 0) {
        adjustedIndex = numbersOriginal.length + adjustedIndex;
      }
      if (adjustedIndex == index) {
        // nothing to do, same spot
        continue;
      }

      // if it is wanting to move to 0, then move it to the end
      if (adjustedIndex == 0) {
        numbers.remove(foundNum);
        numbers.add(foundNum);
      } else {
        // remove and add in new location
        final subsequentElement = numbers.elementAt(adjustedIndex);
        numbers.remove(foundNum);
        subsequentElement.insertBefore(foundNum);
      }
    } else {
      // nothing to do if the value is zero
    }

    // print('Updated list: $numbers');
  }

  // Then, the grove coordinates can be found by looking at the 1000th,
  // 2000th, and 3000th numbers after the value 0, wrapping around the list as
  // necessary.
  final zeroIndex = findIndexOfElement(numbers, zeroElement!)!;
  // print('Zero index: $zeroIndex');
  final oneThousandth = numbers.elementAt((zeroIndex + 1000) % numbers.length);
  final twoThousandth = numbers.elementAt((zeroIndex + 2000) % numbers.length);
  final threeThousandth =
      numbers.elementAt((zeroIndex + 3000) % numbers.length);
  final sum = oneThousandth.value + twoThousandth.value + threeThousandth.value;
  print('Sum: $sum');

  // too high: 13343
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
