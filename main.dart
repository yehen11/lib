/*
@Author - Anuruddha
@Date - 2025/02/11
 */

import 'package:adgo_mobile/router/router.dart';
import 'package:adgo_mobile/routes/routes.dart';
import 'package:adgo_mobile/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  
   String initialRoute = Routes.login; 

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      setState(() {
        initialRoute = Routes.home; 
      });
    }
  }

  
  @override
  Widget build(BuildContext context) => MaterialApp.router(
        routerConfig: getRouter(initialRoute),
        debugShowCheckedModeBanner: false,
        scrollBehavior: AppTheme.scrollBehavior,
        themeMode: AppTheme.themeMode,
        theme: AppTheme.lightTheme,
      );
}


