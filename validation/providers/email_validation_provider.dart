import 'package:adgo_mobile/validation/validators/email_validater.dart';
import 'package:adgo_mobile/validation/validation_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final emailProvider = StateProvider<String>((ref) => '');


final emailValidationProvider = Provider<ValidationResult>((ref) {
  final email = ref.watch(emailProvider).trim();
  return EmailValidator().validate(email);
});


final isEmailValidProvider = Provider<bool>((ref) {
  return ref.watch(emailValidationProvider).isValid;
});
