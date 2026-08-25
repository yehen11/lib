import 'package:adgo_mobile/validation/validation_result.dart';
import 'package:adgo_mobile/validation/validators/ivalidater.dart';

class ShortTextValidator implements Validator<String> {
  @override
  ValidationResult validate(String value) {
    if (value.isEmpty) {
      return ValidationResult.failure("can't be empty");
    }

    if (value.length < 3) {
      return ValidationResult.failure("must be at least 3 characters");
    }

    if (value.length > 50) {
      return ValidationResult.failure("must be less than 50 characters");
    }

    if (!RegExp(r"^[a-zA-Z0-9\s\-&']+$").hasMatch(value)) {
      return ValidationResult.failure("can only contain letters, numbers, spaces, hyphens, and ampersands");
    }

    return ValidationResult.success();
  }
}