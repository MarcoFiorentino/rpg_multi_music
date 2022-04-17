import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesManager {

  // Recupero l'istanza delle sharedPreferences
  static Future<SharedPreferences> getSharedPreferencesInstance() async {
    return await SharedPreferences.getInstance();
  }

  // Aggiorna le coppie di chiave-valore
  static void updateKV(String key, bool add, [dynamic value = ""]) async {

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
  static void updateDirList(String dirId) async {

    SharedPreferences sharedPreferences = await getSharedPreferencesInstance();
    List<String> dirs = <String>[];
    if (sharedPreferences.getStringList("DirsId") != null) {
      dirs = sharedPreferences.getStringList("DirsId");
    }

    if (dirs.contains(dirId)) {
      dirs.remove(dirId);
    } else {
      dirs.add(dirId);
    }

    sharedPreferences.setStringList("DirsId", dirs);
  }
}