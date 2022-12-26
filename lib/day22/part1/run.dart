import 'dart:io';

import '../../src/util.dart';

enum Direction {
  right,
  left,
}

enum FacingDirection {
  left,
  right,
  up,
  down,
}

class Instruction {
  bool isDirection;
  int? numTilesToMove;
  Direction? direction;

  Instruction(this.isDirection, this.numTilesToMove, this.direction);

  @override
  String toString() {
    return 'isDirection: $isDirection, numTilesToMove: $numTilesToMove, direction: $direction';
  }
}

class Point {
  int x;
  int y;

  Point(this.x, this.y);
}

class Board {
  List<List<String>> matrix = [];
  Point currentPostion = Point(0, 0);
  // Initially, you are facing to the right (from the perspective of how the map is drawn).
  FacingDirection facing = FacingDirection.right;

  Board();

  // The final password is the sum of 1000 times the row, 4 times the
  // column, and the facing.
  int password() {
    // Facing is 0 for right (>), 1 for down (v), 2 for left (<), and 3 for up (^).
    int facingVal = 0;
    switch (facing) {
      case FacingDirection.left:
        facingVal = 2;
        break;
      case FacingDirection.right:
        facingVal = 0;
        break;
      case FacingDirection.up:
        facingVal = 3;
        break;
      case FacingDirection.down:
        facingVal = 1;
        break;
    }
    return (1000 * (currentPostion.y + 1)) +
        (4 * (currentPostion.x + 1)) +
        facingVal;
  }

  void followInstruction(Instruction instruction) {
    if (instruction.isDirection) {
      if (instruction.direction == Direction.right) {
        turnRight();
      } else {
        turnLeft();
      }
    } else {
      moveNTiles(instruction.numTilesToMove!);
    }
  }

  // whether to turn 90 degrees clockwise (R)
  void turnRight() {
    switch (facing) {
      case FacingDirection.left:
        facing = FacingDirection.up;
        break;
      case FacingDirection.up:
        facing = FacingDirection.right;
        break;
      case FacingDirection.right:
        facing = FacingDirection.down;
        break;
      case FacingDirection.down:
        facing = FacingDirection.left;
        break;
    }
  }

  // or counterclockwise (L)
  void turnLeft() {
    switch (facing) {
      case FacingDirection.left:
        facing = FacingDirection.down;
        break;
      case FacingDirection.down:
        facing = FacingDirection.right;
        break;
      case FacingDirection.right:
        facing = FacingDirection.up;
        break;
      case FacingDirection.up:
        facing = FacingDirection.left;
        break;
    }
  }

  // A number indicates the number of tiles to move in the direction you are
  // facing.
  void moveNTiles(int numTilesToMove) {
    for (int i = 0; i < numTilesToMove; i++) {
      moveOneTile();
    }
  }

  void moveOneTile() {
    // figure out where we would like to go
    int desiredX = currentPostion.x;
    int desiredY = currentPostion.y;
    switch (facing) {
      case FacingDirection.down:
        desiredY++;
        break;
      case FacingDirection.left:
        desiredX--;
        break;
      case FacingDirection.right:
        desiredX++;
        break;
      case FacingDirection.up:
        desiredY--;
        break;
    }

    // handle wrapping
    var actualX = desiredX;
    var actualY = desiredY;
    if (needToWrap(desiredX, desiredY)) {
      final newPosition = wrapAround();
      if (newPosition == null) {
        return;
      }
      actualX = newPosition.x;
      actualY = newPosition.y;
    }

    // check if we hit a wall
    final char = matrix[actualY][actualX];
    if (char == '#') {
      return;
    }

    // did not hit a wall
    currentPostion.x = actualX;
    currentPostion.y = actualY;
  }

