import '../../src/util.dart';

Future<void> main() async {
  final matrix = await Util.readIntMatrix('input.txt');

  int count = 0;
  for (int i = 1; i < matrix.length - 1; i++) {
    for (int j = 1; j < matrix.length - 1; j++) {
      final val = matrix[i][j];

      // left
      var isVisible = true;
      for (int k = j - 1; k >= 0; k--) {
        final other = matrix[i][k];
        if (other >= val) {
          isVisible = false;
          break;
        }
      }
      if (isVisible) {
        count++;
        continue;
      }

      // right
      isVisible = true;
      for (int k = j + 1; k < matrix.length; k++) {
        final other = matrix[i][k];
        if (other >= val) {
          isVisible = false;
          break;
        }
      }
      if (isVisible) {
        count++;
        continue;
      }

      // up
      isVisible = true;
      for (int k = i - 1; k >= 0; k--) {
        final other = matrix[k][j];
        if (other >= val) {
          isVisible = false;
          break;
        }
      }
      if (isVisible) {
        count++;
        continue;
      }

      // down
      isVisible = true;
      for (int k = i + 1; k < matrix.length; k++) {
        final other = matrix[k][j];
        if (other >= val) {
          isVisible = false;
          break;
        }
      }
      if (isVisible) {
        count++;
        continue;
      }
    }
  }

  // num outside
  final total = matrix.length * matrix.length;
  final inner = (matrix.length - 2) * (matrix.length - 2);
  final toAdd = total - inner;
  count += toAdd;
  print(count);
}
