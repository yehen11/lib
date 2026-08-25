/*
@Author - Anuruddha
@Date - 2025/02/11
 */

import 'package:adgo_mobile/routes/routes.dart';
import 'package:adgo_mobile/themes/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custombottom_navigation_bar.dart';

class LayoutScaffold extends StatelessWidget {
  const LayoutScaffold({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('LayoutScaffold'));

  final StatefulNavigationShell navigationShell;

  

  @override
  Widget build(BuildContext context){

    final String location = GoRouterState.of(context).uri.toString();
    final bool hideBottomNavBar = location.contains(Routes.login) || location.contains(Routes.signUp) || location.contains(Routes.verificationScreen);
       
        
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: secondaryLightColor,
      body: SafeArea(
        top: true,
        bottom: false,
        child: navigationShell,
      ),
      bottomNavigationBar: hideBottomNavBar ? null : Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: primaryDarkColor, width: 0.5)),
        ),
        child: CustomBottomNavigationBar(navigationShell: navigationShell),
      ),
    );
  }
}
