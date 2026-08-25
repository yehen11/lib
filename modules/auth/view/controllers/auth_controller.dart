import 'package:adgo_mobile/modules/auth/data/apis/aws_cognito_api.dart';
import 'package:adgo_mobile/modules/auth/data/repositories/auth_repo.dart';
import 'package:adgo_mobile/modules/auth/data/services/auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';


final _authApiProvider = Provider<AwsCognitoApi>((ref) => AwsCognitoApi());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(_authApiProvider));
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(authRepositoryProvider));
});

// Providers for AuthService methods
final signUpUserProvider = FutureProvider.family<bool, (String, String, BuildContext)>((ref, params) async {
  final authService = ref.read(authServiceProvider);
  return await authService.signUpUser(params.$1, params.$2, params.$3);
});

final confirmSignUpProvider = FutureProvider.family<bool, (String, String)>((ref, params) async {
  final authService = ref.read(authServiceProvider);
  return await authService.confirmSignUp(params.$1, params.$2);
});

final signInUserProvider = FutureProvider.family<bool, (String, String)>((ref, params) async {
  final authService = ref.read(authServiceProvider);
  return await authService.signInUser(params.$1, params.$2);
});

final signOutProvider = FutureProvider.family<bool, String>((ref, username) async {
  final authService = ref.read(authServiceProvider);
  return await authService.signOut(username);
});

final resetPasswordProvider = FutureProvider.family<bool, (String, String, String)>((ref, params) async {
  final authService = ref.read(authServiceProvider);
  return await authService.resetPassword(params.$1, params.$2, params.$3);
});

final isUserSignedInWithEmailProvider = FutureProvider.family<bool, String>((ref, email) async {
  final authService = ref.read(authServiceProvider);
  return await authService.isUserSignedInWithEmail(email);
});

final isUserSignedInSharedPrefProvider = FutureProvider<bool>((ref) async {
  final authService = ref.read(authServiceProvider);
  return await authService.isUserSignedInSharedPref();
});

final forgotPasswordProvider = FutureProvider.family<bool, String>((ref, username) async {
  final authService = ref.read(authServiceProvider);
  return await authService.forgotPassword(username);
});

final userIDProvider = FutureProvider.family<String?, String>((ref, email) async {
  final authService = ref.read(authServiceProvider);
  return await authService.getUserId(email);
});

final signUpAndGetUserIdProvider = FutureProvider.family<String?, (String, String)>((ref, params) async {
  final authService = ref.read(authServiceProvider);
  return await authService.signUpAndGetUserId(params.$1, params.$2);
});


