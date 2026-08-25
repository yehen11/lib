import 'package:adgo_mobile/validation/validation_result.dart';
import 'package:adgo_mobile/validation/validators/description_validater.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final hoursProvider = StateProvider<String>((ref) => '');

final hoursValidationProvider = Provider<ValidationResult>((ref) {
  final hours = ref.watch(hoursProvider).trim();
  return DescriptionValidator().validate(hours);
});

final isDescriptionValidProvider = Provider<bool>((ref) {
  return ref.watch(hoursValidationProvider).isValid;
});