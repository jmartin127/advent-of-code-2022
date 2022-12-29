import 'dart:collection';

void main() {
  final q = Queue<int>();
  q.addFirst(1);
  q.addFirst(2);
  q.addFirst(3);
  q.addFirst(4);

  print(q.removeLast());
  print(q.removeLast());
  print(q.removeLast());
  print(q.removeLast());
}
