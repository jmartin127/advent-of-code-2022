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

  // define the line at y=10
  // int yRef = 10; // TODO change to test
  int yRef = 2000000; // TODO change to test
  int xBuffer = 10000000;
  int xStart = -1 * xBuffer;
  int xEnd = xBuffer;
  //Line refLine = Line(Point(xStart, yRef), Point(xEnd, yRef));

  int count = 0;
  for (int x = xStart; x < xEnd; x++) {
    final refPoint = Point(x, yRef);
    for (final line in lines) {
      // calculate the distance of the sensor from the beacon
      final lineDist = manhattanDistance(line.sensor, line.beacon);

      // calculate the distance from the ref point to the sensor
      final refDist = manhattanDistance(refPoint, line.sensor);
      if (refDist <= lineDist) {
        count++;
        break;
      }
    }
  }

  print('Answer: ${count - 1}'); // subtract beacon
}

int manhattanDistance(Point one, Point two) {
  return absolute(one.x, two.x) + absolute(one.y, two.y);
}
