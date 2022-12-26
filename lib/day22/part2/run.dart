import 'dart:io';

import '../../src/util.dart';

enum CubeFace {
  back, // #1
  right, // #2
  bottom, // #3
  left, // #4
  front, // #5
  top, // #6
}

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

  @override
  String toString() {
    return '$x, $y';
  }
}

class WrapResult {
  Point newPoint;
  FacingDirection newFacing;

  WrapResult(this.newPoint, this.newFacing);
}

class VisitedPoint {
  Point point;
  FacingDirection facing;

  VisitedPoint(this.point, this.facing);
}

class Board {
  List<List<String>> matrix = [];
  Point currentPostion = Point(0, 0);
  // Initially, you are facing to the right (from the perspective of how the map is drawn).
  FacingDirection facing = FacingDirection.right;
  Map<String, VisitedPoint> visitedPointsByCoords = {};

  Board();

  CubeFace getFaceForCoords(int x, int y) {
    if (x >= 50 && x <= 99 && y >= 0 && y <= 49) return CubeFace.back;
    if (x >= 100 && x <= 149 && y >= 0 && y <= 49) return CubeFace.right;
    if (x >= 50 && x <= 99 && y >= 50 && y <= 99) return CubeFace.bottom;
    if (x >= 0 && x <= 49 && y >= 100 && y <= 149) return CubeFace.left;
    if (x >= 50 && x <= 99 && y >= 100 && y <= 149) return CubeFace.front;
    if (x >= 0 && x <= 49 && y >= 150 && y <= 199) return CubeFace.top;

    throw Exception('could not get cube face from coords: $x, $y');
  }

  void recordCurrentPosition() {
    visitedPointsByCoords['${currentPostion.x},${currentPostion.y}'] =
        VisitedPoint(Point(currentPostion.x, currentPostion.y), facing);
  }

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
      } else if (instruction.direction == Direction.left) {
        turnLeft();
      } else {
        throw Exception('Bad directions');
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
      if (!moveOneTile()) {
        // don't keep moving if we hit a wall
        return;
      }
    }
  }

  // returns true if was able to move, false otherwise
  bool moveOneTile() {
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
    FacingDirection? newFacing;
    if (needToWrap(desiredX, desiredY)) {
      final wrapResult = wrapAround();
      final newPosition = wrapResult.newPoint;
      newFacing = wrapResult.newFacing;
      if (positionIsOffBoard(newPosition.x, newPosition.y)) {
        throw Exception('Off the board: ${newPosition.x}, ${newPosition.y}');
      }
      actualX = newPosition.x;
      actualY = newPosition.y;
    }

    // check if we hit a wall
    if (matrix[actualY][actualX] == '#') {
      return false;
    }

    // did not hit a wall, move
    // wraping can now cause us to face a different direction
    if (newFacing != null) {
      facing = newFacing;
    }
    moveToPosition(actualX, actualY);
    return true;
  }

  void moveToPosition(int newX, newY) {
    if (isItEmpty(newX, newY)) {
      throw Exception('Cannnot move to an empty position');
    }
    if (isWall(newX, newY)) {
      throw Exception('Cannot move into a wall');
    }
    recordCurrentPosition();
    currentPostion.x = newX;
    currentPostion.y = newY;
  }

  // It is possible for the next tile (after wrapping around) to be a wall;
  // this still counts as there being a wall in front of you, and so movement
  // stops before you actually wrap to the other side of the board.
  //
  // Returns null if not able to actually wrap around due to a wall
  WrapResult wrapAround() {
    final currentFace = getFaceForCoords(currentPostion.x, currentPostion.y);
    switch (currentFace) {
      case CubeFace.back:
        if (facing == FacingDirection.left) {
          return WrapResult(
              Point(0, 149 - currentPostion.y), FacingDirection.right);
        } else if (facing == FacingDirection.up) {
          return WrapResult(
              Point(0, currentPostion.x + 100), FacingDirection.right);
        }
        throw Exception('problem with back wrap');
      case CubeFace.right:
        if (facing == FacingDirection.up) {
          return WrapResult(
              Point(currentPostion.x - 100, 199), FacingDirection.up);
        } else if (facing == FacingDirection.right) {
          return WrapResult(
              Point(99, 149 - currentPostion.y), FacingDirection.left);
        } else if (facing == FacingDirection.down) {
          return WrapResult(
              Point(99, currentPostion.x - 50), FacingDirection.left);
        }
        throw Exception('problem with right wrap');
      case CubeFace.bottom:
        if (facing == FacingDirection.left) {
          return WrapResult(
              Point(currentPostion.y - 50, 100), FacingDirection.down);
        } else if (facing == FacingDirection.right) {
          return WrapResult(
              Point(currentPostion.y + 50, 49), FacingDirection.up);
        }
        throw Exception('problem with bottom wrap');
      case CubeFace.left:
        if (facing == FacingDirection.left) {
          return WrapResult(
              Point(50, 149 - currentPostion.y), FacingDirection.right);
        } else if (facing == FacingDirection.up) {
          return WrapResult(
              Point(50, currentPostion.x + 50), FacingDirection.right);
        }
        throw Exception('problem with left wrap');
      case CubeFace.front:
        if (facing == FacingDirection.right) {
          return WrapResult(
              Point(149, 149 - currentPostion.y), FacingDirection.left);
        } else if (facing == FacingDirection.down) {
          return WrapResult(
              Point(49, currentPostion.x + 100), FacingDirection.left);
        }
        throw Exception('problem with front wrap');
      case CubeFace.top:
        if (facing == FacingDirection.left) {
          return WrapResult(
              Point(currentPostion.y - 100, 0), FacingDirection.down);
        } else if (facing == FacingDirection.down) {
          return WrapResult(
              Point(currentPostion.x + 100, 0), FacingDirection.down);
        } else if (facing == FacingDirection.right) {
          return WrapResult(
              Point(currentPostion.y - 100, 149), FacingDirection.up);
        }
        throw Exception('problem with top wrap');
    }
  }

  bool needToWrap(int desiredX, int desiredY) {
    return positionIsOffBoard(desiredX, desiredY) ||
        isItEmpty(desiredX, desiredY);
  }

  bool isItEmpty(int x, int y) {
    final result = valueAtPostion(x, y).trim().isEmpty;
    return result;
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
        final val = matrix[i][j];
        stdout.write(val.isEmpty ? ' ' : val);
      }
      print('');
    }
  }

  void printMatrixWithPath() {
    for (int i = 0; i < matrix.length; i++) {
      for (int j = 0; j < matrix[i].length; j++) {
        String val = matrix[i][j];
        final visitedKey = '$j,$i';
        if (visitedPointsByCoords.containsKey(visitedKey)) {
          val = convertFacingtoAscii(visitedPointsByCoords[visitedKey]!.facing);
        }
        stdout.write(val.isEmpty ? ' ' : val);
      }
      print('');
    }
  }

  String convertFacingtoAscii(FacingDirection facing) {
    switch (facing) {
      case FacingDirection.left:
        return '<';
      case FacingDirection.right:
        return '>';
      case FacingDirection.up:
        return '^';
      case FacingDirection.down:
        return 'v';
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
          row.add(chars[x].trim());
        } else {
          row.add('');
        }
      }
      board.matrix.add(row);
    }
  }

  // find the starting tile
  board.initStartingPostion();
  print('Starting at: ${board.currentPostion}');

  // walk the path
  for (final instruction in instructions) {
    board.followInstruction(instruction);
  }
  board.recordCurrentPosition();

  board.printMatrixWithPath();

  // get the password
  print(board.password());
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
