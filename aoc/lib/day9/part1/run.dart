import '../../src/util.dart';

class MakeMove {
  int numStepsToMove;
  int xDirection;
  int yDirection;

  MakeMove(this.numStepsToMove, this.xDirection, this.yDirection);
}

Future<void> main() async {
  final lines = await Util.readFileAsStrings('input.txt');

  Map<String, bool> positionsVisited = {};
  int headX = 0;
  int headY = 0;
  int tailX = 0;
  int tailY = 0;
  positionsVisited['$tailX.$tailY'] = true;
  for (final line in lines) {
    final lineParts = line.split(' ');
    final direction = lineParts[0];
    final numSteps = int.parse(lineParts[1]);
    for (int i = 0; i < numSteps; i++) {
      if (direction == 'R') {
        headX++;
      } else if (direction == 'L') {
        headX--;
      } else if (direction == 'U') {
        headY--;
      } else if (direction == 'D') {
        headY++;
      }
      // move the head
      final choice = chooseDirectionAndMagnitude(headX, headY, tailX, tailY);
      if (choice != null) {
        tailX += choice.xDirection;
        tailY += choice.yDirection;
        positionsVisited['$tailX.$tailY'] = true;
      }
    }
  }
  print(positionsVisited.length);
}

MakeMove? chooseDirectionAndMagnitude(
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
