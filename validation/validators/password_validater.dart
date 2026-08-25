import 'package:adgo_mobile/validation/validators/ivalidater.dart';
import '../validation_result.dart';

class PasswordValidator implements Validator<String> {
  @override
  ValidationResult validate(String value) {
    if (value.isEmpty) {
      return ValidationResult.failure("Password can't be empty");
    }

    if (value.length < 6) {
      return ValidationResult.failure("Password must be at least 6 characters");
    }

    if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$').hasMatch(value)) {
      return ValidationResult.failure("Password must include at least one uppercase letter, one number, and one special character"
);
    }

    return ValidationResult.success();
  }
}
