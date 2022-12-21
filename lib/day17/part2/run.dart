import 'dart:collection';
import 'dart:io';

import '../../src/util.dart';

final int boardWindowHeight = 10000;
final int numPieces = 2022;

class Rock {
  String key;
  List<List<bool>> shape;
  int xPos = 0;
  int yPos = 0;

  Rock(this.key, this.shape);

  int height() {
    return shape.length;
  }

  int width() {
    return shape[0].length;
  }

  Rock copy() {
    // the shape shouldn't change so use same list
    final newRock = Rock(key, shape);
    newRock.xPos = xPos;
    newRock.yPos = yPos;
    return newRock;
  }

  @override
  String toString() {
    return 'Key: $key, x: $xPos, y: $yPos';
  }
}

final dashRock = Rock('-', [
  [true, true, true, true]
]);
final plusRock = Rock('+', [
  [false, true, false],
  [true, true, true],
  [false, true, false],
]);
final lRock = Rock('l', [
  [true, true, true],
  [false, false, true],
  [false, false, true],
]);
final stickRock = Rock('|', [
  [true],
  [true],
  [true],
  [true],
]);
final squareRock = Rock('[', [
  [true, true],
  [true, true],
]);

Map<String, Rock> nextRock = {
  '-': plusRock,
  '+': lRock,
  'l': stickRock,
  '|': squareRock,
  '[': dashRock,
};

class Board {
  ListQueue<List<String>> values = ListQueue();
  int highestRockInRoom = 0;

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
    return values.first.length;
  }

  void setRockPostionsToValue(Rock rock, String val) {
    for (int i = 0; i < rock.height(); i++) {
      for (int j = 0; j < rock.width(); j++) {
        if (rock.shape[i][j]) {
          int xPos = j + rock.xPos;
          int yPos = i + rock.yPos;
          values.elementAt(yPos)[xPos] = val;
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
    print('Starting new rock at pos: ${rock.yPos}');
    setRockInMotion(rock);
  }

  void setRockInMotion(Rock rock) {
    setRockPostionsToValue(rock, '@');
  }

  void setRockStopped(Rock rock) {
    setRockPostionsToValue(rock, '#');
    int newHighest = rock.yPos + rock.height();
    if (newHighest > highestRockInRoom) {
      highestRockInRoom = newHighest;
    }
    print('setting highestRockInRoom to $highestRockInRoom');
  }

  void removeRock(Rock rock) {
    setRockPostionsToValue(rock, '.');
  }

  void moveToSide(Rock rock, bool moveRight) {
    // first remove the shape so that it doesn't interfere for itself
    removeRock(rock);

    // then move the rock if we can
    if (canShiftRockToSide(rock, moveRight)) {
      rock.xPos = rock.xPos + (moveRight ? 1 : -1);
    }

    // either way set it back to in motion
    setRockInMotion(rock);
  }

  bool moveDown(Rock rock) {
    // first remove the shape so that it doesn't interfere for itself
    removeRock(rock);

    // then move the rock if we can
    bool moved = false;
    if (canShiftRockDown(rock)) {
      rock.yPos = rock.yPos - 1;
      moved = true;
    }

    // either way set it back to in motion
    setRockInMotion(rock);
    return moved;
  }

  bool canShiftRockToSide(Rock rock, bool moveRight) {
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

  bool canShiftRockDown(Rock rock) {
    for (int i = 0; i < rock.height(); i++) {
      for (int j = 0; j < rock.width(); j++) {
        // shift to the new coord
        int newI = i - 1;

        if (rock.shape[i][j]) {
          int xPos = j + rock.xPos;
          int yPos = newI + rock.yPos;
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
    return values.elementAt(i)[j] == '.';
  }

  void printBoard() {
    for (int i = boardWindowHeight - 1; i >= 0; i--) {
      final row = values.elementAt(i);
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
  print('init');
  board.init(7, boardWindowHeight);
  print('init done');
  // board.printBoard();

  // start dropping pieces
  Rock currentRock = getNextRock('[');
  board.startNewRock(currentRock);
  int numStopped = 0;
  int directionIndex = 0;
  while (true) {
    // If the end of the list is reached, it repeats.
    if (directionIndex >= directionsIsRight.length) {
      directionIndex = 0;
    }
    final directionIsRight = directionsIsRight[directionIndex];
    directionIndex++;

    // it alternates between being pushed by a jet of hot gas one unit (in the
    // direction indicated by the next symbol in the jet pattern) and then
    // falling one unit down.
    board.moveToSide(currentRock, directionIsRight);
    if (!board.moveDown(currentRock)) {
      print('Setting rock stopped: $currentRock');
      board.setRockStopped(currentRock);
      numStopped++;
      if (numStopped == numPieces) {
        break;
      }

      // get the next rock
      currentRock = getNextRock(currentRock.key);
      board.startNewRock(currentRock);
      //board.printBoard();
    }
  }
  print(board.highestRockInRoom);
}

/*
  '-': '+',
  '+': 'l',
  'l': '|',
  '|': '[',
  '[': '-'
*/
Rock getNextRock(String currentRockKey) {
  final next = nextRock[currentRockKey];
  return next!.copy();
}
