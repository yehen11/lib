/*
@Author - Anuruddha
@Date - 2025/03/01
*/

import 'package:adgo_mobile/themes/utils.dart';
import 'package:flutter/material.dart';

Widget floatingButton(IconData icon,VoidCallback onPressed) {
    return Column(
      children: [
            IconButton(
              icon: Icon(icon, color: whiteColor, size: 32,shadows: [Shadow(
                color: Colors.black26,
                offset: Offset(0, 2),
                blurRadius: 4,
              ),],),
              onPressed: onPressed,
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        );
  }