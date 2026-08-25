import 'package:adgo_mobile/validation/validation_result.dart';
import 'package:adgo_mobile/validation/validators/ivalidater.dart';

class NameValidator implements Validator<String> {
  @override
  ValidationResult validate(String value) {
    if (value.isEmpty) {
      return ValidationResult.failure("Name can't be empty");
    }
    if (value.length < 2) {
      return ValidationResult.failure("Name is too short");
    }
    
    if (value.length > 50) {
      return ValidationResult.failure("Name is too long");
    }
    final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!nameRegex.hasMatch(value)) {
      return ValidationResult.failure("Name contains invalid characters");
    }
    if (!value.contains(' ')) {
      return ValidationResult.failure("Please enter your full name");
    }
    
    return ValidationResult.success();
  }
}