import 'package:adgo_mobile/validation/validation_result.dart';
import 'package:adgo_mobile/validation/validators/shopName_validater.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final shopNameProvider = StateProvider<String>((ref) => '');

final shopNameValidationProvider = Provider<ValidationResult>((ref) {
  final shopName = ref.watch(shopNameProvider).trim();
  return ShopNameValidator().validate(shopName);
});

final isShopNameValidProvider = Provider<bool>((ref) {
  return ref.watch(shopNameValidationProvider).isValid;
});