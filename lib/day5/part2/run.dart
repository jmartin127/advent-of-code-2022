import 'package:stack/stack.dart';

import '../../src/util.dart';

const indexLine = 8;

Future<void> main() async {
  final lines = await Util.readFileAsStrings('input.txt');

  // Create the stacks
  //  1   2   3   4   5   6   7   8   9
  Map<int, Stack<String>> stackById = {};
  Map<int, int> posByStackId = {};
  final idsLine = lines[indexLine];
  for (int i = 0; i < idsLine.length; i++) {
    final char = idsLine[i];
    if (char.trim().isNotEmpty) {
      final int currNum = int.parse(char);
      stackById[currNum] = Stack<String>();
      posByStackId[currNum] = i;
    }
  }

  // Initialize the stacks with the corresponding values
  // [G] [Z] [C] [H] [C] [R] [H] [P] [D]
  for (int i = indexLine - 1; i >= 0; i--) {
    final line = lines[i];
    for (final stackEntry in stackById.entries) {
      final stackId = stackEntry.key;
      final stack = stackEntry.value;
      final stackIndex = posByStackId[stackId]!;
      final val = line[stackIndex];
      if (val.trim().isNotEmpty) {
        stack.push(val);
      }
    }
  }

  // Apply the move operations
  // move 3 from 5 to 2
  for (int i = indexLine + 2; i < lines.length; i++) {
    final lineParts = lines[i].split(' ');
    final numToMove = int.parse(lineParts[1]);
    final fromStackId = int.parse(lineParts[3]);
    final toStackId = int.parse(lineParts[5]);
    Stack<String> tmpStack = Stack();
    for (int j = 0; j < numToMove; j++) {
      final v = stackById[fromStackId]!.pop();
      tmpStack.push(v);
    }
    final tmpLen = tmpStack.length;
    for (int j = 0; j < tmpLen; j++) {
      final v = tmpStack.pop();
      stackById[toStackId]!.push(v);
    }
  }

  // Get the values of the top of each stack
  var answer = '';
  for (int i = 1; i < 10; i++) {
    answer += stackById[i]!.top();
  }
  print(answer);
}
