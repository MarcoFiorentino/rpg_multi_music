import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:music_handler/shared_preferences_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilesProvider with ChangeNotifier {
  // Variabili condivise
  List<List<File>> _filesPaths = [];
  List<String> _dirsIds = [];
  List<String> _dirsPaths = [];
  List<String> _dirsColors = [];
  List<String> _dirsNames = [];


  List<List<File>> get filesPaths => this._filesPaths;
  List<String> get dirsIds => this._dirsIds;
  List<String> get dirsPaths => this._dirsPaths;
  List<String> get dirsColors => this._dirsColors;
  List<String> get dirsNames => this._dirsNames;

  // Recupero le liste di file
  void getFilesList() async {
    SharedPreferences sharedPreferences = await SharedPreferencesManager.getSharedPreferencesInstance();

    // Svuoto tutte le liste
    this._filesPaths = [];
    this._dirsIds = [];
    this._dirsPaths = [];
    this._dirsColors = [];
    this._dirsNames = [];

    if (sharedPreferences.getStringList("DirsId") != null && sharedPreferences.getStringList("DirsId").length > 0) {
      // Per ogni id salvato riempio le liste
      sharedPreferences.getStringList("DirsId").asMap().forEach((index, dirId) async {
        this._filesPaths.add(await this.getFiles(dirId, sharedPreferences.getStringList(dirId)[0]));
        this._dirsIds.add(dirId);
        this._dirsPaths.add(sharedPreferences.getStringList(dirId)[0]);
        this._dirsColors.add(sharedPreferences.getStringList(dirId)[1]);
        this._dirsNames.add(sharedPreferences.getStringList(dirId)[2]);

        // Notifico i cambiamenti ai listener
        this.notifyListeners();
      });
    } else {
      // Se ho cancellato tutte le colonne notifico i cambiamenti ai listener
      this.notifyListeners();
    }
  }

  // Restituisce l'elenco dei file audio nella sotto cartella specificata
  Future<List<File>> getFiles(String dirId, String dirPath) async {
    List<File> files = new List<File>.empty();

    if (await Permission.storage.request().isGranted) {
      FileManager fm;

      if (dirPath != "") {
        fm = FileManager(
            root: Directory(dirPath));
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
}
