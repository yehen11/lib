import 'package:adgo_mobile/validation/validation_result.dart';
import 'package:adgo_mobile/validation/validators/ivalidater.dart';

class SocialMediaValidator implements Validator {
  @override
  ValidationResult validate(dynamic value) {
    if (value == null) return ValidationResult.failure("Value cannot be null");

    final String stringValue = value.toString();
    
    if (stringValue.isEmpty) return ValidationResult.success();
    
    final socialMediaRegex = RegExp(
      r'^https?:\/\/(www\.)?(facebook|instagram|twitter|x|linkedin|youtube|tiktok|pinterest|snapchat|threads)\.(com|co)\/[a-zA-Z0-9_\-\.]+\/?.*$',
      caseSensitive: false
    );

    final usernameRegex = RegExp(r'^@[a-zA-Z0-9_\.]{1,30}$');

    final websiteRegex = RegExp(
      r'^(https?:\/\/)?(www\.)?([a-zA-Z0-9][-a-zA-Z0-9]*\.)+[a-zA-Z0-9]{2,}(\/[-a-zA-Z0-9_%\.\~#\?&=]*)*$',
      caseSensitive: false
    );
    
    if (socialMediaRegex.hasMatch(stringValue)) {
      return ValidationResult.success();
    }
    
    if (usernameRegex.hasMatch(stringValue)) {
      return ValidationResult.success();
    }
    
    if (websiteRegex.hasMatch(stringValue)) {
      return ValidationResult.success();
    }
    
    return ValidationResult.failure("Invalid URL or username");
  }
}