import '../../src/util.dart';

enum Operator {
  addition,
  subtraction,
  multiplication,
  division,
}

class Node {
  String label;
  bool isResolved;
  int? resolvedValue;
  String? leftOperand;
  String? rightOperand;
  Operator? operator;

  Node(this.label, this.resolvedValue, this.isResolved, this.leftOperand,
      this.rightOperand, this.operator);

  @override
  String toString() {
    return '$label, isResolved: $isResolved, resolvedValue: $resolvedValue, leftOperand: $leftOperand, rightOperand: $rightOperand, operator: $operator';
  }
}

Future<void> main() async {
  final lines = await Util.readFileAsStrings('input.txt');
  print('${lines.length}');

  Map<String, Node> nodesByLabel = {};
  for (final line in lines) {
    final lineParts = line.split(': ');
    final label = lineParts[0];
    if (lineParts[1].contains(' ')) {
      // root: pppw + sjmn
      final operands = lineParts[1].split(' ');
      final leftOperand = operands[0];
      final op = operands[1];
      final rightOperand = operands[2];

      Operator? theOperator;
      if (op == '+') {
        theOperator = Operator.addition;
      } else if (op == '-') {
        theOperator = Operator.subtraction;
      } else if (op == '*') {
        theOperator = Operator.multiplication;
      } else if (op == '/') {
        theOperator = Operator.division;
      }
      nodesByLabel[label] =
          Node(label, null, false, leftOperand, rightOperand, theOperator);
    } else {
      // this means it must be resolved already (e.g., dbpl: 5)
      final resolvedValue = int.parse(lineParts[1]);
      nodesByLabel[label] = Node(label, resolvedValue, true, null, null, null);
    }
  }

  for (final entry in nodesByLabel.entries) {
    print(entry.value);
  }

  // loop through the map until we can resolve all values
  final root = nodesByLabel['root']!;
  while (!root.isResolved) {
    for (final entry in nodesByLabel.entries) {
      final node = entry.value;
      if (node.isResolved) {
        continue;
      }

      final leftOp = node.leftOperand;
      final rightOp = node.rightOperand;
      final leftNode = nodesByLabel[leftOp]!;
      final rightNode = nodesByLabel[rightOp]!;
      if (leftNode.isResolved && rightNode.isResolved) {
        final computedValue = performCalculation(
            leftNode.resolvedValue!, rightNode.resolvedValue!, node.operator!);
        node.isResolved = true;
        node.resolvedValue = computedValue;
      }
    }
    print('Num resolved: ${numResolved(nodesByLabel)}');
  }
  print('Value of root: ${root.resolvedValue}');
}

int numResolved(Map<String, Node> nodesByLabel) {
  int count = 0;
  for (final entry in nodesByLabel.entries) {
    if (entry.value.isResolved) {
      count++;
    }
  }
  return count;
}

int performCalculation(int left, int right, Operator op) {
  if (op == Operator.addition) {
    return left + right;
  } else if (op == Operator.subtraction) {
    return left - right;
  } else if (op == Operator.multiplication) {
    return left * right;
  } else if (op == Operator.division) {
    return (left / right).toInt();
  }
  throw Exception('not possible');
}
