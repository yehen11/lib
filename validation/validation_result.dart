


class ValidationResult {
  final bool isValid;
  final String? error;

  const ValidationResult({required this.isValid, this.error});

  static ValidationResult success() => const ValidationResult(isValid: true);
  static ValidationResult failure(String error) =>
      ValidationResult(isValid: false, error: error);
}