import 'package:adgo_mobile/validation/validation_result.dart';
import 'package:adgo_mobile/validation/validators/social_validater.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final instaProvider = StateProvider<String>((ref) => '');


final instaValidationProvider = Provider<ValidationResult>((ref) {
  final insta = ref.watch(instaProvider).trim();
  return SocialMediaValidator().validate(insta);
});


final isinstaValidProvider = Provider<bool>((ref) {
  return ref.watch(instaValidationProvider).isValid;
});