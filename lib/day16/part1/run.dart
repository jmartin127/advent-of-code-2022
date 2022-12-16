import '../../src/util.dart';

class Valve {
  String label;
  int flowRate;
  List<String> tunnels;

  Valve(this.label, this.flowRate, this.tunnels);

  @override
  String toString() {
    return '$label flow of $flowRate, leads to $tunnels';
  }
}

Future<void> main() async {
  final lines = await Util.readFileAsStrings('input.txt');

  // read in the input
  Map<String, Valve> valves = {};
  for (var line in lines) {
    // Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
    line = line.replaceAll('=', ' ');
    line = line.replaceAll(';', '');
    line = line.replaceAll(',', '');
    // Valve AA has flow rate 0 tunnels lead to valves DD II BB
    final parts = line.split(' ');
    List<String> tunnels = [];
    for (int i = 10; i < parts.length; i++) {
      tunnels.add(parts[i]);
    }
    final label = parts[1];
    final valve = Valve(parts[1], int.parse(parts[5]), tunnels);
    valves[label] = valve;
  }
}
