import 'package:adgo_mobile/validation/validators/password_validater.dart';
import 'package:adgo_mobile/validation/validation_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final pwProvider = StateProvider<String>((ref) => '');


final pwValidationProvider = Provider<ValidationResult>((ref) {
  final password = ref.watch(pwProvider).trim();
  return PasswordValidator().validate(password);
});


final isPWValidProvider = Provider<bool>((ref) {
  return ref.watch(pwValidationProvider).isValid;
});
