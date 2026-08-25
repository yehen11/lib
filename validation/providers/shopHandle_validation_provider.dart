import 'package:adgo_mobile/validation/validation_result.dart';
import 'package:adgo_mobile/validation/validators/shopHandle_validater.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shopHandleProvider = StateProvider<String>((ref) => '');

final shopHandleValidationProvider = Provider<ValidationResult>((ref) {
  final shopHandle = ref.watch(shopHandleProvider).trim();
  return ShopHandleValidator().validate(shopHandle);
});

final isShopHandleValidProvider = Provider<bool>((ref) {
  return ref.watch(shopHandleValidationProvider).isValid;
});