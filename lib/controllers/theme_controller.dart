import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final storage = GetStorage();
  Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  final _themeKey = 'app_theme';
  @override
  void onInit() {
    // TODO: implement onInit
    themeMode.value =
        _getThemeModeFromString(storage.read(_themeKey) ?? 'system');
    Get.changeThemeMode(themeMode.value);
    super.onInit();
  }

  void setTheme(ThemeMode mode) {
    themeMode.value = mode;
    storage.write(_themeKey, _getThemeString(mode));
    Get.changeThemeMode(mode);
  }

  String _getThemeString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  ThemeMode _getThemeModeFromString(String theme) {
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
