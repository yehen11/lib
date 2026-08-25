
import 'package:adgo_mobile/validation/validation_result.dart';

abstract class Validator<T> {
  ValidationResult validate(T value);
}
