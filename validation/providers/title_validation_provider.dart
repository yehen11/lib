import 'package:adgo_mobile/validation/validation_result.dart';
import 'package:adgo_mobile/validation/validators/short_text_validater.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final titleProvider = StateProvider<String>((ref) => '');

final titleValidationProvider = Provider<ValidationResult>((ref) {
  final Title = ref.watch(titleProvider).trim();
  return ShortTextValidator().validate(Title);
});

final isTitleValidProvider = Provider<bool>((ref) {
  return ref.watch(titleValidationProvider).isValid;
});