import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rpg_multi_music/shared_preferences_manager.dart';

class FilesProvider with ChangeNotifier {
  // Variabili condivise
  List<List<File>> _filesPaths = [];
  List<String> _dirsIds = [];
  List<String> _dirsPaths = [];
  List<String> _dirsColors = [];
  List<String> _dirsNames = [];
  List<String> _fontsColors = [];
  List<String> _settings = [
    "true", // Schermo sempre attivo di default
    "4279983648", // Colore della barra e del pulsante del più
    "4294638330", // Colore del font
    "assets/Background/Desert-Oasis-Town.jpg", // Immagine di sfondo
    "4294956367", // Colore di sfondo dietro la mappa
    "false" // Tutorial visto
  ];
  Map<String, String> _appFontColors = {
    "black": "4280361249",
    "white": "4294638330"
  };
  List<String> _backgroundImages = [];
  double _loadedBackgroundHeight = 0.0;
  double _loadedBackgroundWidth = 0.0;

  List<List<File>> get filesPaths => this._filesPaths;
  List<String> get dirsIds => this._dirsIds;
  List<String> get dirsPaths => this._dirsPaths;
  List<String> get dirsColors => this._dirsColors;
  List<String> get dirsNames => this._dirsNames;
  List<String> get fontsColors => this._fontsColors;
  List<String> get settings => this._settings;
  Map<String, String> get appFontColors => this._appFontColors;
  List<String> get backgroundImages => this._backgroundImages;
  double get loadedBackgroundHeight => this._loadedBackgroundHeight;
  double get loadedBackgroundWidth => this._loadedBackgroundWidth;

  // Recupero le liste di file
  void getFilesList() async {
    SharedPreferences sharedPreferences = await SharedPreferencesManager.getSharedPreferencesInstance();

    // Svuoto tutte le liste
    this._filesPaths = [];
    this._dirsIds = [];
    this._dirsPaths = [];
    this._dirsColors = [];
    this._dirsNames = [];
    this._fontsColors = [];

    if (sharedPreferences.getStringList("DirsId") != null && sharedPreferences.getStringList("DirsId").length > 0) {
      // Per ogni id salvato riempio le liste
      sharedPreferences.getStringList("DirsId").asMap().forEach((index, dirId) async {
        this._filesPaths.add(await this.getFiles(dirId, sharedPreferences.getStringList(dirId)[0]));
        this._dirsIds.add(dirId);
        this._dirsPaths.add(sharedPreferences.getStringList(dirId)[0]);
        this._dirsColors.add(sharedPreferences.getStringList(dirId)[1]);
        this._dirsNames.add(sharedPreferences.getStringList(dirId)[2]);
        this._fontsColors.add(sharedPreferences.getStringList(dirId)[3]);

        // Notifico i cambiamenti ai listener
        this.notifyListeners();
      });
    } else {
      // Se ho cancellato tutte le colonne notifico i cambiamenti ai listener
      this.notifyListeners();
    }
  }

  // Restituisce l`elenco dei file audio nella sotto cartella specificata
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

  // Recupera la lista di settings generici
  void getSettings() async {
    SharedPreferences sharedPreferences = await SharedPreferencesManager.getSharedPreferencesInstance();
    if (sharedPreferences.getStringList("Settings") != null) {
      this._settings = sharedPreferences.getStringList("Settings");
    }

    if (this.settings[3] != "none") {
      var img = await rootBundle.load(this.settings[3]);
      var decodedImage = await decodeImageFromList(img.buffer.asUint8List());
      this._loadedBackgroundHeight = decodedImage.height.toDouble();
      this._loadedBackgroundWidth = decodedImage.width.toDouble();
    }
    this.notifyListeners();
  }

  // Recupera le immagini di sfondo
  void getBackgroundImages() async {
    String manifestContent = await rootBundle.loadString('AssetManifest.json');
    Map<String, dynamic> manifestMap = json.decode(manifestContent);
    this._backgroundImages = manifestMap.keys
        .where((String key) => key.contains("assets/Background/"))
        .toList();
    this._backgroundImages.add("none");
  }
}
