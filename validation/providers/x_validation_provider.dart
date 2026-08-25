import 'package:adgo_mobile/validation/validation_result.dart';
import 'package:adgo_mobile/validation/validators/social_validater.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final xProvider = StateProvider<String>((ref) => '');


final xValidationProvider = Provider<ValidationResult>((ref) {
  final x = ref.watch(xProvider).trim();
  return SocialMediaValidator().validate(x);
});


final isxValidProvider = Provider<bool>((ref) {
  return ref.watch(xValidationProvider).isValid;
});