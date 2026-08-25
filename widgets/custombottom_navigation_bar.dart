import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:adgo_mobile/models/destination.dart';
import 'package:adgo_mobile/themes/utils.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const CustomBottomNavigationBar({Key? key, required this.navigationShell}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: primaryLightColor, width: 0.25)),
        ),
        child: Theme(
          data: ThemeData(
            navigationBarTheme: NavigationBarThemeData(
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return TextStyle(
                    color: primaryDarkColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  );
                }
                return TextStyle(
                  color: primaryDarkColor.withOpacity(0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                );
              }),
            ),
          ),
          child: NavigationBar(
            height: 75,
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: navigationShell.goBranch,
            indicatorColor: primaryLightColor,
            backgroundColor: secondaryLightColor,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            elevation: 0,
            destinations: destinations
                .map((destination) => NavigationDestination(
                      icon: Icon(
                        destination.icon,
                        color: primaryDarkColor.withOpacity(0.6),
                        size: 24,
                      ),
                      label: destination.label,
                      selectedIcon: Icon(
                        destination.icon,
                        color: Colors.white,
                        size: 26,
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}