  // It is possible for the next tile (after wrapping around) to be a wall;
  // this still counts as there being a wall in front of you, and so movement
  // stops before you actually wrap to the other side of the board.
  //
  // Returns null if not able to actually wrap around due to a wall
  Point? wrapAround() {
    switch (facing) {
      case FacingDirection.down:
        // start at the top, go down, and find first non-empty square
        for (int newY = 0; newY < matrix.length; newY++) {
          final currentChar = matrix[newY][currentPostion.x];
          if (currentChar.isNotEmpty) {
            if (currentChar == '#') {
              return null;
            }
            return Point(currentPostion.x, newY);
          }
        }
        break;
      case FacingDirection.left:
        // start at the right, go left, and find first non-empty square
        for (int newX = matrix[0].length - 1; newX >= 0; newX--) {
          final currentChar = matrix[currentPostion.y][newX];
          if (currentChar.isNotEmpty) {
            if (currentChar == '#') {
              return null;
            }
            return Point(newX, currentPostion.y);
          }
        }
        break;
      case FacingDirection.right:
        // start at the left, go right, and find first non-empty square
        for (int newX = 0; newX < matrix[0].length; newX++) {
          final currentChar = matrix[currentPostion.y][newX];
          if (currentChar.isNotEmpty) {
            if (currentChar == '#') {
              return null;
            }
            return Point(newX, currentPostion.y);
          }
        }
        break;
      case FacingDirection.up:
        // start at the bottom, go up, and find first non-empty square
        for (int newY = matrix.length - 1; newY >= 0; newY--) {
          final currentChar = matrix[newY][currentPostion.x];
          if (currentChar.isNotEmpty) {
            if (currentChar == '#') {
              return null;
            }
            return Point(currentPostion.x, newY);
          }
        }
        break;
    }

    throw Exception('unable to wrap around');
  }

  bool needToWrap(int desiredX, int desiredY) {
    return positionIsOffBoard(desiredX, desiredY) ||
        isEmpty(desiredX, desiredY);
  }

  bool isEmpty(int x, int y) {
    return valueAtPostion(x, y) == '';
  }

  bool isWall(int x, int y) {
    return valueAtPostion(x, y) == '#';
  }

  String valueAtPostion(int x, int y) {
    return matrix[y][x];
  }

  bool positionIsOffBoard(int x, int y) {
    if (x < 0 || x >= matrix[0].length) {
      return true;
    }
    if (y < 0 || y >= matrix.length) {
      return true;
    }

    return false;
  }

  void printMatrix() {
    for (int i = 0; i < matrix.length; i++) {
      for (int j = 0; j < matrix[i].length; j++) {
        stdout.write(matrix[i][j]);
      }
      print('');
    }
  }

  // You begin the path in the leftmost open tile of the top row of tiles.
  void initStartingPostion() {
    for (int i = 0; i < matrix[0].length; i++) {
      if (matrix[0][i] == '.') {
        currentPostion = Point(i, 0);
        return;
      }
    }
    throw Exception('Could not find starting point');
  }
}

Future<void> main() async {
  final lines = await Util.readFileAsStrings('input.txt');

  // find the longest line
  int maxX = 0;
  for (final line in lines) {
    if (line.isEmpty) {
      break;
    }
    if (line.length > maxX) {
      maxX = line.length;
    }
  }
  print('maxX: $maxX');

  // parse the board
  Board board = Board();
  List<Instruction> instructions = [];
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (line.isEmpty) {
      instructions = parseInstructions(lines[i + 1]);
      break;
    } else {
      // '        #...'
      final chars = line.split('');
      List<String> row = [];
      for (int x = 0; x < maxX; x++) {
        if (x < chars.length) {
          row.add(chars[x]);
        } else {
          row.add('');
        }
      }
      board.matrix.add(row);
    }
  }

  // find the starting tile
  board.initStartingPostion();

  // walk the path
  for (final instruction in instructions) {
    board.followInstruction(instruction);
  }

  // get the password
  print(board.password());

  // too high: 111172
}

// 10R5L5R10L4R5L5
List<Instruction> parseInstructions(String input) {
  List<Instruction> instructions = [];
  String currentNum = '';
  for (final char in input.split('')) {
    if (char == 'R' || char == 'L') {
      if (currentNum != '') {
        final num = int.parse(currentNum);
        instructions.add(Instruction(false, num, null));
      }
      currentNum = '';
      instructions.add(Instruction(
          true, null, char == 'R' ? Direction.right : Direction.left));
    } else {
      currentNum += char;
    }
  }
  if (currentNum != '') {
    final num = int.parse(currentNum);
    instructions.add(Instruction(false, num, null));
  }
  return instructions;
}
