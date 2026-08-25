import 'package:adgo_mobile/validation/validation_result.dart';
import 'package:adgo_mobile/validation/validators/description_validater.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final videoDescriptionProvider = StateProvider<String>((ref) => '');

final videoDescriptionValidationProvider = Provider<ValidationResult>((ref) {
  final videoDescription = ref.watch(videoDescriptionProvider).trim();
  return DescriptionValidator().validate(videoDescription);
});

final isDescriptionValidProvider = Provider<bool>((ref) {
  return ref.watch(videoDescriptionValidationProvider).isValid;
});