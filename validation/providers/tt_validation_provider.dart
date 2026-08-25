import 'package:adgo_mobile/validation/validation_result.dart';
import 'package:adgo_mobile/validation/validators/social_validater.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final ttProvider = StateProvider<String>((ref) => '');


final ttValidationProvider = Provider<ValidationResult>((ref) {
  final tt = ref.watch(ttProvider).trim();
  return SocialMediaValidator().validate(tt);
});


final isttValidProvider = Provider<bool>((ref) {
  return ref.watch(ttValidationProvider).isValid;
});