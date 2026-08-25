import 'package:adgo_mobile/validation/validation_result.dart';
import 'package:adgo_mobile/validation/validators/phone_validater.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final phoneProvider = StateProvider<String>((ref) => '');


final phoneValidationProvider = Provider<ValidationResult>((ref) {
  final phone = ref.watch(phoneProvider).trim();
  return PhoneValidator().validate(phone);
});


final isPhoneValidProvider = Provider<bool>((ref) {
  return ref.watch(phoneValidationProvider).isValid;
});
