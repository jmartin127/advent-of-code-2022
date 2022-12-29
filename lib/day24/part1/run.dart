import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:quiver/core.dart';

import '../../src/util.dart';

var random = Random();

enum Facing {
  left,
  right,
  up,
  down,
}

class Point {
  int x;
  int y;
  bool explored = false;
  Point? parent;

  Point(this.x, this.y);

  Point copy() {
    return Point(x, y);
  }

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

  Blizzard copy() {
    return Blizzard(currentLocation.copy(), facing);
  }

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

  Basin.empty();

  Basin copy() {
    final newBasin = Basin.empty();
    newBasin.values = copyValues();
    newBasin.blizzardsByPosition = copyBlizzardsByPos();
    newBasin.startPosition = startPosition.copy();
    newBasin.endPosition = endPosition.copy();
    newBasin.expeditionPos = expeditionPos.copy();
    return newBasin;
  }

  List<List<String>> copyValues() {
    List<List<String>> newValues = [];
    for (final row in values) {
      List<String> newRow = [];
      for (final val in row) {
        newRow.add(val);
      }
      newValues.add(newRow);
    }
    return newValues;
  }

  Map<Point, List<Blizzard>> copyBlizzardsByPos() {
    Map<Point, List<Blizzard>> result = {};
    for (final entry in blizzardsByPosition.entries) {
      result[entry.key.copy()] = copyBlizzards(entry.value);
    }
    return result;
  }

  List<Blizzard> copyBlizzards(List<Blizzard> other) {
    List<Blizzard> result = [];
    for (final blizzard in other) {
      result.add(blizzard.copy());
    }
    return result;
  }

  bool isExpeditionInBlizzard() {
    return blizzardsByPosition.containsKey(expeditionPos) &&
        blizzardsByPosition[expeditionPos]!.isNotEmpty;
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

  // var minAnswer = 100000000;
  // for (int i = 0; i < 10; i++) {
  final newBasin = basin.copy();
  final result = runExpeditionOneTime(newBasin);
  newBasin.printBasin();
  //   if (result != -1) {
  //     if (result < minAnswer) {
  //       minAnswer = result;
  //     }
  //   }
  // }
  // print(minAnswer);
}

int runExpeditionOneTime(Basin basin) {
  // move until we reach the goal
  int minute = 0;
  while (true) {
    minute++;
    basin.moveBlizzards();

    // figure out where to move the expedition
    bool succeeded = moveExpedition(basin);
    if (!succeeded) {
      print('Expedition failed');
      // return -1;
    }

    // print the result
    print('Minute $minute');
    basin.printBasin();

    // check if we made it
    if (basin.isExpeditionAtEnd()) {
      print('Expedition has ended at minute $minute');
      return minute;
    }
  }
}

Point? runBreadthFirstSearch(Basin basin, Point startPos, Point endPos) {
  // let Q be a queue
  final queue = Queue<Point>();

  // label root as explored
  startPos.explored = true;

  // Q.enqueue(root)
  queue.addFirst(startPos);

  // while Q is not empty do
  while (queue.isNotEmpty) {
    // v := Q.dequeue()
    final v = queue.removeLast(); // tested that this acts as a FIFO
    // if v is the goal then return v
    if (v == endPos) {
      return v;
    }
    // TODO check which other points can be reached from this point at this
    //      point in time. We should be able to tell what point in time we are
    //      at by checking he number of parents that v has.
    List<Point> possibleDestinations = [];
    // for all edges from v to w in G.adjacentEdges(v) do
    for (final w in possibleDestinations) {
      // if w is not labeled as explored then
      if (!w.explored) {
        // label w as explored
        w.explored = true;
        w.parent = v;
        // Q.enqueue(w)
        queue.addFirst(w);
      }
    }
  }
}

bool shoudlMoveToNewPosition(Basin basin, Point newPos) {
  // reached the end, stop
  if (basin.isEndPosition(newPos)) {
    return true;
  }

  // no blizzard and still in basin
  return (!basin.blizzardsByPosition.containsKey(newPos) &&
      basin.isWithinBasin(newPos));
}

int abs(int a, int b) {
  if (a > b) {
    return a - b;
  }
  return b - a;
}

bool randomlyReturnTrue(double fraction) {
  return random.nextDouble() <= fraction;
}
