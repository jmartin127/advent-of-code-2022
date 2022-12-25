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
  BigInt? resolvedValue;
  String? leftOperand;
  String? rightOperand;
  Operator? operator;

  Node(this.label, this.resolvedValue, this.isResolved, this.leftOperand,
      this.rightOperand, this.operator);

  @override
  String toString() {
    return '$label, isResolved: $isResolved, resolvedValue: $resolvedValue, leftOperand: $leftOperand, rightOperand: $rightOperand, operator: $operator';
  }

  Node copy() {
    return Node(
        label,
        resolvedValue == null ? null : BigInt.parse(resolvedValue.toString()),
        isResolved,
        leftOperand,
        rightOperand,
        operator);
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
      final resolvedValue = lineParts[1];
      nodesByLabel[label] =
          Node(label, BigInt.parse(resolvedValue), true, null, null, null);
    }
  }

  for (final entry in nodesByLabel.entries) {
    print(entry.value);
  }

  // sanity check
  var nodesCopy = copyMap(nodesByLabel);
  var areEqual = numbersPriorToRootAreEqual(nodesCopy, BigInt.parse('1'));
  print(areEqual);

  // trying to match
  int numToMatch = 116154256834924;

  int min = 3000000000000;
  int max = 4000000000000;

  // binary search to narrow in on the answer
  // while (true) {
  //   print('min: $min');
  //   print('max: $max');
  //   int numToTry = ((max + min) / 2).toInt();
  //   nodesCopy = copyMap(nodesByLabel);
  //   final currentVal =
  //       numbersPriorToRootAreEqual(nodesCopy, BigInt.from(numToTry));
  //   print(currentVal);
  //   final currentValInt = currentVal.toInt();
  //   if (currentValInt > numToMatch) {
  //     min = numToTry;
  //   } else {
  //     max = numToTry;
  //   }
  // }

  for (int i = 3678125408016 - 100; i < 3678125408016 + 1000; i++) {
    nodesCopy = copyMap(nodesByLabel);
    final currentVal = numbersPriorToRootAreEqual(nodesCopy, BigInt.from(i));
    print('CURR: $currentVal');
    if (currentVal.toInt() == 116154256834924) {
      throw Exception('worked! for $i');
    }
  }
}

BigInt numbersPriorToRootAreEqual(
    Map<String, Node> nodesByLabel, BigInt numForHuman) {
  final root = nodesByLabel['root']!;
  final humnNode = nodesByLabel['humn']!;
  humnNode.resolvedValue = numForHuman;
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
  }
  final rootLeftNode = nodesByLabel[root.leftOperand!]!;
  final rootRightNode = nodesByLabel[root.rightOperand!]!;

  // print('Left : ${rootLeftNode.resolvedValue}');
  // print('Right: ${rootRightNode.resolvedValue}');
  return rootLeftNode.resolvedValue!;
}

Map<String, Node> copyMap(Map<String, Node> nodesByLabel) {
  Map<String, Node> copy = {};
  for (final entry in nodesByLabel.entries) {
    copy[entry.key] = entry.value.copy();
  }
  return copy;
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

BigInt performCalculation(BigInt left, BigInt right, Operator op) {
  if (op == Operator.addition) {
    return left + right;
  } else if (op == Operator.subtraction) {
    return left - right;
  } else if (op == Operator.multiplication) {
    return left * right;
  } else if (op == Operator.division) {
    return BigInt.from(left / right);
  }
  throw Exception('not possible');
}
