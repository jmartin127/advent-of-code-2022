import 'dart:io';

import '../../src/util.dart';

class Point {
  int x;
  int y;
  Point(this.x, this.y);
}

class Line {
  Point from;
  Point to;
  Line(this.from, this.to);
}

Future<void> main() async {
  final input = await Util.readFileAsStrings('input.txt');

  // Read in all of the lines
  // x,y
  // 498,4 -> 498,6 -> 496,6
  int maxY = 0;
  int maxX = 0;
  int minX = 1000000000;
  List<Line> lines = [];
  for (final line in input) {
    final lineParts = line.split(' -> ');
    for (int i = 0; i < lineParts.length - 1; i++) {
      final start = lineParts[i];
      final end = lineParts[i + 1];
      final startCoords = start.split(',');
      final endCoords = end.split(',');
      final startPoint =
          Point(int.parse(startCoords[0]), int.parse(startCoords[1]));
      final endPoint = Point(int.parse(endCoords[0]), int.parse(endCoords[1]));
      final lineObj = Line(startPoint, endPoint);
      lines.add(lineObj);
      if (startPoint.y > maxY) {
        maxY = startPoint.y;
      }
      if (endPoint.y > maxY) {
        maxY = endPoint.y;
      }
      if (startPoint.x > maxX) {
        maxX = startPoint.x;
      }
      if (endPoint.x > maxX) {
        maxX = endPoint.x;
      }

      if (startPoint.x < minX) {
        minX = startPoint.x;
      }
      if (endPoint.x < minX) {
        minX = endPoint.x;
      }
    }
  }
  int xBuffer = 1000; // allow for infinite growth
  maxY += 2;
  minX -= xBuffer;
  maxX += xBuffer;

  // Initialize the matrix
  List<List<String>> matrix = [];
  final width = maxX - minX + 1;
  final length = maxY + 1;
  for (int i = 0; i < length; i++) {
    List<String> row = [];
    for (int j = 0; j < width; j++) {
      row.add('.');
    }
    matrix.add(row);
  }

  // Add the floor
  Line floor = Line(Point(minX, maxY), Point(maxX, maxY));
  lines.add(floor);

  // Add the lines
  for (final line in lines) {
    if (line.from.x == line.to.x) {
      // vertical line (x's are the same)
      final yBegin = line.from.y < line.to.y ? line.from.y : line.to.y;
      final yEnd = line.from.y > line.to.y ? line.from.y : line.to.y;
      final xCoord = convertXCoordToMatrixCoord(line.from.x, minX);
      for (int y = yBegin; y <= yEnd; y++) {
        matrix[y][xCoord] = '#';
      }
    } else {
      // horizontal line (y's are the same)
      final xBegin = line.from.x < line.to.x ? line.from.x : line.to.x;
      final xEnd = line.from.x > line.to.x ? line.from.x : line.to.x;
      final yCoord = line.from.y;
      final xBeginCoord = convertXCoordToMatrixCoord(xBegin, minX);
      final xEndCoord = convertXCoordToMatrixCoord(xEnd, minX);
      for (int x = xBeginCoord; x <= xEndCoord; x++) {
        matrix[yCoord][x] = '#';
      }
    }
  }

  // Add the start of the sand
  matrix[0][convertXCoordToMatrixCoord(500, minX)] = '.';

  // Start dropping sand pellets
  int numSandDropped = 0;
  while (true) {
    final sand = Point(convertXCoordToMatrixCoord(500, minX), 0);
    numSandDropped++;
    moveSandUntilRest(matrix, sand);
    // check for the condition right before last piece of sand
    if (matrix[1][convertXCoordToMatrixCoord(500, minX)] == 'o' &&
        matrix[1][convertXCoordToMatrixCoord(499, minX)] == 'o' &&
        matrix[1][convertXCoordToMatrixCoord(501, minX)] == 'o') {
      break;
    }
  }

  // add one since we are checking the condition just before the last sand
  print(numSandDropped + 1);
}

Point? moveSandUntilRest(List<List<String>> matrix, Point sand) {
  Point? currentSand = sand;
  while (true) {
    currentSand = moveSandIfPossible(matrix, currentSand!);
    if (currentSand == null) {
      // sand came to rest
      break;
    }
  }
  return currentSand;
}

Point? moveSandIfPossible(List<List<String>> matrix, Point sand) {
  // A unit of sand always falls down one step if possible.
  final charOneDown = matrix[sand.y + 1][sand.x];
  if (charOneDown == '.') {
    matrix[sand.y][sand.x] = '.';
    matrix[sand.y + 1][sand.x] = 'o';
    return Point(sand.x, sand.y + 1);
  }

  // If the tile immediately below is blocked (by rock or sand), the unit of
  // sand attempts to instead move diagonally one step down and to the left.
  final charLeftDiag = matrix[sand.y + 1][sand.x - 1];
  if (charLeftDiag == '.') {
    matrix[sand.y][sand.x] = '.';
    matrix[sand.y + 1][sand.x - 1] = 'o';
    return Point(sand.x - 1, sand.y + 1);
  }

  // If that tile is blocked, the unit of sand attempts to instead move
  // diagonally one step down and to the right.
  final charRightDiag = matrix[sand.y + 1][sand.x + 1];
  if (charRightDiag == '.') {
    matrix[sand.y][sand.x] = '.';
    matrix[sand.y + 1][sand.x + 1] = 'o';
    return Point(sand.x + 1, sand.y + 1);
  }

  // If all three possible destinations are blocked, the unit of sand comes to
  // rest and no longer moves
  return null;
}

void printMatrix(List<List<String>> matrix) {
  for (int i = 0; i < matrix.length; i++) {
    final row = matrix[i];
    for (int j = 0; j < row.length; j++) {
      stdout.write(matrix[i][j]);
    }
    print('');
  }
}

int convertXCoordToMatrixCoord(int xCoord, int minX) {
  return xCoord - minX;
}
