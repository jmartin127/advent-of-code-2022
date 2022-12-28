import 'dart:io';

import 'package:quiver/core.dart';

import '../../src/util.dart';

enum Facing {
  left,
  right,
  up,
  down,
}

class Point {
  int x;
  int y;

  Point(this.x, this.y);

  @override
  bool operator ==(other) => other is Point && x == other.x && y == other.y;

  @override
  int get hashCode => hash2(x, y);

  @override
  String toString() {
    return 'x: $x, y: $y';
  }
}

class Blizzard {
  Point currentLocation;
  Facing facing;

  Blizzard(this.currentLocation, this.facing);

  void moveToLocation(Point point) {
    currentLocation.x = point.x;
    currentLocation.y = point.y;
  }

  Point nextLocation() {
    switch (facing) {
      case Facing.left:
        return Point(currentLocation.x - 1, currentLocation.y);
      case Facing.right:
        return Point(currentLocation.x + 1, currentLocation.y);
      case Facing.up:
        return Point(currentLocation.x, currentLocation.y - 1);
      case Facing.down:
        return Point(currentLocation.x, currentLocation.y + 1);
    }
  }

  static Blizzard parseBlizzard(int x, int y, String facingDir) {
    final loc = Point(x, y);
    Facing face;
    switch (facingDir) {
      case '>':
        face = Facing.right;
        break;
      case '<':
        face = Facing.left;
        break;
      case 'v':
        face = Facing.down;
        break;
      case '^':
        face = Facing.up;
        break;
      default:
        throw Exception('Unable to parse blizzard direction from $facingDir');
    }
    return Blizzard(loc, face);
  }

  String facingAsString() {
    switch (facing) {
      case Facing.left:
        return '<';
      case Facing.right:
        return '>';
      case Facing.up:
        return '^';
      case Facing.down:
        return 'v';
    }
  }
}

class Basin {
  List<List<String>> values = [];
  Map<Point, List<Blizzard>> blizzardsByPosition = {};
  late Point startPosition;
  late Point endPosition;
  late Point expeditionPos;

  /*
    #.######
    #>>.<^<#
    #.<..<<#
    #>v.><>#
    #<^v^^>#
    ######.#
  */
  Basin(List<String> input) {
    for (int i = 0; i < input.length; i++) {
      final line = input[i];
      List<String> row = [];
      final chars = line.split('');
      for (int j = 0; j < chars.length; j++) {
        final char = chars[j];
        row.add(char == '#' ? char : '.');
        if (char != '#' && char != '.') {
          final newBlizzard = Blizzard.parseBlizzard(j, i, char);
          final currentPos = Point(j, i);
          if (blizzardsByPosition.containsKey(currentPos)) {
            blizzardsByPosition[currentPos]!.add(newBlizzard);
          } else {
            blizzardsByPosition[currentPos] = [newBlizzard];
          }
        }
      }
      values.add(row);
    }

    // Your expedition begins in the only non-wall position in the top row and
    // needs to reach the only non-wall position in the bottom row.
    for (int x = 0; x < values.length; x++) {
      if (values[0][x] == '.') {
        startPosition = Point(x, 0);
      }
    }
    for (int x = 0; x < values[0].length; x++) {
      if (values[values.length - 1][x] == '.') {
        endPosition = Point(x, values.length - 1);
      }
    }
    expeditionPos = Point(startPosition.x, startPosition.y);
  }

  void moveExpedition(Point point) {
    expeditionPos.x = point.x;
    expeditionPos.y = point.y;
  }

