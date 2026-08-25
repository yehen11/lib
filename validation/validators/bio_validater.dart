import 'package:adgo_mobile/validation/validators/ivalidater.dart';
import '../validation_result.dart';

class BioValidator implements Validator<String> {
  @override
  ValidationResult validate(String value) {
    if (value.isEmpty) {
      return ValidationResult.failure("Bio can't be empty");
    }

    if (value.length > 300) {
      return ValidationResult.failure("Bio must be less than 300 characters");
    }

    if (value.length < 10) {
      return ValidationResult.failure("Bio must be at least 10 characters");
    }

    return ValidationResult.success();
  }
}