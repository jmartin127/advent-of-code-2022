import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

Future<void> main() async {
  test('Test int matrix creation', () {
    final matrix = ('data/int-matrix.txt');
    expect(matrix.length, 5);
  });
}
