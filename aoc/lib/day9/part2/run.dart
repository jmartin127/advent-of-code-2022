import 'dart:io';

import '../../src/util.dart';

class MakeMove {
  int numStepsToMove;
  int xDirection;
  int yDirection;

  MakeMove(this.numStepsToMove, this.xDirection, this.yDirection);
}

class KnotPos {
  int x;
  int y;

  KnotPos(this.x, this.y);
}

Future<void> main() async {
  final lines = await Util.readFileAsStrings('input.txt');

  Map<String, bool> positionsVisited = {};
  Map<int, KnotPos> knotsById = {};
  for (int i = 0; i < 10; i++) {
    knotsById[i] = KnotPos(0, 0);
  }
  positionsVisited['${knotsById[9]!.x}.${knotsById[9]!.y}'] = true;
  for (final line in lines) {
    print('#################### INSTRUCTION: $line ####################');
    final lineParts = line.split(' ');
    final direction = lineParts[0];
    final numSteps = int.parse(lineParts[1]);
    for (int i = 0; i < numSteps; i++) {
      // move the front knot
      if (direction == 'R') {
        knotsById[0]!.x = knotsById[0]!.x + 1;
      } else if (direction == 'L') {
        knotsById[0]!.x = knotsById[0]!.x - 1;
      } else if (direction == 'U') {
        knotsById[0]!.y = knotsById[0]!.y - 1;
      } else if (direction == 'D') {
        knotsById[0]!.y = knotsById[0]!.y + 1;
      }

      // loop through each of the rest of the knots and move them
      for (int i = 1; i < 10; i++) {
        // find the positions of the previous knot
        int inFrontX = knotsById[i - 1]!.x;
        int inFrontY = knotsById[i - 1]!.y;
        int currentX = knotsById[i]!.x;
        int currentY = knotsById[i]!.y;
        final choice =
            chooseDirectionAndMagnitude(inFrontX, inFrontY, currentX, currentY);
        // move this one
        knotsById[i]!.x = knotsById[i]!.x + choice.xDirection;
        knotsById[i]!.y = knotsById[i]!.y + choice.yDirection;
      }
      // mark the 9th one as visited
      positionsVisited['${knotsById[9]!.x}.${knotsById[9]!.y}'] = true;
    }
    printResult(knotsById);
    print('');
  }
  for (final pos in positionsVisited.keys) {
    print(pos);
  }
  print(positionsVisited.keys.length);
}

void printResult(Map<int, KnotPos> knotsById) {
  List<List<int>> result = [];
  for (int i = 0; i < 50; i++) {
    List<int> row = [];
    for (int j = 0; j < 50; j++) {
      row.add(-1);
    }
    result.add(row);
  }
  for (int i = 9; i >= 0; i--) {
    final id = i;
    final pos = knotsById[i]!;
    result[pos.y + 25][pos.x + 25] = id;
  }

  for (int i = 0; i < result.length; i++) {
    for (int j = 0; j < result.length; j++) {
      final val = result[i][j];
      if (val == -1) {
        stdout.write('.');
      } else if (val == 0) {
        stdout.write('H');
      } else {
        stdout.write(val);
      }
    }
    stdout.write('\n');
  }
}

MakeMove chooseDirectionAndMagnitude(
    int headX, int headY, int tailX, int tailY) {
  if (headX - 2 == tailX && headY == tailY) {
    // tail is 2 left
    return MakeMove(1, 1, 0);
  } else if (headX + 2 == tailX && headY == tailY) {
    // tail is 2 right
    return MakeMove(1, -1, 0);
  } else if (headY - 2 == tailY && headX == tailX) {
    // tail is 2 up
    return MakeMove(1, 0, 1);
  } else if (headY + 2 == tailY && headX == tailX) {
    // tail is 2 down
    return MakeMove(1, 0, -1);
  }

  // if either the x difference or the y difference is >=2 then it must be a diagonal move
  final xDiff = absolute(headX, tailX);
  final yDiff = absolute(headY, tailY);
  if (xDiff >= 2 || yDiff >= 2) {
    if (headX - tailX == 2) {
      // tail is to the left
      // check if the tail is up or down
      if (headY - tailY == 1) {
        // tail is above
        // move diag down and right
        return MakeMove(1, 1, 1);
      } else {
        // move diag up and right
        return MakeMove(1, 1, -1);
      }
    } else if (tailX - headX == 2) {
      // tail is to the right
      // check if the tail is up or down
      if (headY - tailY == 1) {
        // tail is above
        // move diag down and right
        return MakeMove(1, -1, 1);
      } else {
        // move diag up and right
        return MakeMove(1, -1, -1);
      }
    } else if (headY - tailY == 2) {
      // tail is up
      // check if the head is left or right
      if (tailX - headX == 1) {
        // tail is right
        // move diag left and down
        return MakeMove(1, -1, 1);
      } else {
        // move diag right and down
        return MakeMove(1, 1, 1);
      }
    } else if (tailY - headY == 2) {
      // tail is down
      // check if the head is left or right
      if (tailX - headX == 1) {
        // tail is right
        // move diag left and down
        return MakeMove(1, -1, -1);
      } else {
        // move diag right and down
        return MakeMove(1, 1, -1);
      }
    }
  }

  return MakeMove(0, 0, 0); // don't move
}

int absolute(int a, int b) {
  if (a > b) {
    return a - b;
  }
  return b - a;
}
