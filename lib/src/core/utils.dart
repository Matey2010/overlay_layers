/// Generate a unique ID for overlay instances
int _idCounter = 0;

String generateId(String prefix) {
  _idCounter++;
  return '$prefix-${DateTime.now().millisecondsSinceEpoch}-$_idCounter';
}
