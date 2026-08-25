import 'package:adgo_mobile/validation/validators/ivalidater.dart';
import '../validation_result.dart';

class PhoneValidator implements Validator<String> {
  @override
  ValidationResult validate(String value) {
    if (value.isEmpty) {
      return ValidationResult.failure("Phone number can't be empty");
    }
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length < 7) {
      return ValidationResult.failure("Phone number is too short");
    }
    if (digitsOnly.length > 15) {
      return ValidationResult.failure("Phone number is too long");
    }

    return ValidationResult.success();
  }
}