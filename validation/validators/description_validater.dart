import 'package:adgo_mobile/validation/validators/ivalidater.dart';
import '../validation_result.dart';

class DescriptionValidator implements Validator<String> {
  @override
  ValidationResult validate(String value) {
    if (value.isEmpty) {
      return ValidationResult.failure("can't be empty");
    }

    if (value.length > 500) {
      return ValidationResult.failure("Must be less than 500 characters");
    }

    if (value.length < 2) {
      return ValidationResult.failure("Must be at least 2 characters");
    }

    return ValidationResult.success();
  }
}