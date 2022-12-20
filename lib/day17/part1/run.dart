import 'dart:io';

import '../../src/util.dart';

final int boardHeight = 100;

class Rock {
  List<List<bool>> shape;
  int xPos = 0;
  int yPos = 0;

  Rock(this.shape);

  int height() {
    return shape.length;
  }

  int width() {
    return shape[0].length;
  }

  Rock copy() {
    // the shape shouldn't change so use same list
    final newRock = Rock(shape);
    newRock.xPos = xPos;
    newRock.yPos = yPos;
    return newRock;
  }
}

final dashRock = Rock([
  [true, true, true, true]
]);
final plusRock = Rock([
  [false, true, false],
  [true, true, true],
  [false, true, false],
]);
final lRock = Rock([
  [true, true, true],
  [false, false, true],
  [false, false, true],
]);
final stickRock = Rock([
  [true],
  [true],
  [true],
  [true],
]);
final squareRock = Rock([
  [true, true],
  [true, true],
]);

Map<Rock, Rock> nextRock = {
  dashRock: plusRock,
  plusRock: lRock,
  lRock: stickRock,
  stickRock: squareRock,
  squareRock: dashRock
};

class Board {
  List<List<String>> values = [];
  int highestRockInRoom = 0; // TODO ensure this is getting set

  Board();

  void init(int width, int height) {
    for (int i = 0; i < height; i++) {
      List<String> row = [];
      for (int j = 0; j < width; j++) {
        row.add('.');
      }
      values.add(row);
    }
  }

  int height() {
    return values.length;
  }

  int width() {
    return values[0].length;
  }

  void setRockPostionsToValue(Rock rock, String val) {
    for (int i = 0; i < rock.height(); i++) {
      for (int j = 0; j < rock.width(); j++) {
        if (rock.shape[i][j]) {
          int xPos = j + rock.xPos;
          int yPos = i + rock.yPos;
          values[yPos][xPos] = val;
        }
      }
    }
  }

  // The tall, vertical chamber is exactly seven units wide. Each rock appears
  // so that its left edge is two units away from the left wall and its bottom
  // edge is three units above the highest rock in the room (or the floor, if
  // there isn't one).
  void startNewRock(Rock rock) {
    rock.xPos = 2;
    rock.yPos = highestRockInRoom + 3;
    setRockInMotion(rock);
  }

  void setRockInMotion(Rock rock) {
    setRockPostionsToValue(rock, '@');
  }

  void removeRock(Rock rock) {
    setRockPostionsToValue(rock, '.');
  }

  void moveToSide(Rock rock, bool moveRight) {
    // first remove the shape so that it doesn't interfere for itself
    removeRock(rock);

    // then move the rock if we can
    if (canShiftRock(rock, moveRight)) {
      rock.xPos = rock.xPos + (moveRight ? 1 : -1);
    }

    // either way set it back to in motion
    setRockInMotion(rock);
  }

  bool canShiftRock(Rock rock, bool moveRight) {
    for (int i = 0; i < rock.height(); i++) {
      for (int j = 0; j < rock.width(); j++) {
        // shift to the new coord
        int newJ = j;
        if (moveRight) {
          newJ++;
        } else {
          newJ--;
        }

        if (rock.shape[i][j]) {
          int xPos = newJ + rock.xPos;
          int yPos = i + rock.yPos;
          if (!isValidAndOpenPosition(yPos, xPos)) {
            return false;
          }
        }
      }
    }
    return true;
  }

  bool isValidAndOpenPosition(int i, int j) {
    if (i < 0 || i >= height()) {
      return false;
    }
    if (j < 0 || j >= width()) {
      return false;
    }
    return values[i][j] == '.';
  }

  void printBoard() {
    for (int i = boardHeight - 1; i >= 0; i--) {
      final row = values[i];
      for (int j = 0; j < row.length; j++) {
        final val = row[j];
        stdout.write(val);
      }
      print('');
    }
    print('');
  }
}

// Summary: Tetris (or so it appears)
Future<void> main() async {
  final lines = await Util.readFileAsStrings('input.txt');

  // parse the input arrow directions
  List<bool> directionsIsRight = [];
  for (final direction in lines[0].split('')) {
    directionsIsRight.add(direction == '>');
  }

  // initialize the board
  final board = Board();
  board.init(7, boardHeight);
  board.printBoard();

  // start dropping pieces
  Rock lastRock = dashRock;
  board.startNewRock(lastRock);
  board.printBoard();
  board.moveToSide(lastRock, false);
  board.moveToSide(lastRock, false);
  board.printBoard();
}
