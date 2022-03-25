import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {

  static Future<SharedPreferences> getSharedPreferencesInstance() async {
    return await SharedPreferences.getInstance();
  }

  static void saveKV(String key, dynamic value) async {
    SharedPreferences sharedPreferences = await getSharedPreferencesInstance();
    if (value is bool) {
      sharedPreferences.setBool(key, value);
    } else if (value is String) {
      sharedPreferences.setString(key, value);
    } else if (value is int) {
      sharedPreferences.setInt(key, value);
    } else if (value is double) {
      sharedPreferences.setDouble(key, value);
    } else if (value is List<String>) {
      sharedPreferences.setStringList(key, value);
    }
  }

  static void saveDirList(String dir, int rowIndex) async {
    SharedPreferences sharedPreferences = await getSharedPreferencesInstance();
    List<String> dirs = <String>[];
    if (sharedPreferences.getStringList("Directories") != null) {
      dirs = sharedPreferences.getStringList("Directories");
    }

    if (dirs.length >= rowIndex+1) {
      dirs[rowIndex] = dir;
    } else {
      dirs.add(dir);
    }

    sharedPreferences.setStringList("Directories", dirs);
  }

  static void saveColorsList(String color, int rowIndex) async {
    SharedPreferences sharedPreferences = await getSharedPreferencesInstance();
    List<String> colors = <String>[];
    if (sharedPreferences.getStringList("Colors") != null) {
      colors = sharedPreferences.getStringList("Colors");
    }

    if (colors.length >= rowIndex+1) {
      colors[rowIndex] = color;
    } else {
      colors.add(color);
    }

    sharedPreferences.setStringList("Colors", colors);
  }
}