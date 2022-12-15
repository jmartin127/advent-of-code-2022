import 'dart:io';

import 'dart:math';

class Point {
  int x;
  int y;
  Point(this.x, this.y);
}

class Line {
  Point start;
  Point end;
  Line(this.start, this.end);
}

class Util {
  static Future<List<String>> readFileAsStrings(String filepath) async {
    final file = File(filepath);
    return file.readAsLinesSync();
  }

  static Future<List<int>> readFileAsInts(String filepath) async {
    final vals = await readFileAsStrings(filepath);
    List<int> result = [];
    for (final val in vals) {
      result.add(int.parse(val));
    }
    return result;
  }

  /*
    92  3 88 13 50
    90 70 24 28 52
    15 98 10 26  5
    84 34 37 73 87
    25 36 74 33 63
  */
  static Future<List<List<int>>> readIntMatrix(String filepath) async {
    final lines = await readFileAsStrings(filepath);
    List<List<int>> result = [];
    for (final line in lines) {
      final parts = line.split('');
      List<int> row = [];
      for (final part in parts) {
        if (part.isEmpty) {
          continue;
        }
        row.add(int.parse(part));
      }
      result.add(row);
    }
    return result;
  }

// My goodness, the issue I had was that I was using eucliden distance instead of manhattan distance
// none of the below is needed, but may be helpful later

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

// WHY did I use the wrong distance formula?
  int euclideanDistance(Point one, Point two) {
    return sqrt((two.x - one.x) * (two.x - one.x) +
            (two.y - one.y) * (two.y - one.y))
        .toInt();
  }

  bool linesIntersect(Line one, Line two) {
    return doIntersect(one.start, one.end, two.start, two.end);
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
}
