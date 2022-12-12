import '../../src/util.dart';

class Point {
  int x;
  int y;
  Point(this.x, this.y);
}

Future<void> main() async {
  final matrix = await Util.readFileAsStrings('input.txt');

  /// Hash all the values in the matrix for eash lookup
  int startId = 0;
  int endId = 0;
  int id = 0;
  Map<String, int> idsByPoint = {};
  for (int i = 0; i < matrix.length; i++) {
    final row = matrix[i];
    for (int j = 0; j < row.length; j++) {
      final val = matrix[i][j];
      id++;
      idsByPoint['$i.$j'] = id;
      if (val == 'S') {
        startId = id;
      } else if (val == 'E') {
        endId = id;
      }
    }
  }

  Map<int, List<int>> validNodeTransitions = {};
  for (int i = 0; i < matrix.length; i++) {
    final row = matrix[i];
    for (int j = 0; j < row.length; j++) {
      // IDs where this node can go to in the graph
      final int nodeId = idsByPoint['$i.$j']!;
      List<int> toIds = [];

      // check left
      if (isValid(matrix, i, j, i, j - 1)) {
        final otherId = idsByPoint['${i}.${j - 1}']!;
        toIds.add(otherId);
      }

      // check right
      if (isValid(matrix, i, j, i, j + 1)) {
        final otherId = idsByPoint['${i}.${j + 1}']!;
        toIds.add(otherId);
      }

      // check up
      if (isValid(matrix, i, j, i - 1, j)) {
        final otherId = idsByPoint['${i - 1}.${j}']!;
        toIds.add(otherId);
      }

      // check down
      if (isValid(matrix, i, j, i + 1, j)) {
        final otherId = idsByPoint['${i + 1}.${j}']!;
        toIds.add(otherId);
      }
      validNodeTransitions[nodeId] = toIds;
      print('Can Transition from $nodeId to $toIds');
    }
  }
}

/// Determines if a given transition is a valid transition in the graph
bool isValid(List<String> matrix, int i, int j, int toI, int toJ) {
  // out of bounds
  if (toI < 0 || toI >= matrix.length) {
    return false;
  }
  if (toJ < 0 || toJ >= matrix[0].length) {
    return false;
  }

  String val = matrix[i][j];
  String toVal = matrix[toI][toJ];

  if (val == 'S' && toVal == 'a') {
    return true;
  }
  if (val == 'z' && toVal == 'E') {
    return true;
  }

  final intVal = val.codeUnitAt(0);
  final intToVal = toVal.codeUnitAt(0);
  if (intVal == intToVal || intToVal - 1 == intVal) {
    return true;
  }

  return false;
}
