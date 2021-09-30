import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:music_handler/shared_preferences_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilesProvider with ChangeNotifier {
  // Actual shared content
  List<File> _musicNames = [];
  List<File> _ambienceNames = [];
  String _selectedDirectory;

  List<File> get musicNames => this._musicNames;
  List<File> get ambienceNames => this._ambienceNames;
  String get selectedDirectory => this._selectedDirectory;

  // Recupero le liste di file
  void getFilesList() async {
    // Recupero i file dalla cartella 'music'
    this._musicNames = await this.getFiles("music");
    this.notifyListeners();
    this._ambienceNames = await this.getFiles("ambience");
    this.notifyListeners();
  }

  // Restituisce l'elenco dei file audio nella sotto cartella specificata
  Future<List<File>> getFiles(String type) async {
    List<File> files = new List<File>.empty();

    if (await Permission.storage.request().isGranted) {
      FileManager fm;

      SharedPreferences sharedPreferences = await SharedPreferencesManager.getSharedPreferencesInstance();
      this._selectedDirectory = sharedPreferences.getString(SharedPreferencesManager.selectedDirectory) ?? "";
      if (this._selectedDirectory != "") {
        fm = FileManager(
            root: Directory(this._selectedDirectory + "/" + type));
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
