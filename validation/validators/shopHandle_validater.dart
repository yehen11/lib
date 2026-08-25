import 'package:adgo_mobile/validation/validators/ivalidater.dart';
import '../validation_result.dart';

class ShopHandleValidator implements Validator<String> {
  @override
  ValidationResult validate(String value) {
    if (value.isEmpty) {
      return ValidationResult.failure("Shop handle can't be empty");
    }

    if (value.length < 3) {
      return ValidationResult.failure("Shop handle must be at least 3 characters");
    }

    if (value.length > 30) {
      return ValidationResult.failure("Shop handle must be less than 30 characters");
    }

    if (!RegExp(r'^[a-z0-9\-]+$').hasMatch(value)) {
      return ValidationResult.failure("Shop handle can only contain lowercase letters, numbers, and hyphens");
    }

    if (value.startsWith('-') || value.endsWith('-')) {
      return ValidationResult.failure("Shop handle cannot start or end with a hyphen");
    }

    if (value.contains('--')) {
      return ValidationResult.failure("Shop handle cannot contain consecutive hyphens");
    }

    return ValidationResult.success();
  }
}