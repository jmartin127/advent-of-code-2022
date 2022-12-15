import 'package:aoc/day9/part2/run.dart';

import '../../src/util.dart';

class Point {
  int x;
  int y;
  Point(this.x, this.y);

  @override
  String toString() {
    return 'x: $x, y: $y';
  }
}

class Line {
  Point sensor;
  Point beacon;
  Line(this.sensor, this.beacon);

  @override
  String toString() {
    return '$sensor --> $beacon';
  }
}

Future<void> main() async {
  final input = await Util.readFileAsStrings('input.txt');

  List<Line> lines = [];
  for (var line in input) {
    // Sensor at x=2, y=18: closest beacon is at x=-2, y=15
    line = line.replaceAll(',', '');
    line = line.replaceAll('=', ' ');
    line = line.replaceAll(':', '');
    final lineParts = line.split(' ');
    final sensor = Point(int.parse(lineParts[3]), int.parse(lineParts[5]));
    final beacon = Point(int.parse(lineParts[11]), int.parse(lineParts[13]));
    final newLine = Line(sensor, beacon);
    lines.add(newLine);
  }

  // int searchArea = 20; // TODO change for smaller set
  int searchArea = 4000000;

  // Strategy:
  // 1. Find all the points that are 1 distance outside of each shape formed
  //    by the outline of the beacon
  // 2. These points now form our possible search area, if they are also within
  //    The original search area, but that can be checked when adding to the
  //    list of possible points.
  // 3. Then we check each reference point to see if it is within each of the
  //    sensor areas, only one will NOT be in one of them.
  List<Point> possiblePoints = [];
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    print('processing line $i');
    final refPoints = findAllPointsJustOutsideSensor(line, searchArea);
    possiblePoints.addAll(refPoints);
  }
  print('Total num possible: ${possiblePoints.length}');

  for (final refPoint in possiblePoints) {
    bool foundRefPoint = false;
    for (final line in lines) {
      // calculate the distance of the sensor from the beacon
      final lineDist = manhattanDistance(line.sensor, line.beacon);

      // calculate the distance from the ref point to the sensor
      final refDist = manhattanDistance(refPoint, line.sensor);
      if (refDist <= lineDist) {
        foundRefPoint = true;
        break;
      }
    }

    // To isolate the distress beacon's signal, you need to determine its tuning
    // frequency, which can be found by multiplying its x coordinate by 4000000
    // and then adding its y coordinate.
    if (!foundRefPoint) {
      print('Found $refPoint');
      print(refPoint.x * 4000000 + refPoint.y);
      break;
    }
  }
}

List<Point> findAllPointsJustOutsideSensor(Line line, int maxSearch) {
  final dist = manhattanDistance(line.sensor, line.beacon);
  final sensor = line.sensor;

  // mark each corner that is just the top/bottom/left/right of the diamond shape
  final topRefPoint = Point(sensor.x, sensor.y - (dist + 1));
  final bottomRefPoint = Point(sensor.x, sensor.y + (dist + 1));
  final leftRefPoint = Point(sensor.x - (dist + 1), sensor.y);
  final rightRefPoint = Point(sensor.x + (dist + 1), sensor.y);

  // possible points where missing beacon could be
  List<Point> refPoints = [];

  // upper-right diagnoal (go down and right, i larger, j larger)
  for (int i = topRefPoint.x; i <= rightRefPoint.x; i) {
    for (int j = topRefPoint.y; j <= rightRefPoint.y; j) {
      i++;
      j++;
      final refPoint = Point(i, j);
      if (isInSearchArea(refPoint, maxSearch)) {
        refPoints.add(refPoint);
      }
    }
  }

  // lower-right diagonal (go down and left, i smaller, j larger)
  for (int i = rightRefPoint.x; i >= bottomRefPoint.x; i) {
    for (int j = rightRefPoint.y; j <= bottomRefPoint.y; j) {
      i--;
      j++;
      final refPoint = Point(i, j);
      if (isInSearchArea(refPoint, maxSearch)) {
        refPoints.add(refPoint);
      }
    }
  }

  // lower-left diagonal (go up and left, i smaller, j smaller)
  for (int i = bottomRefPoint.x; i >= leftRefPoint.x; i) {
    for (int j = bottomRefPoint.y; j >= leftRefPoint.y; j) {
      i--;
      j--;
      final refPoint = Point(i, j);
      if (isInSearchArea(refPoint, maxSearch)) {
        refPoints.add(refPoint);
      }
    }
  }

  // upper-left diagonal (go up and right, i larger, j smaller)
  for (int i = leftRefPoint.x; i <= topRefPoint.x; i) {
    for (int j = leftRefPoint.y; j >= topRefPoint.y; j) {
      i++;
      j--;
      final refPoint = Point(i, j);
      if (isInSearchArea(refPoint, maxSearch)) {
        refPoints.add(refPoint);
      }
    }
  }

  return refPoints;
}

bool isInSearchArea(Point point, int maxSearch) {
  return point.x >= 0 &&
      point.x <= maxSearch &&
      point.y >= 0 &&
      point.y <= maxSearch;
}

int manhattanDistance(Point one, Point two) {
  return absolute(one.x, two.x) + absolute(one.y, two.y);
}
