/*
@Author - Anuruddha
@Date - 2025/02/11
 */

import 'package:adgo_mobile/models/user.dart';
import 'package:adgo_mobile/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Settingsscreen extends StatelessWidget {
  const Settingsscreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          leading: const BackButton(),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 80,
                child: Icon(Icons.person_outlined, size: 80),
              ),
              const SizedBox(height: 20),
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(user.email),
              InkWell(
                onTap: () {
                GoRouter.of(context).go(Routes.home);
                },
                child: const Text("Home"))
            ],
          ),
        ),
      );
}
