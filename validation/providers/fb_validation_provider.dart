import 'package:adgo_mobile/validation/validation_result.dart';
import 'package:adgo_mobile/validation/validators/social_validater.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final fbProvider = StateProvider<String>((ref) => '');


final fbValidationProvider = Provider<ValidationResult>((ref) {
  final fb = ref.watch(fbProvider).trim();
  return SocialMediaValidator().validate(fb);
});


final isfbValidProvider = Provider<bool>((ref) {
  return ref.watch(fbValidationProvider).isValid;
});