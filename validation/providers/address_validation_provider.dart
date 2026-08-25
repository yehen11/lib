import 'package:adgo_mobile/validation/validation_result.dart';
import 'package:adgo_mobile/validation/validators/description_validater.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Individual address line providers
final addressLine1Provider = StateProvider<String>((ref) => '');
final addressLine2Provider = StateProvider<String>((ref) => '');
final addressLine3Provider = StateProvider<String>((ref) => '');

// Combined address provider
final addressProvider = Provider<String>((ref) {
  final line1 = ref.watch(addressLine1Provider).trim();
  final line2 = ref.watch(addressLine2Provider).trim();
  final line3 = ref.watch(addressLine3Provider).trim();
  
  if (line1.isEmpty) return '';
  if (line2.isEmpty) return line1;
  if (line3.isEmpty) return '$line1, $line2';
  
  return '$line1, $line2, $line3';
});

// Validation providers for individual lines
final addressLine1ValidationProvider = Provider<ValidationResult>((ref) {
  final addressLine1 = ref.watch(addressLine1Provider).trim();
  return DescriptionValidator().validate(addressLine1);
});

final addressLine2ValidationProvider = Provider<ValidationResult>((ref) {
  final addressLine2 = ref.watch(addressLine2Provider).trim();
  
  // Skip validation if line 2 is empty (it's optional)
  if (addressLine2.isEmpty) {
    return ValidationResult.success();
  }
  
  return DescriptionValidator().validate(addressLine2);
});

  final addressLine3ValidationProvider = Provider<ValidationResult>((ref) {
  final addressLine3 = ref.watch(addressLine3Provider).trim();

  // Skip validation if line 3 is empty (it's optional)
  if (addressLine3.isEmpty) {
    return ValidationResult.success();
  }

  return DescriptionValidator().validate(addressLine3);
});

// Combined address validation provider
final addressValidationProvider = Provider<ValidationResult>((ref) {
  final line1Validation = ref.watch(addressLine1ValidationProvider);
  final line2Validation = ref.watch(addressLine2ValidationProvider);
  final line3Validation = ref.watch(addressLine3ValidationProvider);
  
  // Address is valid only if both lines are valid
  if (!line1Validation.isValid) {
    return line1Validation;
  }
  
  if (!line2Validation.isValid) {
    return line2Validation;
  }
  
  if (!line3Validation.isValid) {
    return line3Validation;
  }
  
  return ValidationResult.success();
});

final isAddressValidProvider = Provider<bool>((ref) {
  return ref.watch(addressValidationProvider).isValid;
});