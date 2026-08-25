/*
@Author - Anuruddha
@Date - 2025/03/29
 */
import 'package:adgo_mobile/modules/auth/data/apis/i_auth_api.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AwsCognitoApi implements IAuthApi{

static const String userPoolId = String.fromEnvironment('USER_POOL_ID', defaultValue: 'SOME_DEFAULT_VALUE');
static const String clientId = String.fromEnvironment('CLIENT_ID', defaultValue: 'SOME_DEFAULT_VALUE');
static const identityPoolId = String.fromEnvironment('IDENTITY_POOL_ID', defaultValue: 'SOME_DEFAULT_VALUE');
static const region = String.fromEnvironment('REGION', defaultValue: 'SOME_DEFAULT_VALUE');
static const bucketName = String.fromEnvironment('BUCKET_NAME', defaultValue: 'SOME_DEFAULT_VALUE');


final CognitoUserPool userPool = CognitoUserPool(userPoolId, clientId);

@override
  Future<bool> signInUser(String email, String password) async {
  final cognitoUser = CognitoUser(email, userPool);
  final authDetails = AuthenticationDetails(username: email, password: password);
  
  try {
    final session = await cognitoUser.authenticateUser(authDetails);
    
    if (session?.idToken.jwtToken != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      //await prefs.setString('idToken', session!.idToken.jwtToken!);
      //await prefs.setString('accessToken', session.accessToken.jwtToken!);
      //await prefs.setString('refreshToken', session.refreshToken!.token!);
      final idToken = session!.idToken;
      final userId = idToken.payload['sub'];
      await prefs.setString('userId', userId);
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', email);
       }
      return true;
    
  } catch (e) {
    return false;
  }
}


@override
  Future<bool> isUserSignedInWithEmail(String email) async {
  try {
    final cognitoUser = CognitoUser(email, userPool);
    final session = await cognitoUser.getSession();
    if (session != null && session.isValid()) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}


@override
  Future<bool> isUserSignedInSharedPref() async {
  try {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn');
    if (isLoggedIn != null && isLoggedIn) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}



@override
  Future<bool> signUpUser(String email, String password, BuildContext context) async {
  try {
    await userPool.signUp(email, password);
    
     final cognitoUser = CognitoUser(email, userPool);
     final authDetails = AuthenticationDetails(username: email, password: password);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('username', email);
      return true;
  } catch (e) {
    return false;
  }
}

@override
Future<String?> signUpAndGetUserId(String email, String password) async {

  try {
    final cognitoUser = CognitoUser(email, userPool);

    final authDetails = AuthenticationDetails(username: email, password: password);
    final session = await cognitoUser.authenticateUser(authDetails);

    final idToken = session!.idToken;
    final userId = idToken.payload['sub'];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    return userId;

  } catch (e) {
    print("Signup/login error: $e");
    return null;
  }
}


@override
Future<String?> getUserId(String email) async {
  final cognitoUser = CognitoUser(email, userPool);
  try {
    
    final session = await cognitoUser.getSession();
    
    if (session != null && session.isValid()) {
      final idToken = session.idToken;
      final payload = idToken.payload;
      
      return payload['sub']; 
    }
    else{
      print("session is null or invalid");
    }
    return null;
  } catch (e) {
    return null;
  }
}






@override
Future<bool> confirmSignUp(String email, String otp) async {
  final cognitoUser = CognitoUser(email, userPool);
  try {
    await cognitoUser.confirmRegistration(otp);
    return true;
  } catch (e) {
    return false;
  }
}
@override
Future<bool> forgotPassword(String email) async {
  final cognitoUser = CognitoUser(email, userPool);
  try {
    await cognitoUser.forgotPassword();
    return true;
  } catch (e) {
    return false;
  }
}
@override
Future<bool> resetPassword(String email, String otp, String newPassword) async {
  final cognitoUser = CognitoUser(email, userPool);
  try {
    await cognitoUser.confirmPassword(otp, newPassword);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('username', email);
    return true;
  } catch (e) {
    return false;
  }
}
@override
Future<bool> signOutUser(String email) async {
  final cognitoUser = CognitoUser(email, userPool);
  try {
    await cognitoUser.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    return true;
  } catch (e) {
    return false;
  }
}


}