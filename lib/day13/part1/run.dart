import 'package:stack/stack.dart';

import '../../src/util.dart';

class Element {
  String packet;
  int endPos;
  Element(this.packet, this.endPos);
}

Future<void> main() async {
  final lines = await Util.readFileAsStrings('input.txt');

  int counter = 0;
  int answer = 0;
  for (int i = 0; i < lines.length; i = i + 3) {
    counter++;
    final line1 = lines[i];
    final line2 = lines[i + 1];
    print('Line1 $line1');
    print('Line2 $line2');
    if (comparePackets(line1, line2) == true) {
      answer += counter;
    }
  }
  print(answer);
}

// returns true if in the right order
// Compare [1,[2,[3,[4,[5,6,7]]]],8,9] vs [1,[2,[3,[4,[5,6,0]]]],8,9]
bool? comparePackets(String packet1, String packet2) {
  var listOne = parsePacket(packet1);
  var listTwo = parsePacket(packet2);

  /*
  If both values are integers, the lower integer should come first. If the left 
  integer is lower than the right integer, the inputs are in the right order. 
  If the left integer is higher than the right integer, the inputs are not in 
  the right order. Otherwise, the inputs are the same integer; continue checking 
  the next part of the input.
  */
  if (listOne is int && listTwo is int) {
    int numberOne = listOne as int;
    int numberTwo = listTwo as int;
    if (numberOne < numberTwo) {
      return true;
    } else if (numberOne > numberTwo) {
      return false;
    } else {
      return null;
    }
  }

  /*
  If exactly one value is an integer, convert the integer to a list which contains 
  that integer as its only value, then retry the comparison. For example, if 
  comparing [0,0,0] and 2, convert the right value to [2] (a list containing 2); 
  the result is then found by instead comparing [0,0,0] and [2].
  */
  if (listOne is int && listTwo is! int) {
    listOne = [listOne as int];
  }
  if (listOne is! int && listTwo is int) {
    listTwo = [listTwo as int];
  }

  /*
  If both values are lists, compare the first value of each list, then the second 
  value, and so on. If the left list runs out of items first, the inputs are in 
  the right order. If the right list runs out of items first, the inputs are not 
  in the right order. If the lists are the same length and no comparison makes a 
  decision about the order, continue checking the next part of the input.
  */
  if (listOne is! int && listTwo is! int) {
    for (int i = 0; true; i++) {
      // ran out, but of equal length
      if (i >= listOne.length &&
          i >= listTwo.length &&
          listOne.length == listTwo.length) {
        // throw Exception('Not sure what to do');
        return null;
      }

      // ran out of items on left list
      if (i >= listOne.length) {
        return true;
      }
      // ran out of items on right list
      if (i >= listTwo.length) {
        return false;
      }

      // still have items
      // final valOne = listOne[i];
      // final valTwo = listTwo[i];

      int counter = 0;

      // go through each item in the list sequentially
      while (true) {
        // print('COMPARING: $listOne and $listTwo counter $counter');
        if (counter >= listOne.length && counter < listTwo.length) {
          // ran out on left but not right
          return true;
        } else if (counter >= listTwo.length && counter < listOne.length) {
          // ran out on right but not left
          return false;
        } else if (counter >= listOne.length) {
          return null;
        }
        // recursively compare
        final currentResult = comparePackets(
            listOne[counter].toString().replaceAll(' ', ''),
            listTwo[counter].toString().replaceAll(' ', ''));
        if (currentResult != null) {
          return currentResult;
        }
        counter++;
      }
    }
  }

  return false;
}

// [[1],[2,3,4]]
dynamic parsePacket(String packet) {
  Map<int, List<dynamic>> listByStartPos = {};

  // print('INPUT: $packet');
  // final parsingStack = Stack<String>();
  final stackOfListStartPos = Stack<int>();
  List<dynamic>? currentList;
  for (int i = 0; i < packet.length; i++) {
    final char = packet[i];
    if (char == '[') {
      // create a new list
      // set the list by start position
      List<dynamic> newList = [];
      listByStartPos[i] = newList;
      stackOfListStartPos.push(i);
      // add this list as an element to the current
      if (currentList != null) {
        currentList.add(newList);
      }
      // set this list as the current list
      currentList = newList;
    } else if (char == ']') {
      // pop from the stack to set the new list
      if (stackOfListStartPos.isNotEmpty) {
        final startParenPos = stackOfListStartPos.pop();
        currentList = listByStartPos[startParenPos]!;
      }
      // if the next character is a closing paren, we're done, otherwise pop next and set as current
      if (i != packet.length - 1) {
        final nextChar = packet[i + 1];
        if (nextChar != ']') {
          if (stackOfListStartPos.isNotEmpty) {
            final startParenPos = stackOfListStartPos.pop();
            // print('Setting list to list starting at: $startParenPos');
            currentList = listByStartPos[startParenPos]!;
          }
        }
      }
    } else if (char == ',') {
      // nothing to do here, just go to the net element
    } else {
      // must be a number, read until no more numbers
      var numberStr = '';
      for (int j = i; j < packet.length; j++) {
        var numberChar = packet[j];
        if (numberChar == ',' || numberChar == '[' || numberChar == ']') {
          break;
        }
        numberStr = numberStr + numberChar;
      }
      // then add the number to the list
      // print('Parsing: $numberStr.');
      final number = int.parse(numberStr);
      if (currentList == null) {
        return number;
      } else {
        currentList.add(number);
      }
    }
  }

  // print(listByStartPos[0]!);
  return listByStartPos[0]!;
}

Element? getNextElement(
    String packet, int startIndex, Map<int, int> endParenPosByStart) {
  // for example, just a single number
  if (!packet.startsWith('[')) {
    return Element(packet, packet.length);
  }

  // for example, []
  final secondChar = packet[1];
  if (secondChar == ']') {
    return null;
  }

  // now we know it has an opening paren, that is followed by some sort of list
  if (secondChar == '[') {
    // we know it is a nested list
    int endIndex = endParenPosByStart[1]!;
    final newPacket = packet.substring(1, endIndex + 1);
    return Element(newPacket, -1); // TODO
  } else {
    // we know the next thing is a number we need to return
    var numberString = '';
    for (int i = 1; i < packet.length; i++) {
      var char = packet[i];
      if (char == ',' || char == '[' || char == ']') {
        break;
      }
      numberString += char;
    }
    return Element(numberString, -1);
  }
}
