import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {

  // Recupero l'istanza delle sharedPreferences
  static Future<SharedPreferences> getSharedPreferencesInstance() async {
    return await SharedPreferences.getInstance();
  }

  // Aggiorna le coppie di chiave-valore
  static void saveKV(String key, dynamic value, bool add) async {
    SharedPreferences sharedPreferences = await getSharedPreferencesInstance();
    if (add) {
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
    } else {
      sharedPreferences.remove(key);
    }
  }

  // Aggiorna la lista di directory salvate
  static void saveDirList(String dir, int index, bool add) async {
    SharedPreferences sharedPreferences = await getSharedPreferencesInstance();
    List<String> dirs = <String>[];
    if (sharedPreferences.getStringList("Directories") != null) {
      dirs = sharedPreferences.getStringList("Directories");
    }

    if (add) {
      if (dirs.length >= index + 1) {
        dirs[index] = dir;
      } else {
        dirs.add(dir);
      }
    } else {
      dirs.removeAt(index);
    }

    sharedPreferences.setStringList("Directories", dirs);
  }

  // Aggiorna la lista di colori salvati
  static void saveColorsList(String color, int index, bool add) async {
    SharedPreferences sharedPreferences = await getSharedPreferencesInstance();
    List<String> colors = <String>[];
    if (sharedPreferences.getStringList("Colors") != null) {
      colors = sharedPreferences.getStringList("Colors");
    }

    if (add) {
      if (colors.length >= index + 1) {
        colors[index] = color;
      } else {
        colors.add(color);
      }
    } else {
      colors.removeAt(index);
    }

    sharedPreferences.setStringList("Colors", colors);
  }
}