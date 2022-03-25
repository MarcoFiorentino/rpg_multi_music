import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:music_handler/shared_preferences_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilesProvider with ChangeNotifier {
  // Actual shared content
  List<List<File>> _dirNames = [];
  Map<String, String> _directories = {};
  List<String> _colors = [];

  List<List<File>> get dirNames => this._dirNames;
  Map<String, String> get directories => this._directories;
  List<String> get colors => this._colors;

  // Recupero le liste di file
  void getFilesList() async {
    SharedPreferences sharedPreferences = await SharedPreferencesManager.getSharedPreferencesInstance();

    print(sharedPreferences.getStringList("Directories"));
    if (sharedPreferences.getStringList("Directories") != null) {
      sharedPreferences.getStringList("Directories").forEach((directory) async {
        this._dirNames.add(await this.getFiles(directory));
        this.notifyListeners();
      });
    }
  }

  // Restituisce l'elenco dei file audio nella sotto cartella specificata
  Future<List<File>> getFiles(String type) async {
    List<File> files = new List<File>.empty();

    if (await Permission.storage.request().isGranted) {
      FileManager fm;

      SharedPreferences sharedPreferences = await SharedPreferencesManager.getSharedPreferencesInstance();

      this._directories[type] = sharedPreferences.getString(type) ?? "";
      if (this._directories[type] != "") {
        fm = FileManager(
            root: Directory(_directories[type]));
      }

      if (fm != null) {
        files = await fm.filesTree(
          excludedPaths: ["/storage/emulated/0/Android"],
          extensions: ["mp4", "m4a", "mp3"],
        );
      }
    }
    return files;
  }

  Future<int> getNumDir() async {
    SharedPreferences sharedPreferences = await SharedPreferencesManager.getSharedPreferencesInstance();
    if (sharedPreferences.getString("NumDir") != null) {
      return int.parse(sharedPreferences.getString("NumDir"));
    } else {
      return 2;
    }
  }

  void getColors() async {
    SharedPreferences sharedPreferences = await SharedPreferencesManager.getSharedPreferencesInstance();
    if (sharedPreferences.getStringList("Colors") != null) {
      sharedPreferences.getStringList("Colors").forEach((color) async {
        this._colors.add(color);
        this.notifyListeners();
      });
    }
  }
}
