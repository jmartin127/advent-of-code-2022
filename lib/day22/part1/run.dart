import 'dart:io';

import '../../src/util.dart';

enum Direction {
  right,
  left,
}

class Instruction {
  bool isDirection;
  int? numTilesToMove;
  Direction? direction;

  Instruction(this.isDirection, this.numTilesToMove, this.direction);

  @override
  String toString() {
    return 'isDirection: $isDirection, numTilesToMove: $numTilesToMove, direction: $direction';
  }
}

class Board {
  List<List<String>> matrix = [];

  Board();

  void printMatrix() {
    for (int i = 0; i < matrix.length; i++) {
      for (int j = 0; j < matrix[i].length; j++) {
        stdout.write(matrix[i][j]);
      }
      print('');
    }
  }
}

Future<void> main() async {
  final lines = await Util.readFileAsStrings('input.txt');

  // find the longest line
  int maxX = 0;
  for (final line in lines) {
    if (line.isEmpty) {
      break;
    }
    if (line.length > maxX) {
      maxX = line.length;
    }
  }
  print('maxX: $maxX');

  Board board = Board();
  List<Instruction> instructions = [];
  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    if (line.isEmpty) {
      instructions = parseInstructions(lines[i + 1]);
      break;
    } else {
      // '        #...'
      final chars = line.split('');
      List<String> row = [];
      for (int x = 0; x < maxX; x++) {
        if (x < chars.length) {
          row.add(chars[x]);
        } else {
          row.add('');
        }
      }
      board.matrix.add(row);
    }
  }
  board.printMatrix();
  for (final instruction in instructions) {
    print(instruction);
  }
}

// 10R5L5R10L4R5L5
List<Instruction> parseInstructions(String input) {
  List<Instruction> instructions = [];
  String currentNum = '';
  for (final char in input.split('')) {
    if (char == 'R') {
      if (currentNum != '') {
        final num = int.parse(currentNum);
        instructions.add(Instruction(false, num, null));
      }
      currentNum = '';
      instructions.add(Instruction(true, null, Direction.right));
    } else if (char == 'L') {
      if (currentNum != '') {
        final num = int.parse(currentNum);
        instructions.add(Instruction(false, num, null));
      }
      currentNum = '';
      instructions.add(Instruction(true, null, Direction.left));
    } else {
      currentNum += char;
    }
  }
  if (currentNum != '') {
    final num = int.parse(currentNum);
    instructions.add(Instruction(false, num, null));
  }
  return instructions;
}
