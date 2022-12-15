import 'dart:math';

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
  int yRef = 10; // TODO change to test
  // int yRef = 2000000; // TODO change to test
  int xBuffer = 20000000;
  int xStart = -1 * xBuffer;
  int xEnd = xBuffer;
  Line refLine = Line(Point(xStart, yRef), Point(xEnd, yRef));

  // find lines that intersect the line
  List<Line> intersectingLines = [];
  for (final line in lines) {
    if (linesIntersect(line, refLine)) {
      intersectingLines.add(line);
    }
  }
  for (final line in intersectingLines) {
    print(line);
  }

  // alternate way to find intersecting lines since y is fixed
  for (final line in lines) {
    if (line.sensor.y <= yRef && line.beacon.y >= yRef ||
        line.sensor.y >= yRef && line.beacon.y <= yRef) {
      print('Intersecing line: $line');
    }
  }
  print('Next step... finding intersecting points');

  // find how many points intersect with other lines
  Map<int, bool> intersectingPoints = {};
  for (final line in lines) {
    print('LINE: $line');

    // // find the point where the line intersects the ref line
    // int xCoord = 0;
    // if (slopeIsUndefined(line.sensor, line.beacon)) {
    //   print('Vertical line: $line');
    //   xCoord = line.sensor.x; // pick either x, it is a vertical line
    // } else {
    //   double m = findSlope(line.sensor, line.beacon);
    //   double b = solveForYIntercept(line.sensor.y, line.sensor.x, m);
    //   xCoord = findXCoord(yRef, b, m);
    // }

    // print('X COORD: $xCoord');
    // Point intersectionPoint = Point(xCoord, yRef);

    // compute the distance of the sensor to line intersection point
    int lineLen = euclideanDistance(line.sensor, line.beacon);
    // print(
    //     '**** LINE len: $lineLen, from ${line.sensor}, to $intersectionPoint');
    for (int x = xStart; x < xEnd; x++) {
      final refPoint = Point(x, yRef);
      // compute the length from the ref point to the sensor
      int refLen = euclideanDistance(refPoint, line.sensor);
      if (refLen <= lineLen) {
        intersectingPoints[x] = true;
      }
    }
  }

  // incorrect 1432197
  // incorrect 5147404
  print(intersectingPoints.keys.length - 1); // subtract beacon on the line
  for (final key in intersectingPoints.keys) {
    print('Key: $key');
  }
}

int findXCoord(int y, double b, double m) {
  print('Finding x coord: y: $y, b: $b, m: $m');
  return ((y - b) / m).toInt();
}

double solveForYIntercept(int y, int x, double m) {
  return y - (m * x);
}

bool slopeIsUndefined(Point one, Point two) {
  return two.x - one.x == 0;
}

double findSlope(Point one, Point two) {
  print('Finding slope of $one and $two');
  print('\tfirst: ${two.y - one.y}');
  print('\tsecond: ${two.x - one.x}');
  return ((two.y - one.y) / (two.x - one.x));
}

int euclideanDistance(Point one, Point two) {
  return sqrt(
          (two.x - one.x) * (two.x - one.x) + (two.y - one.y) * (two.y - one.y))
      .toInt();
}

bool linesIntersect(Line one, Line two) {
  return doIntersect(one.sensor, one.beacon, two.sensor, two.beacon);
}

// see: https://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/
bool doIntersect(Point p1, Point q1, Point p2, Point q2) {
  // Find the four orientations needed for general and
  // special cases
  int o1 = orientation(p1, q1, p2);
  int o2 = orientation(p1, q1, q2);
  int o3 = orientation(p2, q2, p1);
  int o4 = orientation(p2, q2, q1);

  // General case
  if (o1 != o2 && o3 != o4) return true;

  // Special Cases
  // p1, q1 and p2 are collinear and p2 lies on segment p1q1
  if (o1 == 0 && onSegment(p1, p2, q1)) return true;

  // p1, q1 and q2 are collinear and q2 lies on segment p1q1
  if (o2 == 0 && onSegment(p1, q2, q1)) return true;

  // p2, q2 and p1 are collinear and p1 lies on segment p2q2
  if (o3 == 0 && onSegment(p2, p1, q2)) return true;

  // p2, q2 and q1 are collinear and q1 lies on segment p2q2
  if (o4 == 0 && onSegment(p2, q1, q2)) return true;

  return false; // Doesn't fall in any of the above cases
}

int orientation(Point p, Point q, Point r) {
  // See https://www.geeksforgeeks.org/orientation-3-ordered-points/
  // for details of below formula.
  int val = (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y);

  if (val == 0) return 0; // collinear

  return (val > 0) ? 1 : 2; // clock or counterclock wise
}

// Given three collinear points p, q, r, the function checks if
// point q lies on line segment 'pr'
bool onSegment(Point p, Point q, Point r) {
  if (q.x <= max(p.x, r.x) &&
      q.x >= min(p.x, r.x) &&
      q.y <= max(p.y, r.y) &&
      q.y >= min(p.y, r.y)) {
    return true;
  }

  return false;
}
