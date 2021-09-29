import 'dart:io';

import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:permission_handler/permission_handler.dart';

class Globals {

  static final Globals _instance = Globals._internal();

  // passes the instantiation to the _instance object
  factory Globals() => _instance;

  //initialize variables in here
  Globals._internal() {
    _useExternalMemory = false;
    _musicNames = [];
    _ambienceNames = [];
  }

  bool _useExternalMemory;
  List<File> _musicNames;
  List<File> _ambienceNames;

  //short getters
  bool get useExternalMemory => _useExternalMemory;
  List<File> get musicNames => _musicNames;
  List<File> get ambienceNames => _ambienceNames;

  //short setters
  set useExternalMemory(bool value) => _useExternalMemory = value;
  set musicNames(List<File> value) => _musicNames = value;
  set ambienceNames(List<File> value) => _ambienceNames = value;

  void getFilesList() {

    // Recupero i file dalla cartella 'music'
    getFiles("music").then((musicFiles) {
      // Recupero i file dalla cartella 'ambience'
      getFiles("ambience").then((ambienceFiles) {
        musicNames = musicFiles;
        ambienceNames = ambienceFiles;
      });
    });
  }

  // Restituisce l'elenco dei file audio nella sotto cartella specificata
  // TODO: gestire da settings se usare storage locale o sd
  // TODO: gestire da settings il path da usare
  Future<List<File>> getFiles(String type) async {

    List<File> files;

    if (await Permission.storage.request().isGranted) {
      List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
      var root;
      var fm;
      if (useExternalMemory) {
        root = storageInfo[1].rootDir; //storageInfo[1] for SD card, getting the root directory
        fm = FileManager(root: Directory(root + "/GDR/Musiche/" + type)); //
      } else {
        root = storageInfo[0].rootDir; //storageInfo[1] for SD card, getting the root directory
        fm = FileManager(root: Directory(root + "/Download/D&D/Musiche/" + type)); //
      }

      files = await fm.filesTree(
          excludedPaths: ["/storage/emulated/0/Android"],
          extensions: ["mp4", "m4a"] //optional, to filter files, remove to list all
      );
    }
    return files;
  }
}