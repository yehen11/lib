import 'package:adgo_mobile/validation/validation_result.dart';
import 'package:adgo_mobile/validation/validators/social_validater.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final websiteProvider = StateProvider<String>((ref) => '');


final websiteValidationProvider = Provider<ValidationResult>((ref) {
  final website = ref.watch(websiteProvider).trim();
  return SocialMediaValidator().validate(website);
});


final isWebsiteValidProvider = Provider<bool>((ref) {
  return ref.watch(websiteValidationProvider).isValid;
});