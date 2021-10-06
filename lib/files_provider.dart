import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:music_handler/shared_preferences_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilesProvider with ChangeNotifier {
  // Actual shared content
  List<File> _firstDirNames = [];
  List<File> _secondDirNames = [];
  Map<String, String> _directories = {};

  List<File> get firstDirNames => this._firstDirNames;
  List<File> get secondDirNames => this._secondDirNames;
  Map<String, String> get directories => this._directories;

  // Recupero le liste di file
  void getFilesList() async {
    // Recupero i file dalla cartella 'music'
    this._firstDirNames = await this.getFiles(SharedPreferencesManager.firstDirectory);
    this.notifyListeners();
    this._secondDirNames = await this.getFiles(SharedPreferencesManager.secondDirectory);
    this.notifyListeners();
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
          extensions: ["mp4", "m4a"],
        );
      }
    }
    return files;
  }
}