  // Due to conservation of blizzard energy, as a blizzard reaches the wall of
  // the valley, a new blizzard forms on the opposite side of the valley moving
  // in the same direction.
  //
  // Because blizzards are made of tiny snowflakes, they pass right through each
  // other.
  void moveBlizzards() {
    Map<Point, List<Blizzard>> newPositions = {};
    for (final entry in blizzardsByPosition.entries) {
      for (final blizzard in entry.value) {
        var newPosition = blizzard.nextLocation();
        if (!isWithinBasin(newPosition)) {
          // hit a wall, wrap
          if (newPosition.x <= 0) {
            newPosition.x = values[0].length - 2;
          } else if (newPosition.x >= values[0].length - 1) {
            newPosition.x = 1;
          } else if (newPosition.y <= 0) {
            newPosition.y = values.length - 2;
          } else if (newPosition.y >= values.length - 1) {
            newPosition.y = 1;
          }
        }
        blizzard.moveToLocation(newPosition);

        // update the map of blizzards
        if (newPositions.containsKey(newPosition)) {
          newPositions[newPosition]!.add(blizzard);
        } else {
          newPositions[newPosition] = [blizzard];
        }
      }
    }
    blizzardsByPosition = newPositions;
  }

  // Note: There is a wall surrounding the whole thing, so need to account for
  //       that
  bool isWithinBasin(Point point) {
    if (point.x <= 0 || point.x >= values[0].length - 1) {
      return false;
    }
    if (point.y <= 0 || point.y >= values.length - 1) {
      return false;
    }

    return true;
  }

  bool isExpeditionAtEnd() {
    return expeditionPos == endPosition;
  }

  bool isEndPosition(Point point) {
    return point == endPosition;
  }

  void printBasin() {
    for (int i = 0; i < values.length; i++) {
      for (int j = 0; j < values[0].length; j++) {
        var char = values[i][j];
        final currentPoint = Point(j, i);
        if (blizzardsByPosition.containsKey(currentPoint)) {
          final blizzards = blizzardsByPosition[currentPoint]!;
          if (blizzards.length > 1) {
            char = '${blizzards.length}';
          } else if (blizzards.length == 1) {
            char = blizzards[0].facingAsString();
          }
        }
        if (expeditionPos == currentPoint) {
          char = 'E';
        }
        stdout.write(char);
      }
      print('');
    }
    print('');
  }
}

Future<void> main() async {
  final input = await Util.readFileAsStrings('input.txt');

  // initialize the basin
  final basin = Basin(input);
  basin.printBasin();
  print('Start: ${basin.startPosition}');
  print('End: ${basin.endPosition}');

  // move until we reach the goal
  for (int i = 0; i < 30; i++) {
    basin.moveBlizzards();

    // figure out where to move the expedition
    moveExpedition(basin);
    print('Expedition is at ${basin.expeditionPos}');

    // print the result
    print('Minute ${i + 1}');
    basin.printBasin();

    // check if we made it
    if (basin.isExpeditionAtEnd()) {
      throw Exception('reached end');
    }
  }
}

void moveExpedition(Basin basin) {
  // determine if we reach the end position first by going left, right, or down
  final vertDist = abs(basin.expeditionPos.y, basin.endPosition.y);
  final horizDist = abs(basin.expeditionPos.x, basin.endPosition.x);
  print('Vert dist: $vertDist');
  print('Hori dist: $horizDist');

  Point? movingToPosition;

  // move down (if can)
  if (vertDist >= horizDist) {
    print('Moving down');
    final newPos = Point(basin.expeditionPos.x, basin.expeditionPos.y + 1);

    if (basin.isEndPosition(newPos) ||
        (!basin.blizzardsByPosition.containsKey(newPos) &&
            basin.isWithinBasin(newPos))) {
      // check for blizzards and going off of the board
      movingToPosition = newPos;
    }
  }

  // move right (if haven't already moved down, and can)
  if (vertDist <= horizDist && movingToPosition == null) {
    print('Moving right');
    final newPos = Point(basin.expeditionPos.x + 1, basin.expeditionPos.y);

    // check for blizzards and going off of the board
    if (basin.isEndPosition(newPos) ||
        (!basin.blizzardsByPosition.containsKey(newPos) &&
            basin.isWithinBasin(newPos))) {
      movingToPosition = newPos;
    }
  }

  // TODO move left and up if can't move closer to the goal

  if (movingToPosition != null) {
    print('Moving expedition to $movingToPosition');
    basin.moveExpedition(movingToPosition);
  }
}

int abs(int a, int b) {
  if (a > b) {
    return a - b;
  }
  return b - a;
}
