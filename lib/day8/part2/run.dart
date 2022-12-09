import '../../src/util.dart';

Future<void> main() async {
  final matrix = await Util.readIntMatrix('input.txt');

  int maxScore = -1;
  for (int i = 1; i < matrix.length - 1; i++) {
    for (int j = 1; j < matrix.length - 1; j++) {
      final val = matrix[i][j];

      // left
      var leftScore = 0;
      for (int k = j - 1; k >= 0; k--) {
        final other = matrix[i][k];
        leftScore++;
        if (other >= val) {
          break;
        }
      }

      // right
      var rightScore = 0;
      for (int k = j + 1; k < matrix.length; k++) {
        final other = matrix[i][k];
        rightScore++;
        if (other >= val) {
          break;
        }
      }

      // up
      var upScore = 0;
      for (int k = i - 1; k >= 0; k--) {
        final other = matrix[k][j];
        upScore++;
        if (other >= val) {
          break;
        }
      }

      // down
      var downScore = 0;
      for (int k = i + 1; k < matrix.length; k++) {
        final other = matrix[k][j];
        downScore++;
        if (other >= val) {
          break;
        }
      }
      final scenicScore = leftScore * rightScore * upScore * downScore;
      if (scenicScore > maxScore) {
        maxScore = scenicScore;
      }
    }
  }
  print(maxScore);
}
