import 'package:adgo_mobile/validation/validation_result.dart';
import 'package:adgo_mobile/validation/validators/bio_validater.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bioProvider = StateProvider<String>((ref) => '');

final bioValidationProvider = Provider<ValidationResult>((ref) {
  final bio = ref.watch(bioProvider).trim();
  return BioValidator().validate(bio);
});

final isbioValidProvider = Provider<bool>((ref) {
  return ref.watch(bioValidationProvider).isValid;
});