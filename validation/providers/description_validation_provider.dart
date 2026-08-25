import 'package:adgo_mobile/validation/validation_result.dart';
import 'package:adgo_mobile/validation/validators/description_validater.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final descriptionProvider = StateProvider<String>((ref) => '');

final descriptionValidationProvider = Provider<ValidationResult>((ref) {
  final shopDescription = ref.watch(descriptionProvider).trim();
  return DescriptionValidator().validate(shopDescription);
});

final isDescriptionValidProvider = Provider<bool>((ref) {
  return ref.watch(descriptionValidationProvider).isValid;
});