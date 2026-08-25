import 'package:adgo_mobile/validation/validation_result.dart';
import 'package:adgo_mobile/validation/validators/phone_validater.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final contactProvider = StateProvider<String>((ref) => '');


final contactValidationProvider = Provider<ValidationResult>((ref) {
  final phone = ref.watch(contactProvider).trim();
  return PhoneValidator().validate(phone);
});


final isContactValidProvider = Provider<bool>((ref) {
  return ref.watch(contactValidationProvider).isValid;
});
