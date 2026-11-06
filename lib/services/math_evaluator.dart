/// Evaluates mathematical equations with standard BODMAS/PEMDAS order of operations.
/// Supports +, -, × (*), ÷ (/) and ensures integer arithmetic rules for Crossmath puzzles.
class MathEvaluator {
  /// Evaluates an expression given alternating numbers and operators:
  /// e.g. numbers: [3, 4, 2], operators: ['+', '×'] -> 3 + (4 * 2) = 11.
  /// Returns null if division by zero occurs or if non-integer division happens.
  static int? evaluate({
    required List<int> numbers,
    required List<String> operators,
  }) {
    if (numbers.isEmpty) return null;
    if (numbers.length == 1) return numbers.first;
    if (numbers.length != operators.length + 1) return null;

    // Work on mutable copies
    final nums = List<double>.from(numbers.map((n) => n.toDouble()));
    final ops = List<String>.from(operators.map(_normalizeOp));

    // First pass: Multiplication and Division (left to right)
    int i = 0;
    while (i < ops.length) {
      final op = ops[i];
      if (op == '*' || op == '/') {
        final left = nums[i];
        final right = nums[i + 1];

        if (op == '/') {
          if (right == 0) return null; // Division by zero invalid
          final result = left / right;
          // In Crossmath, division must yield clean integers
          if ((result - result.roundToDouble()).abs() > 0.00001) {
            return null;
          }
          nums[i] = result;
        } else {
          nums[i] = left * right;
        }

        nums.removeAt(i + 1);
        ops.removeAt(i);
      } else {
        i++;
      }
    }

    // Second pass: Addition and Subtraction (left to right)
    i = 0;
    while (i < ops.length) {
      final op = ops[i];
      final left = nums[i];
      final right = nums[i + 1];

      if (op == '+') {
        nums[i] = left + right;
      } else if (op == '-') {
        nums[i] = left - right;
      } else {
        return null;
      }

      nums.removeAt(i + 1);
      ops.removeAt(i);
    }

    final finalResult = nums.first;
    if ((finalResult - finalResult.roundToDouble()).abs() > 0.00001) {
      return null;
    }
    return finalResult.round();
  }

  static String _normalizeOp(String op) {
    if (op == '×' || op == 'x' || op == 'X' || op == '*') return '*';
    if (op == '÷' || op == '/' || op == ':') return '/';
    if (op == '+') return '+';
    if (op == '-' || op == '−') return '-';
    return op;
  }
}

