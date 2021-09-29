import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:path_provider_ex/path_provider_ex.dart';
import 'package:permission_handler/permission_handler.dart';

class FilesProvider with ChangeNotifier {
  // Actual shared content.
  List<File> _musicNames = [];
  List<File> _ambienceNames = [];
  Directory _selectedLocalDirectory;
  Directory _selectedExternalDirectory;
  bool _useExternalMemory = false;

  List<File> get musicNames => this._musicNames;
  List<File> get ambienceNames => this._ambienceNames;

  Directory get selectedLocalDirectory => this._selectedLocalDirectory;
  Directory get selectedExternalDirectory => this._selectedExternalDirectory;

  bool get useExternalMemory => this._useExternalMemory;

  set selectedLocalDirectory(Directory dir) {
    this._selectedLocalDirectory = dir;
  }

  set selectedExternalDirectory(Directory dir) {
    this._selectedExternalDirectory = dir;
  }

  set useExternalMemory(bool val) {
    this._useExternalMemory = val;
  }

  // Recupero le liste di file
  void getFilesList() async {
    // Recupero i file dalla cartella 'music'
    this._musicNames = await this.getFiles("music");
    this.notifyListeners();
    print('GetFilesList music: ' + this.musicNames.toString());
    this._ambienceNames = await this.getFiles("ambience");
    this.notifyListeners();
    print('GetFilesList ambience: ' + this.ambienceNames.toString());
  }

  // Restituisce l'elenco dei file audio nella sotto cartella specificata
  // TODO: gestire da settings se usare storage locale o sd
  // TODO: gestire da settings il path da usare
  Future<List<File>> getFiles(String type) async {
    List<File> files;

    if (await Permission.storage.request().isGranted) {
      List<StorageInfo> storageInfo = await PathProviderEx.getStorageInfo();
      var root;
      FileManager fm;
      if (this._useExternalMemory) {
        root = storageInfo[1].rootDir; //storageInfo[1] for SD card, getting the root directory
        fm = FileManager(root: Directory(this._selectedExternalDirectory.path + "/" + type)); //
      } else {
        root = storageInfo[0].rootDir; //storageInfo[1] for SD card, getting the root directory
        fm = FileManager(root: Directory(this._selectedLocalDirectory.path + "/" + type)); //
      }

      files = await fm.filesTree(
        excludedPaths: ["/storage/emulated/0/Android"],
        extensions: ["mp3"],
      );
    }
    return files;
  }
}
