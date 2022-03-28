import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:music_handler/shared_preferences_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilesProvider with ChangeNotifier {
  // Variabili condivise
  List<List<File>> _dirNames = [];
  Map<String, String> _directories = {};
  List<String> _colors = [];

  List<List<File>> get dirNames => this._dirNames;
  Map<String, String> get directories => this._directories;
  List<String> get colors => this._colors;

  // Recupero le liste di file
  void getFilesList() async {
    SharedPreferences sharedPreferences = await SharedPreferencesManager.getSharedPreferencesInstance();

    if (sharedPreferences.getStringList("Directories") != null) {
      if (sharedPreferences.getStringList("Directories").length > 0) {
        // Aggiorno le voci in dirNames con quelle nelle SharedPreferences
        sharedPreferences.getStringList("Directories").asMap().forEach((index, directory) async {
          if (this._dirNames.length >= index + 1) {
            this._dirNames[index] = await this.getFiles(directory);
          } else {
            this._dirNames.add(await this.getFiles(directory));
          }
          this.notifyListeners();
        });
        // Rimuovo le dirNames eccedenti
        if (this._dirNames.length > sharedPreferences.getStringList("Directories").length) {
          this._dirNames.removeAt(sharedPreferences.getStringList("Directories").length);
          this.notifyListeners();
        }
      } else {
        // Se le SharedPreferences non hanno directory svuoto anche dirNames e directories
        this._dirNames = [];
        this._directories = {};
        this.notifyListeners();
      }
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

  // Recupero la lista di colori
  void getColors() async {
    SharedPreferences sharedPreferences = await SharedPreferencesManager.getSharedPreferencesInstance();
    if (sharedPreferences.getStringList("Colors") != null) {
      if (sharedPreferences.getStringList("Colors").length > 0) {
        // Aggiorno le voci in colors con quelle nelle SharedPreferences
        sharedPreferences.getStringList("Colors").asMap().forEach((index, color) async {
          if (this._colors.length >= index + 1) {
            this._colors[index] = color;
          } else {
            this._colors.add(color);
          }
          this.notifyListeners();
        });
        // Rimuovo le colors eccedenti
        if (this._colors.length > sharedPreferences.getStringList("Colors").length) {
          this._colors.removeAt(sharedPreferences.getStringList("Colors").length);
        }
      } else {
        // Se le SharedPreferences non hanno colori svuoto anche colors
        this._colors = [];
      }
    }
  }

  void removeFromDirs(String dirName) {
    this._directories.remove(dirName);
    print(this._directories);
  }
}
