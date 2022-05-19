import 'dart:convert';
import 'dart:io';

import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:gdr_multi_music/shared_preferences_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilesProvider with ChangeNotifier {
  // Variabili condivise
  List<List<File>> _filesPaths = [];
  List<String> _dirsIds = [];
  List<String> _dirsPaths = [];
  List<String> _dirsColors = [];
  List<String> _dirsNames = [];
  List<String> _fontsColors = [];
  List<String> _settings = [
    "English", // Lingua di default
    "true", // Schermo sempre attivo di default
    "4294688813", // Colore della barra e del pulsante del più
    "4280361249", // Colore del font
    "assets/Background/Shipyard.jpg", // Immagine di sfondo
    "4292927712", // Colore di sfondo dietro la mappa
    "false" // Tutorial visto
  ];
  Map<String, dynamic> _translations = {
    "TUTORIAL": "**********************************************************",
    "welcome_tutorial": "Hi and welcome!",
    "settings_tutorial": "Here you will find the settings page, where you can change language, bar color, font color, background, etc...",
    "button_tutorial": "By clicking here you can add a new music folder and define path, background color, name and font color.",
    "done_tutorial": "Understood",
    "MAIN_PAGE": "*********************************************************",
    "state": "State",
    "playing": "Playing",
    "paused": "Paused",
    "stopped": "Stopped",
    "volume": "Volume",
    "random": "Random",
    "black": "Black",
    "white": "White",
    "POPUP": "*************************************************************",
    "new_column": "New column",
    "edit_column": "Edit column",
    "directory_path": "Directory path",
    "color": "Color",
    "name": "Name",
    "directory_name": "Directory name",
    "delete_column": "Delete column",
    "abort": "Abort",
    "save": "Save",
    "SETTINGS_PAGE": "*****************************************************",
    "settings": "Settings",
    "language": "Language",
    "screen_always_on": "Keep the screen always on",
    "appbar_color": "Bar color",
    "font_color": "Font color",
    "background_img": "Background image",
    "none": "None",
    "background_color": "Background color",
    "show_tutorial": "Show tutorial at start",
    "signal_bug_request_feature": "Do you want to signal a bug o request a feature?",
    "click_here": "Click here!",
    "2-minute-tabletop-attribution": "The astounding maps are drawn by 2-Minute Tabletop",
    "attribution-link": "Click here to see their works!",
    "url_error": "Error while opening the link"
  };
  Map<String, String> _languages = {
    "IT": "Italiano",
    "GB": "English",
    "ES": "Espanol",
    "FR": "Frances",
    "DE": "Deutsch"
  };
  String _deviceLanguage = "";
  Map<String, String> _appFontColors = {
    "black": "4280361249",
    "white": "4294638330"
  };
  List<String> _backgroundImages = [];

  List<List<File>> get filesPaths => this._filesPaths;
  List<String> get dirsIds => this._dirsIds;
  List<String> get dirsPaths => this._dirsPaths;
  List<String> get dirsColors => this._dirsColors;
  List<String> get dirsNames => this._dirsNames;
  List<String> get fontsColors => this._fontsColors;
  List<String> get settings => this._settings;
  Map<String, dynamic> get translations => this._translations;
  Map<String, String> get languages => this._languages;
  String get deviceLanguage => this._deviceLanguage;
  Map<String, String> get appFontColors => this._appFontColors;
  List<String> get backgroundImages => this._backgroundImages;

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
    this.getTranslations();
    this.notifyListeners();
  }

  // Recupera la lista di lingue disponibili
  void getLanguages() async {
    String devicelocale = await Devicelocale.currentLocale;
    this._settings[0] = _languages[devicelocale.split("-")[1]];
  }

  // Recupera le traduzioni dal file
  void getTranslations() async {
    var lang = this._settings.length > 0 ? this._settings[0] : "en";
    var jsonText = await rootBundle.loadString('assets/Languages/' + lang + '.json');
    this._translations = json.decode(jsonText);
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
