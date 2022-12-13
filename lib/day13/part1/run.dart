import 'package:stack/stack.dart';

import '../../src/util.dart';

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
  parsePacket(packet1);

  return true;
}

// [[1],[2,3,4]]
List<dynamic> parsePacket(String packet) {
  Map<String, List<dynamic>> listByPos = {};

  print('INPUT: $packet');
  final parsingStack = Stack<String>();
  for (int i = 0; i < packet.length; i++) {
    final char = packet[i];
    // found the end of a list
    if (char == ']') {
      // pop from the stack until we get to an opening paren
      String withinParens = '';
      while (parsingStack.isNotEmpty) {
        final val = parsingStack.pop();
        if (val == '[') {
          print('Found: $withinParens');
          final idOfOpenParen = parsingStack.pop();
          print('List starts at: $idOfOpenParen');
          final currentList = listByPos[idOfOpenParen];
          break;
        }
        withinParens = val + withinParens;
      }
    } else {
      if (char == '[') {
        final parenId = '$i';
        listByPos[parenId] = [];
        parsingStack.push(
            parenId); // push a fake element on the stack that is the position of the opening paren
      }
      parsingStack.push(char);
    }
  }

  return [];
}
