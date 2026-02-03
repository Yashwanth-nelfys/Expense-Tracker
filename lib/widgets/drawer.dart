import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/theme_controller.dart';

class MyDrawer extends StatelessWidget {
  MyDrawer({super.key});
  final controller = Get.find<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
              child: Card(
                  color: Colors.white,
                  child: Image(image: AssetImage("assets/logo.png")))),
          ListTile(
            leading: Theme.of(context).brightness == Brightness.light
                ? const Icon(Icons.dark_mode)
                : const Icon(Icons.light_mode),
            title: const Text("Change Theme"),
            onTap: () {
              if (Get.isDarkMode) {
                controller.setTheme(ThemeMode.light);
              } else {
                controller.setTheme(ThemeMode.dark);
              }
            },
          )
        ],
      ),
    );
  }
}
