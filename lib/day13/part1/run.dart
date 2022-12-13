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
  for (int i = 0; i < lines.length; i = i + 2) {
    counter++;
    final line1 = lines[i];
    final line2 = lines[i + 1];
    if (comparePackets(line1, line2)) {
      answer += counter;
    }
  }
  print(answer);
}

// returns true if in the right order
// Compare [1,[2,[3,[4,[5,6,7]]]],8,9] vs [1,[2,[3,[4,[5,6,0]]]],8,9]
bool comparePackets(String packet1, String packet2) {
  // parsePacket(packet1);

  return true;
}

// [[1],[2,3,4]]
List<dynamic> parsePacket(String packet) {
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
      final number = int.parse(numberStr);
      currentList!.add(number);
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
