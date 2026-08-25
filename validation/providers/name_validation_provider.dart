import 'package:adgo_mobile/validation/validators/name_validater.dart';
import 'package:adgo_mobile/validation/validation_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final nameProvider = StateProvider<String>((ref) => '');


final nameValidationProvider = Provider<ValidationResult>((ref) {
  final name = ref.watch(nameProvider).trim();
  return NameValidator().validate(name);
});


final isnameValidProvider = Provider<bool>((ref) {
  return ref.watch(nameValidationProvider).isValid;
});
