import '../../src/dijkstra/dijkstra.dart';
import '../../src/util.dart';

class Point {
  int x;
  int y;
  Point(this.x, this.y);
}

Future<void> main() async {
  final matrix = await Util.readFileAsStrings('input.txt');

  /// Hash all the values in the matrix for easy lookup
  List<int> startIds = [];
  int endId = 0;
  int id = 0;
  Map<String, int> idsByPoint = {};
  for (int i = 0; i < matrix.length; i++) {
    final row = matrix[i];
    for (int j = 0; j < row.length; j++) {
      final val = matrix[i][j];
      id++;
      idsByPoint['$i.$j'] = id;
      if (val == 'a') {
        startIds.add(id);
      } else if (val == 'E') {
        endId = id;
      }
    }
  }

  // Record all valid transitions in the graph
  Map<dynamic, dynamic> validNodeTransitions = {};
  for (int i = 0; i < matrix.length; i++) {
    final row = matrix[i];
    for (int j = 0; j < row.length; j++) {
      // IDs where this node can go to in the graph
      final int nodeId = idsByPoint['$i.$j']!;
      Map<dynamic, dynamic> toIds = {};

      // check up
      if (isValid(matrix, i, j, i - 1, j)) {
        final otherId = idsByPoint['${i - 1}.${j}']!;
        toIds[otherId] = 1;
      }

      // check down
      if (isValid(matrix, i, j, i + 1, j)) {
        final otherId = idsByPoint['${i + 1}.${j}']!;
        toIds[otherId] = 1;
      }

      // check left
      if (isValid(matrix, i, j, i, j - 1)) {
        final otherId = idsByPoint['${i}.${j - 1}']!;
        toIds[otherId] = 1;
      }

      // check right
      if (isValid(matrix, i, j, i, j + 1)) {
        final otherId = idsByPoint['${i}.${j + 1}']!;
        toIds[otherId] = 1;
      }
      validNodeTransitions[nodeId] = toIds;
      print('Can Transition from $nodeId to $toIds');
    }
  }

  // Solve via Dijkstra's
  int min = 1000000;
  for (final startId in startIds) {
    var output2 =
        Dijkstra.findPathFromGraph(validNodeTransitions, startId, endId);
    final answer = output2.length - 1;
    if (answer > 0 && answer < min) {
      min = answer;
    }
  }
  print(min);
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
  if (intVal == intToVal ||
      intToVal - 1 == intVal ||
      (intVal > intToVal && toVal != 'E' && toVal != 'S')) {
    return true;
  }

  return false;
}
