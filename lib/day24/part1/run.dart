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

class PointInTime {
  Point point;
  int minute;

  PointInTime(this.point, this.minute);

  @override
  String toString() {
    return 'Point: $point, Minute: $minute';
  }

  PointInTime oneMinuteLater() {
    return PointInTime(point.copy(), minute + 1);
  }

  PointInTime oneMinuteLaterRight() {
    return PointInTime(Point(point.x + 1, point.y), minute + 1);
  }

  PointInTime oneMinuteLaterLeft() {
    return PointInTime(Point(point.x - 1, point.y), minute + 1);
  }

  PointInTime oneMinuteLaterUp() {
    return PointInTime(Point(point.x, point.y - 1), minute + 1);
  }

  PointInTime oneMinuteLaterDown() {
    return PointInTime(Point(point.x, point.y + 1), minute + 1);
  }

  @override
  bool operator ==(other) =>
      other is PointInTime && point == other.point && minute == other.minute;

  @override
  int get hashCode => hash2(point, minute);

  bool matchesPoint(Point otherPoint) {
    return point == otherPoint;
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

  // store a mapping of the blizzards at every point in time, up to an arbitrary
  // number of minutes, since that is independent of the expedition
  print('Generating input blizzards');
  Map<int, Map<Point, List<Blizzard>>> blizzardsByMinute = {};
  for (int minute = 0; minute < 10000; minute++) {
    blizzardsByMinute[minute] = basin.copyBlizzardsByPos();
    basin.moveBlizzards();
  }
  print('Done generating');

  // convet the mapping to a point-in-time mapping
  print('Formatting blizzards');
  Map<PointInTime, List<Blizzard>> blizzardsAtPointInTime = {};
  for (final entry in blizzardsByMinute.entries) {
    final minute = entry.key;
    final blizzardsByPoint = entry.value;
    for (final innerEntry in blizzardsByPoint.entries) {
      final point = innerEntry.key;
      final blizzards = innerEntry.value;
      final pointInTime = PointInTime(point, minute);
      blizzardsAtPointInTime[pointInTime] = blizzards;
    }
  }
  print('Done formatting');

  // find the solution
  print('Running BFS...');
  final startPos = PointInTime(basin.startPosition, 0);
  final answer = runBreadthFirstSearch(basin, startPos, blizzardsAtPointInTime);
  print('Done running BFS');
  print(answer);
}

PointInTime? runBreadthFirstSearch(Basin basin, PointInTime startPos,
    Map<PointInTime, List<Blizzard>> blizzardsAtPointInTime) {
  Set<int> minutesTracked = {};
  Set<PointInTime> visited = {};

  // let Q be a queue
  final queue = Queue<PointInTime>();

  // label root as explored
  visited.add(startPos);

  // Q.enqueue(root)
  queue.addFirst(startPos);

  // while Q is not empty do
  while (queue.isNotEmpty) {
    // v := Q.dequeue()
    final v = queue.removeLast(); // tested that this acts as a FIFO
    // if v is the goal then return v
    if (v.matchesPoint(basin.endPosition)) {
      return v;
    }

    if (!minutesTracked.contains(v.minute)) {
      minutesTracked.add(v.minute);
      print('\tBFS at minute: ${v.minute}');
    }

    // check which other points can be reached from v at the next point in time
    final possibleDestinations =
        findValidNextPositions(blizzardsAtPointInTime, v, basin);
    // for all edges from v to w in G.adjacentEdges(v) do
    for (final w in possibleDestinations) {
      // if w is not labeled as explored then
      if (!visited.contains(w)) {
        // label w as explored
        visited.add(w);
        // if we cared about the path we could also set: w.parent = v;
        // Q.enqueue(w)
        queue.addFirst(w);
      }
    }
  }

  print('Unable to find solution using BFS');
  return null;
}

List<PointInTime> findValidNextPositions(
    Map<PointInTime, List<Blizzard>> blizzardsAtPointInTime,
    PointInTime pos,
    Basin basin) {
  // NOTE: need to include current position, if we are going to wait where we are
  //       but in including the current position, it would be incrementing the
  //       minte by one.
  List<PointInTime> possibleNextMoves = [
    pos.oneMinuteLater(),
    pos.oneMinuteLaterUp(),
    pos.oneMinuteLaterDown(),
    pos.oneMinuteLaterLeft(),
    pos.oneMinuteLaterRight()
  ];

  // filter out points that will have a blizzard at that time, or that are off
  // of the board
  List<PointInTime> validNextMoves = [];
  for (final possibleNextMove in possibleNextMoves) {
    if (isValidMove(possibleNextMove, blizzardsAtPointInTime, basin)) {
      validNextMoves.add(possibleNextMove);
    }
  }

  return validNextMoves;
}

bool isValidMove(PointInTime pointInTime,
    Map<PointInTime, List<Blizzard>> blizzardsAtPointInTime, Basin basin) {
  if (pointInTime.matchesPoint(basin.startPosition)) {
    return true;
  }

  if (pointInTime.matchesPoint(basin.endPosition)) {
    return true;
  }

  // no blizzard and still in basin
  return (!blizzardsAtPointInTime.containsKey(pointInTime) &&
      basin.isWithinBasin(pointInTime.point));
}
