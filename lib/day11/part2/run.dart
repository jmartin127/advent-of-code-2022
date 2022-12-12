import '../../src/util.dart';

class Monkey {
  List<int> items;
  bool operationIsAdd;
  int? operationAmount; // null means old
  int testDevisibleBy;
  int trueSendToMonkeyId;
  int falseSendToMonkeyId;

  Monkey(this.items, this.operationIsAdd, this.operationAmount,
      this.testDevisibleBy, this.trueSendToMonkeyId, this.falseSendToMonkeyId);
}

final Map<int, int> numInspectionsByMonkeyId = {};
int allDivisibleBy = 1;

Future<void> main() async {
  final lines = await Util.readFileAsStrings('input.txt');

  /*
  Monkey 0:
  Starting items: 59, 74, 65, 86
  Operation: new = old * 19
  Test: divisible by 7
    If true: throw to monkey 6
    If false: throw to monkey 2
  */
  Map<int, Monkey> monkeysById = {};
  for (int i = 0; i < lines.length; i = i + 7) {
    print('I: $i');
    final line = lines[i];
    if (line.startsWith('Monkey')) {
      // monkey ID
      final monkeyParts = line.split(' ');
      final monkeyId = int.parse(monkeyParts[1].replaceFirst(':', ''));
      print('ID: $monkeyId');
      numInspectionsByMonkeyId[monkeyId] = 0;

      // items
      final startingItemsLine = lines[i + 1];
      final startingItemsTxt = startingItemsLine.split(':');
      final startingItemsStrings = startingItemsTxt[1].trim().split(', ');
      List<int> items = [];
      for (final startingItem in startingItemsStrings) {
        items.add(int.parse(startingItem));
      }
      print('Items: $items');

      // operation
      //  Operation: new = old * 19
      final operationLine = lines[i + 2];
      final operationIsAdd = operationLine.contains('+');
      final operationParts = operationLine.split(' ');
      int? operationAmount;
      try {
        operationAmount = int.parse(operationParts[operationParts.length - 1]);
      } on Exception catch (e) {
        // TODO
      }
      print('operationIsAdd: $operationIsAdd');
      print('operationAmount: $operationAmount');

      //   Test: divisible by 7
      final testLine = lines[i + 3];
      final testLineParts = testLine.split(' ');
      final testDevisibleBy =
          int.parse(testLineParts[testLineParts.length - 1]);
      print('testDevisibleBy: $testDevisibleBy');

      // If true: throw to monkey 6
      // If false: throw to monkey 2
      final trueLine = lines[i + 4];
      final trueLineParts = trueLine.split(' ');
      final trueSendToMonkeyId =
          int.parse(trueLineParts[trueLineParts.length - 1]);
      final falseLine = lines[i + 5];
      final falseLineParts = falseLine.split(' ');
      final falseSendToMonkeyId =
          int.parse(falseLineParts[falseLineParts.length - 1]);
      print('trueSendToMonkeyId: $trueSendToMonkeyId');
      print('falseSendToMonkeyId: $falseSendToMonkeyId');

      final monkey = Monkey(items, operationIsAdd, operationAmount,
          testDevisibleBy, trueSendToMonkeyId, falseSendToMonkeyId);
      monkeysById[monkeyId] = monkey;
    }
  }

  for (final entry in monkeysById.values) {
    allDivisibleBy *= entry.testDevisibleBy;
  }

  print(monkeysById.keys.length);

  // loop through rounds
  for (int i = 0; i < 10000; i++) {
    // print('Round $i');
    runOneRound(monkeysById);
    // for (final entry in monkeysById.entries) {
    //   print('${entry.key}, ${entry.value.items}');
    // }
  }

  // get the max 2
  for (final entry in numInspectionsByMonkeyId.entries) {
    print('Monkey: ${entry.key}, ${entry.value}');
  }
}

void runOneRound(Map<int, Monkey> monkeysById) {
  for (int i = 0; i < monkeysById.keys.length; i++) {
    final monkey = monkeysById[i]!;
    List<int> allItems = [];
    for (final item in monkey.items) {
      allItems.add(item);
    }
    for (final item in allItems) {
      // update our counter
      numInspectionsByMonkeyId[i] = numInspectionsByMonkeyId[i]! + 1;

      int worryLevel = item;
      if (monkey.operationIsAdd) {
        if (monkey.operationAmount != null) {
          worryLevel = worryLevel + monkey.operationAmount!;
        } else {
          worryLevel = worryLevel + worryLevel;
        }
      } else {
        if (monkey.operationAmount != null) {
          worryLevel = worryLevel * monkey.operationAmount!;
        } else {
          worryLevel = worryLevel * worryLevel;
        }
      }

      // // Not a thing for part 2
      // // Monkey gets bored with item. Worry level is divided by 3
      // worryLevel = (worryLevel / 3).toInt();

      // check if is divisible
      int nextMonkeyId;
      if (worryLevel % monkey.testDevisibleBy == 0) {
        nextMonkeyId = monkey.trueSendToMonkeyId;
        // TODO maybe?
        // worryLevel = worryLevel % monkey.testDevisibleBy;
      } else {
        nextMonkeyId = monkey.falseSendToMonkeyId;
      }

      print(worryLevel);

      // get remainder of next one?
      // final nextDivisibleBy = monkeysById[nextMonkeyId]!.testDevisibleBy;
      // worryLevel = worryLevel % nextDivisibleBy;
      worryLevel = worryLevel % allDivisibleBy;

      // add to other monkey
      monkeysById[nextMonkeyId]!.items.add(worryLevel);
    }

    // remove from this monkey
    monkeysById[i]!.items = [];
  }
}
